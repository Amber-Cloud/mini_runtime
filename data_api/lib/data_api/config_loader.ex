defmodule DataApi.ConfigLoader do
  @moduledoc """
  Loads compiled configurations from Redis.
  """

  def load_all_configs do
    case Redix.start_link() do
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
      map_size(config["tables"]) > 0
  end
end
