defmodule DataCompiler do
  @moduledoc """
  Compiles application configuration into a format suitable for DataAPI.
  """

  def example_input() do
    %{
      "app_id" => "my_app",
      "endpoints" => [
        %{
          "path" => "/users",
          "method" => "GET",
          "table" => "users",
          "cardinality" => "all"
        },
        %{
          "path" => "/users",
          "method" => "GET",
          "table" => "users",
          "cardinality" => "one"
        },
        %{
          "path" => "/users",
          "method" => "POST",
          "table" => "users",
          "cardinality" => "one"
        }
      ],
      "tables" => %{
        "users" => %{
          "name" => "users",
          "columns" => [
            %{"name" => "id", "type" => "string"},
            %{"name" => "name", "type" => "string"},
            %{"name" => "email", "type" => "string"}
          ]
        }
      }
    }
  end

  def process_input(input) when is_binary(input) do
    case Jason.decode(input) do
      {:ok, parsed} -> process_input(parsed)
      {:error, reason} -> {:error, "Invalid JSON: #{reason}"}
    end
  end

  def process_input(input) when is_map(input) do
    case compile(input) do
      {:ok, compiled} -> store_in_redis(compiled)
      {:error, reason} -> {:error, reason}
    end
  end

  defp compile(%{"app_id" => app_id, "endpoints" => endpoints, "tables" => tables}) do
    compiled = %{
      app_id: app_id,
      endpoints: process_endpoints(endpoints),
      tables: process_tables(tables)
    }
    {:ok, compiled}
  end

  defp compile(_), do: {:error, "Invalid input format"}

  defp process_endpoints(endpoints) do
    Enum.map(endpoints, fn endpoint ->
      %{
        path: endpoint["path"],
        method: endpoint["method"],
        table: endpoint["table"],
        cardinality: endpoint["cardinality"],
        # Generate a unique key for this endpoint
        key: "#{endpoint["method"]}_#{String.replace(endpoint["path"], "/", "_")}_#{endpoint["cardinality"]}"
      }
    end)
  end

  defp process_tables(tables) do
    Enum.into(tables, %{}, fn {table_name, table_def} ->
      {table_name, %{
        name: table_def["name"],
        columns: Enum.map(table_def["columns"], fn col ->
          %{
            name: col["name"],
            type: col["type"]
          }
        end)
      }}
    end)
  end

  defp store_in_redis(compiled) do
    case Redix.start_link() do
      {:ok, conn} ->
        key = "compiled:#{compiled.app_id}"
        case Redix.command(conn, ["SET", key, Jason.encode!(compiled)]) do
          {:ok, "OK"} ->
            Redix.stop(conn)
            {:ok, compiled}
          {:error, reason} ->
            Redix.stop(conn)
            {:error, "Redis error: #{reason}"}
        end
      {:error, reason} ->
        {:error, "Redis connection failed: #{reason}"}
    end
  end

end
