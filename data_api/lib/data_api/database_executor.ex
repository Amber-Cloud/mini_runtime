defmodule DataApi.DatabaseExecutor do
  @moduledoc """
  Executes SQL queries against the Postgres database.
  """

  alias DataApi.Repo

  @type query_result :: {:ok, [map()]} | {:error, String.t()}

  @doc """
  Executes a SQL query with parameters against the database.

  Returns the results as a list of maps where each map represents a row
  with column names as keys and values as the corresponding row values.

  ## Examples
      iex> execute_query("SELECT id, name FROM users WHERE app_id = $1", ["test_app"])
      {:ok, [%{"id" => 1, "name" => "John Doe"}, %{"id" => 2, "name" => "Jane Smith"}]}

      iex> execute_query("SELECT * FROM users WHERE app_id = $1 AND id = $2", ["test_app", "999"])
      {:ok, []}
  """
  @spec execute_query(String.t(), [String.t()]) :: query_result()
  def execute_query(sql, params) do
    case Repo.query(sql, params) do
      {:ok, %{rows: rows, columns: columns}} ->
        results = Enum.map(rows, fn row ->
          Enum.zip(columns, row) |> Enum.into(%{})
        end)
        {:ok, results}

      {:error, %{message: message}} ->
        {:error, "Database error: #{message}"}

      {:error, error} ->
        {:error, "Database error: #{inspect(error)}"}
    end
  end
end
