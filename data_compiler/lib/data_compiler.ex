defmodule DataCompiler do
  @moduledoc """
  Compiles application configuration into a format suitable for DataAPI.
  """

  def process_input(input) when is_binary(input) do
    case Jason.decode(input) do
      {:ok, parsed} -> process_input(parsed)
      {:error, %Jason.DecodeError{data: data}} -> {:error, "Invalid JSON: #{data}"}
    end
  end

  def process_input(input) when is_map(input) do
    case compile(input) do
      {:ok, compiled} -> store_in_redis(compiled)
      {:error, reason} -> {:error, reason}
    end
  end

  defp compile(%{"app_id" => app_id, "endpoints" => endpoints, "tables" => tables}) do
    with {:ok, processed_endpoints} <- process_endpoints(endpoints, app_id),
         {:ok, processed_tables} <- process_tables(tables) do
      compiled = %{
        "app_id" => app_id,
        "endpoints" => processed_endpoints,
        "tables" => processed_tables
      }
      {:ok, compiled}
    end
  end

  defp compile(_), do: {:error, "Invalid input format"}

  defp process_endpoints([], _app_id) do
    {:error, "No endpoints provided"}
  end

  defp process_endpoints(endpoints, app_id) do
    processed = Enum.map(endpoints, fn endpoint ->
      %{
        "path" => endpoint["path"],
        "method" => endpoint["method"],
        "table" => endpoint["table"],
        "cardinality" => endpoint["cardinality"],
        "app_id" => app_id,
        # Generate a unique key for this endpoint
        "key" =>
          "#{endpoint["method"]}_#{app_id}_#{endpoint["path"] |> String.trim_leading("/") |> String.replace(":", "") |> String.replace("/", "_")}_#{endpoint["cardinality"]}"
      }
    end)
    {:ok, processed}
  end

  defp process_tables(tables) when map_size(tables) > 0 do
    case validate_and_process_tables(tables) do
      {:ok, processed} -> {:ok, processed}
      {:error, reason} -> {:error, reason}
    end
  end

  defp process_tables(_), do: {:error, "No tables defined"}

  defp validate_and_process_tables(tables) do
    try do
      processed = Enum.into(tables, %{}, fn {table_name, table_def} ->
        case validate_table_columns(table_def["columns"]) do
          :ok ->
            {table_name,
             %{
               "name" => table_def["name"],
               "columns" =>
                 Enum.map(table_def["columns"], fn col ->
                   %{
                     "name" => col["name"],
                     "type" => col["type"]
                   }
                 end)
             }}
          {:error, reason} ->
            throw({:validation_error, "Table '#{table_name}': #{reason}"})
        end
      end)
      {:ok, processed}
    catch
      {:validation_error, reason} -> {:error, reason}
    end
  end

  defp validate_table_columns(columns) when is_list(columns) do
    valid_types = ["integer", "string"]

    invalid_columns = Enum.reject(columns, fn col ->
      col["type"] in valid_types
    end)

    case invalid_columns do
      [] -> :ok
      [invalid_col | _] ->
        {:error, "Invalid column type '#{invalid_col["type"]}' for column '#{invalid_col["name"]}'. Supported types: #{Enum.join(valid_types, ", ")}"}
    end
  end

  defp validate_table_columns(_), do: {:error, "Columns must be a list"}



  defp store_in_redis(compiled) do
    redis_host = System.get_env("REDIS_HOST") || "localhost"
    redis_port = String.to_integer(System.get_env("REDIS_PORT") || "6379")

    redis_opts = case Mix.env() do
      :test -> [database: 1, host: redis_host, port: redis_port]
      _ -> [host: redis_host, port: redis_port]
    end

    case Redix.start_link(redis_opts) do
      {:ok, conn} ->
        key = "config:#{compiled["app_id"]}"

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
