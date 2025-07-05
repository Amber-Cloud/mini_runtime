defmodule DataApi.EndpointMatcher do
  @moduledoc """
  Matches incoming HTTP requests to endpoint configurations.

  Takes a request (method + path) and finds the matching endpoint config
  from the loaded configurations, extracting any path parameters.
  """

  @type config :: map()
  @type endpoint_config :: map()
  @type table_config :: map()
  @type path_params :: %{String.t() => String.t()}

  @doc """
  Finds the endpoint config that matches the given HTTP method and path.

  ## Examples
      iex> match_endpoint(configs, "GET", "/users/123")
      {:ok, {%{"path" => "/users/:id", "method" => "GET", ...}, %{"users" => ...}, %{"id" => "123"}}}

      iex> match_endpoint(configs, "DELETE", "/nonexistent")
      {:error, :not_found}
  """
  @spec match_endpoint([config()], String.t(), String.t()) ::
          {:ok, {endpoint_config(), table_config(), path_params()}} | {:error, :not_found}

  def match_endpoint(configs, method, path) do
    normalized_method = String.upcase(method)
    all_endpoints = Enum.flat_map(configs, fn config -> config["endpoints"] end)

    find_matching_endpoint(all_endpoints, configs, normalized_method, path)
  end

  # Find the first endpoint that matches method and path
  defp find_matching_endpoint(endpoints, configs, method, path) do
    result = Enum.find_value(endpoints, fn endpoint ->
      try_match_endpoint(endpoint, configs, method, path)
    end)

    case result do
      nil -> {:error, :not_found}
      match_data -> {:ok, match_data}
    end
  end

  # Try to match a single endpoint against the request
  defp try_match_endpoint(endpoint, configs, method, path) do
    if endpoint["method"] == method do
      case match_path_pattern(endpoint["path"], path) do
        {:ok, path_params} ->
          build_match_result(endpoint, configs, path_params)
        {:error, :no_match} ->
          nil
      end
    else
      nil
    end
  end

  # Build the final match result with table config
  defp build_match_result(endpoint, configs, path_params) do
    table_name = endpoint["table"]
    case find_table_config(configs, endpoint["app_id"], table_name) do
      {:ok, table_config} ->
        {endpoint, table_config, path_params}
      {:error, :not_found} ->
        nil
    end
  end

  # Matches a path pattern (like "/users/:id") against an actual path (like "/users/123")
  defp match_path_pattern(pattern, actual_path) do
    pattern_segments = String.split(pattern, "/", trim: true)
    actual_segments = String.split(actual_path, "/", trim: true)

    # Paths must have same number of segments to match
    if length(pattern_segments) == length(actual_segments) do
      extract_params(pattern_segments, actual_segments, %{})
    else
      {:error, :no_match}
    end
  end

  defp extract_params([], [], params), do: {:ok, params}

  defp extract_params([pattern_segment | pattern_rest], [actual_segment | actual_rest], params) do
    cond do
      # Parameter segment (starts with :)
      String.starts_with?(pattern_segment, ":") ->
        param_name = String.trim_leading(pattern_segment, ":")
        new_params = Map.put(params, param_name, actual_segment)
        extract_params(pattern_rest, actual_rest, new_params)

      # Literal segment must match exactly
      pattern_segment == actual_segment ->
        extract_params(pattern_rest, actual_rest, params)

      true ->
        {:error, :no_match}
    end
  end

  # Find table configuration for a specific app and table name
  defp find_table_config(configs, app_id, table_name) do
    app_config = Enum.find(configs, fn config -> config["app_id"] == app_id end)

    case app_config do
      nil ->
        {:error, :not_found}
      config ->
        case config["tables"][table_name] do
          nil -> {:error, :not_found}
          table_config -> {:ok, table_config}
        end
    end
  end
end
