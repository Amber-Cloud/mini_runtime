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
  All queries automatically include app_id filtering for multi-tenant isolation.

  ## Examples
      iex> build_query(endpoint, table_config, "blog_app", %{"id" => "123"}, %{})
      {:ok, {"SELECT id, name, email FROM users WHERE app_id = $1 AND id = $2", ["blog_app", "123"]}}
  """
  @spec build_query(endpoint_config(), table_config(), String.t(), path_params(), query_params()) ::
          query_result()
  def build_query(endpoint, table_config, app_id, path_params, query_params \\ %{}) do
    case endpoint["method"] do
      "GET" -> build_select_query(endpoint, table_config, app_id, path_params, query_params)
      _ -> {:error, "Unsupported HTTP method: #{endpoint["method"]}"}
    end
  end

  defp build_select_query(endpoint, table_config, app_id, path_params, query_params) do
    table_name = table_config["name"]
    columns = get_column_names(table_config)
    select_clause = "SELECT #{columns} FROM #{table_name}"

    case build_where_clause(table_config, app_id, path_params, query_params) do
      {where_clause, params} ->
        # WHERE clause is always present because we always filter by app_id
        query = "#{select_clause} WHERE #{where_clause}"

        # Add LIMIT for single record endpoints
        final_query =
          case endpoint["cardinality"] do
            "one" -> "#{query} LIMIT 1"
            _ -> query
          end

        {:ok, {final_query, params}}

      {:error, reason} ->
        {:error, reason}
    end
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

  defp build_where_clause(table_config, app_id, path_params, query_params) do
    # Always start with app_id as the first condition
    app_condition = "app_id = $1"
    app_param = [app_id]

    other_params = Map.merge(query_params, path_params)

    if map_size(other_params) == 0 do
      {app_condition, app_param}
    else
      case convert_and_build_conditions(table_config, other_params) do
        {:ok, {other_conditions, other_values}} ->
          all_conditions = [app_condition | other_conditions]
          all_values = app_param ++ other_values
          where_clause = Enum.join(all_conditions, " AND ")
          {where_clause, all_values}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  defp convert_and_build_conditions(table_config, params) do
    result =
      params
      |> Enum.with_index(2)
      |> Enum.reduce_while({:ok, {[], []}}, fn param_with_index, acc ->
        process_param_conversion(table_config, param_with_index, acc)
      end)

    case result do
      {:ok, {conditions, values}} -> {:ok, {Enum.reverse(conditions), Enum.reverse(values)}}
      error -> error
    end
  end

  defp process_param_conversion(table_config, {{key, value}, index}, {:ok, {conditions, values}}) do
    case convert_param_value(table_config, key, value) do
      {:ok, converted_value} ->
        new_condition = "#{key} = $#{index}"
        {:cont, {:ok, {[new_condition | conditions], [converted_value | values]}}}

      {:error, reason} ->
        {:halt, {:error, "Invalid value for column '#{key}': #{reason}"}}
    end
  end

  defp convert_param_value(table_config, column_name, value) do
    case get_column_type(table_config, column_name) do
      "integer" -> convert_to_integer(value)
      _ -> {:ok, value}
    end
  end

  defp convert_to_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {integer, ""} -> {:ok, integer}
      _ -> {:error, "cannot convert '#{value}' to integer"}
    end
  end

  defp convert_to_integer(value) when is_integer(value), do: {:ok, value}

  defp convert_to_integer(value),
    do: {:error, "expected string or integer, got #{inspect(value)}"}

  defp get_column_type(table_config, column_name) do
    table_config["columns"]
    |> Enum.find(%{}, fn col -> col["name"] == column_name end)
    |> Map.get("type", "string")
  end
end
