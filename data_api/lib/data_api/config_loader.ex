defmodule DataApi.ConfigLoader do
  @moduledoc """
  Loads compiled configurations from Redis.
  """

  @doc """
  Loads all valid application configurations from Redis.

  Connects to Redis, finds all keys matching "config:*", loads and validates each
  configuration, then returns only the valid ones.

  ## Examples
      iex> load_all_configs()
      {:ok, [%{"app_id" => "blog_app", "endpoints" => [...], "tables" => %{...}}]}

      iex> load_all_configs()
      {:error, "No valid configurations found"}
  """
  def load_all_configs do
    redis_opts = case Mix.env() do
      :test -> [database: 1]
      _ -> []
    end

    case Redix.start_link(redis_opts) do
      {:ok, conn} ->
        case Redix.command(conn, ["KEYS", "config:*"]) do
          {:ok, keys} ->
            configs =
              Enum.map(keys, fn key ->
                app_id = String.replace_prefix(key, "config:", "")
                load_config(conn, app_id)
              end)

            Redix.stop(conn)

            # return only successful configs
            successful_configs =
              Enum.filter(configs, fn
                {:ok, _config} -> true
                {:error, _reason} -> false
              end)

            case successful_configs do
              [] -> {:error, "No valid configurations found"}
              configs -> {:ok, Enum.map(configs, fn {:ok, config} -> config end)}
            end

          {:error, reason} ->
            Redix.stop(conn)
            {:error, "Redis error: #{reason}"}
        end

      {:error, reason} ->
        {:error, "Redis connection failed: #{reason}"}
    end
  end

  defp load_config(conn, app_id) do
    key = "config:#{app_id}"

    case Redix.command(conn, ["GET", key]) do
      {:ok, nil} ->
        {:error, "Configuration not found for app_id: #{app_id}"}

      {:ok, json_data} ->
        case Jason.decode(json_data) do
          {:ok, config} ->
            if valid_config?(config) do
              {:ok, config}
            else
              {:error, "Invalid configuration structure for app_id: #{app_id}"}
            end

          {:error, _} ->
            {:error, "Invalid JSON for app_id: #{app_id}"}
        end

      {:error, reason} ->
        {:error, "Redis error for app_id #{app_id}: #{reason}"}
    end
  end

  defp valid_config?(config) do
    is_map(config) and
      Map.has_key?(config, "app_id") and
      Map.has_key?(config, "endpoints") and
      Map.has_key?(config, "tables") and
      is_list(config["endpoints"]) and
      length(config["endpoints"]) > 0 and
      is_map(config["tables"]) and
      map_size(config["tables"]) > 0 and
      valid_table_types?(config["tables"])
  end

  defp valid_table_types?(tables) do
    Enum.all?(tables, fn {_table_name, table_def} ->
      valid_table_columns?(table_def["columns"])
    end)
  end

  defp valid_table_columns?(columns) when is_list(columns) do
    valid_types = ["integer", "string"]
    Enum.all?(columns, fn col -> col["type"] in valid_types end)
  end

  defp valid_table_columns?(_), do: false
end
