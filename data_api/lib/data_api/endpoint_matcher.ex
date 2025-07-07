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

  The path must be in format "/app_id/endpoint_path" where app_id identifies
  which application's endpoints to search.

  ## Examples
      iex> match_endpoint(configs, "GET", "/blog_app/users/123")
      {:ok, {%{"path" => "/users/:id", "method" => "GET", ...}, %{"users" => ...}, %{"id" => "123"}}}

      iex> match_endpoint(configs, "GET", "/unknown_app/users")
      {:error, :app_not_found}

      iex> match_endpoint(configs, "GET", "/blog_app/nonexistent")
      {:error, :endpoint_not_found}
  """
  @spec match_endpoint([config()], String.t(), String.t()) ::
          {:ok, {endpoint_config(), table_config(), path_params()}}
          | {:error, :app_not_found | :endpoint_not_found}

  def match_endpoint(configs, method, path) do
    normalized_method = String.upcase(method)

    case extract_app_id_and_endpoint_path(path) do
      {:ok, {app_id, endpoint_path}} ->
        case find_app_config(configs, app_id) do
          {:ok, app_config} ->
            find_matching_endpoint(
              app_config["endpoints"],
              app_config,
              normalized_method,
              endpoint_path
            )

          {:error, :not_found} ->
            {:error, :app_not_found}
        end

      {:error, :invalid_path} ->
        {:error, :invalid_path}
    end
  end

  # Extract app_id and endpoint path from request path like "/blog_app/users/123"
  defp extract_app_id_and_endpoint_path(path) do
    segments = path |> String.trim_trailing("/") |> String.split("/", trim: true)

    case segments do
      [app_id | endpoint_segments] ->
        endpoint_path = "/" <> Enum.join(endpoint_segments, "/")
        {:ok, {app_id, endpoint_path}}

      [] ->
        {:error, :invalid_path}
    end
  end

  # Find a specific app's config by app_id
  defp find_app_config(configs, app_id) do
    case Enum.find(configs, fn config -> config["app_id"] == app_id end) do
      nil -> {:error, :not_found}
      app_config -> {:ok, app_config}
    end
  end

  # Find the first endpoint that matches method and path
  defp find_matching_endpoint(endpoints, app_config, method, path) do
    result =
      Enum.find_value(endpoints, fn endpoint ->
        try_match_endpoint(endpoint, app_config, method, path)
      end)

    case result do
      nil -> {:error, :endpoint_not_found}
      match_data -> {:ok, match_data}
    end
  end

  # Try to match a single endpoint against the request
  defp try_match_endpoint(endpoint, app_config, method, path) do
    if endpoint["method"] == method and endpoint["app_id"] == app_config["app_id"] do
      case match_path_pattern(endpoint["path"], path) do
        {:ok, path_params} ->
          build_match_result(endpoint, app_config, path_params)

        {:error, :no_match} ->
          nil
      end
    else
      nil
    end
  end

  # Build the final match result with table config
  defp build_match_result(endpoint, app_config, path_params) do
    table_name = endpoint["table"]

    case app_config["tables"][table_name] do
      nil ->
        nil

      table_config ->
        {endpoint, table_config, path_params}
    end
  end

  # Matches a path pattern (like "/users/:id") against an actual path (like "/users/123")
  defp match_path_pattern(pattern, actual_path) do
    # Normalize paths by removing trailing slashes and split into segments
    pattern_segments = pattern |> String.trim_trailing("/") |> String.split("/", trim: true)
    actual_segments = actual_path |> String.trim_trailing("/") |> String.split("/", trim: true)

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
end
