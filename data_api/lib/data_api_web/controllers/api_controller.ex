defmodule DataApiWeb.ApiController do
  use DataApiWeb, :controller

  alias DataApi.ConfigLoader
  alias DataApi.EndpointMatcher
  alias DataApi.QueryBuilder
  alias DataApi.DatabaseExecutor

  @doc """
  Handles API requests by matching them against loaded configurations.

  Expected path format: /app_id/endpoint_path
  Example: GET /blog_app/users/123
  """
  def handle_request(
        %Plug.Conn{method: method, path_info: path_info, query_params: query_params} = conn,
        _params
      ) do
    path = "/" <> Enum.join(path_info, "/")

    case process_request(method, path, query_params) do
      {:ok, results} ->
        json(conn, results)

      {:error, :app_not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Application not found in DB"})

      {:error, :endpoint_not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Endpoint not found"})

      {:error, :invalid_path} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid path format. Expected: /app_id/endpoint_path"})

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: inspect(reason)})
    end
  end

  defp process_request(method, path, query_params) do
    with {:ok, configs} <- ConfigLoader.load_all_configs(),
         {:ok, {endpoint, table_config, path_params}} <-
           EndpointMatcher.match_endpoint(configs, method, path),
         {:ok, {sql, params}} <-
           QueryBuilder.build_query(
             endpoint,
             table_config,
             extract_app_id(path),
             path_params,
             query_params
           ),
         {:ok, results} <- DatabaseExecutor.execute_query(sql, params) do
      # Return single object for cardinality: "one", array for cardinality: "many"
      final_results = format_results_by_cardinality(endpoint, results)
      {:ok, final_results}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Handles unsupported HTTP methods with a 405 Method Not Allowed response.
  """
  def method_not_allowed(conn, _params) do
    conn
    |> put_status(:method_not_allowed)
    |> json(%{error: "Method not allowed. Only GET requests are supported."})
  end

  defp extract_app_id(path) do
    path
    |> String.trim_leading("/")
    |> String.split("/", parts: 2)
    |> hd()
  end

  # Format results based on endpoint cardinality
  defp format_results_by_cardinality(endpoint, results) do
    case endpoint["cardinality"] do
      "one" ->
        case results do
          [single_result] -> single_result
          [] -> nil
          _ -> List.first(results)
        end

      _ ->
        results
    end
  end
end
