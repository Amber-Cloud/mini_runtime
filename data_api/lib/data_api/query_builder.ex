defmodule DataApi.QueryBuilder do
  @moduledoc """
  Builds SQL queries from endpoint configurations, table definitions, and request parameters.

  Currently supports:
  - GET: SELECT queries (with WHERE clauses for path parameters)
  """

  @type endpoint_config :: map()
  @type table_config :: map()
  @type path_params :: %{String.t() => String.t()}
  @type query_params :: %{String.t() => String.t()}
  @type query_result :: {:ok, {String.t(), [String.t()]}} | {:error, String.t()}

  @doc """
  Builds a SQL query based on the endpoint configuration, table config, and request parameters.

  Returns a tuple with the SQL query string and a list of parameters for safe parameterized queries.

  ## Examples
      iex> build_query(get_endpoint, table_config, %{"id" => "123"}, %{})
      {:ok, {"SELECT id, name, email FROM users WHERE id = $1", ["123"]}}
  """
  @spec build_query(endpoint_config(), table_config(), path_params(), query_params()) ::
          query_result()
  def build_query(endpoint, table_config, path_params, query_params \\ %{}) do
    case endpoint["method"] do
      "GET" -> build_select_query(endpoint, table_config, path_params, query_params)
      _ -> {:error, "Unsupported HTTP method: #{endpoint["method"]}"}
    end
  end

  defp build_select_query(endpoint, table_config, path_params, query_params) do
    table_name = table_config["name"]
    columns = get_column_names(table_config)
    select_clause = "SELECT #{columns} FROM #{table_name}"

    {where_clause, params} = build_where_clause(path_params, query_params)

    query =
      case where_clause do
        "" -> select_clause
        _ -> "#{select_clause} WHERE #{where_clause}"
      end

    # Add LIMIT for single record endpoints
    final_query =
      case endpoint["cardinality"] do
        "one" -> "#{query} LIMIT 1"
        _ -> query
      end

    {:ok, {final_query, params}}
  end

  defp get_column_names(table_config) do
    case table_config["columns"] do
      [] ->
        "*"

      nil ->
        "*"

      columns ->
        columns
        |> Enum.map(fn col -> col["name"] end)
        |> Enum.join(", ")
    end
  end

  defp build_where_clause(path_params, query_params) do
    all_params = Map.merge(query_params, path_params)

    if map_size(all_params) == 0 do
      {"", []}
    else
      # NB we retrieve the keys and values in the same pipeline to guarantee the order
      {conditions, values} = all_params
      |> Enum.with_index(1)
      |> Enum.map(fn {{key, value}, index} ->
        {"#{key} = $#{index}", value}
      end)
      |> Enum.unzip()

      where_clause = Enum.join(conditions, " AND ")
      {where_clause, values}
    end
  end
end
