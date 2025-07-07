defmodule DataApi.QueryBuilderTest do
  use ExUnit.Case, async: true

  alias DataApi.QueryBuilder
  alias DataApi.TestFixtures

  describe "build_query/4 - GET endpoints with no parameters" do
    test "builds SELECT query for GET many endpoint" do
      endpoint = %{
        "method" => "GET",
        "cardinality" => "many",
        "table" => "users"
      }

      table_config = %{
        "name" => "users",
        "columns" => [
          %{"name" => "id", "type" => "integer"},
          %{"name" => "name", "type" => "string"},
          %{"name" => "email", "type" => "string"}
        ]
      }

      assert {:ok, {query, params}} =
               QueryBuilder.build_query(endpoint, table_config, "test_app", %{}, %{})

      assert query == "SELECT id, name, email FROM users WHERE app_id = $1"
      assert params == ["test_app"]
    end

    test "builds SELECT query for GET one endpoint with LIMIT" do
      endpoint = %{
        "method" => "GET",
        "cardinality" => "one",
        "table" => "users"
      }

      table_config = %{
        "name" => "users",
        "columns" => [
          %{"name" => "id", "type" => "integer"},
          %{"name" => "name", "type" => "string"}
        ]
      }

      assert {:ok, {query, params}} =
               QueryBuilder.build_query(endpoint, table_config, "test_app", %{}, %{})

      assert query == "SELECT id, name FROM users WHERE app_id = $1 LIMIT 1"
      assert params == ["test_app"]
    end

    test "handles empty columns list with SELECT *" do
      endpoint = %{
        "method" => "GET",
        "cardinality" => "many",
        "table" => "users"
      }

      table_config = %{
        "name" => "users",
        "columns" => []
      }

      assert {:ok, {query, params}} =
               QueryBuilder.build_query(endpoint, table_config, "test_app", %{}, %{})

      assert query == "SELECT * FROM users WHERE app_id = $1"
      assert params == ["test_app"]
    end

    test "handles nil columns with SELECT *" do
      endpoint = %{
        "method" => "GET",
        "cardinality" => "one",
        "table" => "users"
      }

      table_config = %{
        "name" => "users",
        "columns" => nil
      }

      assert {:ok, {query, params}} =
               QueryBuilder.build_query(endpoint, table_config, "test_app", %{}, %{})

      assert query == "SELECT * FROM users WHERE app_id = $1 LIMIT 1"
      assert params == ["test_app"]
    end
  end

  describe "build_query/4 - GET endpoints with path parameters" do
    test "builds SELECT query with single path parameter" do
      endpoint = %{
        "method" => "GET",
        "cardinality" => "one",
        "table" => "users"
      }

      table_config = %{
        "name" => "users",
        "columns" => [
          %{"name" => "id", "type" => "integer"},
          %{"name" => "name", "type" => "string"}
        ]
      }

      path_params = %{"id" => "123"}

      assert {:ok, {query, params}} =
               QueryBuilder.build_query(endpoint, table_config, "test_app", path_params, %{})

      assert query == "SELECT id, name FROM users WHERE app_id = $1 AND id = $2 LIMIT 1"
      assert params == ["test_app", "123"]
    end

    test "builds SELECT query with multiple path parameters" do
      endpoint = %{
        "method" => "GET",
        "cardinality" => "many",
        "table" => "comments"
      }

      table_config = %{
        "name" => "comments",
        "columns" => [
          %{"name" => "id", "type" => "integer"},
          %{"name" => "content", "type" => "text"},
          %{"name" => "article_id", "type" => "integer"}
        ]
      }

      path_params = %{"article_id" => "456", "comment_id" => "789"}

      assert {:ok, {query, [app_param, param1, param2]}} =
               QueryBuilder.build_query(endpoint, table_config, "blog_app", path_params, %{})

      assert String.contains?(query, "WHERE")
      assert String.contains?(query, "app_id = $1")
      assert String.contains?(query, "article_id = $")
      assert String.contains?(query, "comment_id = $")
      assert String.contains?(query, "AND")
      assert app_param == "blog_app"

      # Test that each key's value ends up in the right position (starting from $2)
      cond do
        String.contains?(query, "article_id = $2") ->
          assert param1 == "456"
          assert param2 == "789"
          assert String.contains?(query, "comment_id = $3")

        String.contains?(query, "comment_id = $2") ->
          assert param1 == "789"
          assert param2 == "456"
          assert String.contains?(query, "article_id = $3")

        true ->
          flunk("Unexpected query format: #{query}")
      end
    end
  end

  describe "build_query/4 - GET endpoints with query parameters" do
    test "builds SELECT query with query parameters only" do
      endpoint = %{
        "method" => "GET",
        "cardinality" => "many",
        "table" => "users"
      }

      table_config = %{
        "name" => "users",
        "columns" => [
          %{"name" => "id", "type" => "integer"},
          %{"name" => "name", "type" => "string"},
          %{"name" => "status", "type" => "string"}
        ]
      }

      query_params = %{"status" => "active", "name" => "John"}

      assert {:ok, {query, [app_param, param1, param2]}} =
               QueryBuilder.build_query(endpoint, table_config, "test_app", %{}, query_params)

      assert String.contains?(query, "WHERE")
      assert String.contains?(query, "app_id = $1")
      assert String.contains?(query, "status = $")
      assert String.contains?(query, "name = $")
      assert String.contains?(query, "AND")
      assert app_param == "test_app"

      # Test that each key's value ends up in the right position (starting from $2)
      cond do
        String.contains?(query, "status = $2") ->
          assert param1 == "active"
          assert param2 == "John"
          assert String.contains?(query, "name = $3")

        String.contains?(query, "name = $2") ->
          assert param1 == "John"
          assert param2 == "active"
          assert String.contains?(query, "status = $3")

        true ->
          flunk("Unexpected query format: #{query}")
      end
    end

    test "builds SELECT query with single query parameter" do
      endpoint = %{
        "method" => "GET",
        "cardinality" => "many",
        "table" => "users"
      }

      table_config = %{
        "name" => "users",
        "columns" => [
          %{"name" => "id", "type" => "integer"},
          %{"name" => "email", "type" => "string"}
        ]
      }

      query_params = %{"email" => "john@example.com"}

      assert {:ok, {query, params}} =
               QueryBuilder.build_query(endpoint, table_config, "test_app", %{}, query_params)

      assert query == "SELECT id, email FROM users WHERE app_id = $1 AND email = $2"
      assert params == ["test_app", "john@example.com"]
    end
  end

  describe "build_query/4 - GET endpoints with mixed parameters" do
    test "builds SELECT query with both path and query parameters" do
      endpoint = %{
        "method" => "GET",
        "cardinality" => "many",
        "table" => "comments"
      }

      table_config = %{
        "name" => "comments",
        "columns" => [
          %{"name" => "id", "type" => "integer"},
          %{"name" => "content", "type" => "text"},
          %{"name" => "article_id", "type" => "integer"},
          %{"name" => "status", "type" => "string"}
        ]
      }

      path_params = %{"article_id" => "123"}
      query_params = %{"status" => "approved"}

      assert {:ok, {query, [app_param, param1, param2]}} =
               QueryBuilder.build_query(
                 endpoint,
                 table_config,
                 "test_app",
                 path_params,
                 query_params
               )

      assert String.contains?(query, "WHERE")
      assert String.contains?(query, "app_id = $1")
      assert String.contains?(query, "article_id = $")
      assert String.contains?(query, "status = $")
      assert String.contains?(query, "AND")
      assert app_param == "test_app"

      # Test that each key's value ends up in the right position (starting from $2)
      cond do
        String.contains?(query, "article_id = $2") ->
          assert param1 == "123"
          assert param2 == "approved"
          assert String.contains?(query, "status = $3")

        String.contains?(query, "status = $2") ->
          assert param1 == "approved"
          assert param2 == "123"
          assert String.contains?(query, "article_id = $3")

        true ->
          flunk("Unexpected query format: #{query}")
      end
    end

    test "path parameters take precedence over query parameters in conflicts" do
      endpoint = %{
        "method" => "GET",
        "cardinality" => "one",
        "table" => "users"
      }

      table_config = %{
        "name" => "users",
        "columns" => [
          %{"name" => "id", "type" => "integer"},
          %{"name" => "name", "type" => "string"}
        ]
      }

      path_params = %{"id" => "123"}
      # Conflict!
      query_params = %{"id" => "456"}

      assert {:ok, {query, params}} =
               QueryBuilder.build_query(
                 endpoint,
                 table_config,
                 "test_app",
                 path_params,
                 query_params
               )

      assert query == "SELECT id, name FROM users WHERE app_id = $1 AND id = $2 LIMIT 1"
      # Path param wins
      assert params == ["test_app", "123"]
    end
  end

  describe "build_query/4 - error cases" do
    test "returns error for unsupported HTTP method POST" do
      endpoint = %{
        "method" => "POST",
        "cardinality" => "one",
        "table" => "users"
      }

      table_config = %{
        "name" => "users",
        "columns" => [
          %{"name" => "id", "type" => "integer"}
        ]
      }

      assert {:error, "Unsupported HTTP method: POST"} =
               QueryBuilder.build_query(endpoint, table_config, "test_app", %{}, %{})
    end

    test "returns error for unsupported HTTP method PUT" do
      endpoint = %{
        "method" => "PUT",
        "cardinality" => "one",
        "table" => "users"
      }

      table_config = %{
        "name" => "users",
        "columns" => []
      }

      assert {:error, "Unsupported HTTP method: PUT"} =
               QueryBuilder.build_query(endpoint, table_config, "test_app", %{}, %{})
    end

    test "returns error for unsupported HTTP method DELETE" do
      endpoint = %{
        "method" => "DELETE",
        "cardinality" => "one",
        "table" => "users"
      }

      table_config = %{
        "name" => "users",
        "columns" => []
      }

      assert {:error, "Unsupported HTTP method: DELETE"} =
               QueryBuilder.build_query(endpoint, table_config, "test_app", %{}, %{})
    end
  end

  describe "build_query/4 - integration with test fixtures" do
    test "works with test app fixtures - GET many users" do
      config = TestFixtures.test_app_config()

      endpoint =
        Enum.find(config["endpoints"], fn ep ->
          ep["method"] == "GET" and ep["cardinality"] == "many" and ep["path"] == "/users"
        end)

      table_config = config["tables"]["users"]

      assert {:ok, {query, params}} =
               QueryBuilder.build_query(endpoint, table_config, "test_app", %{}, %{})

      assert query == "SELECT id, name, email FROM users WHERE app_id = $1"
      assert params == ["test_app"]
    end

    test "works with test app fixtures - GET one user by id" do
      config = TestFixtures.test_app_config()

      endpoint =
        Enum.find(config["endpoints"], fn ep ->
          ep["method"] == "GET" and ep["cardinality"] == "one" and ep["path"] == "/users/:id"
        end)

      table_config = config["tables"]["users"]
      path_params = %{"id" => "123"}

      assert {:ok, {query, params}} =
               QueryBuilder.build_query(endpoint, table_config, "test_app", path_params, %{})

      assert query == "SELECT id, name, email FROM users WHERE app_id = $1 AND id = $2 LIMIT 1"
      assert params == ["test_app", "123"]
    end

    test "works with blog app fixtures - GET comments for article" do
      config = TestFixtures.blog_app_config()

      endpoint =
        Enum.find(config["endpoints"], fn ep ->
          ep["method"] == "GET" and ep["path"] == "/articles/:id/comments"
        end)

      table_config = config["tables"]["comments"]
      path_params = %{"id" => "456"}

      assert {:ok, {query, params}} =
               QueryBuilder.build_query(endpoint, table_config, "blog_app", path_params, %{})

      assert query == "SELECT id, content, article_id FROM comments WHERE app_id = $1 AND id = $2"
      assert params == ["blog_app", "456"]
    end

    test "works with blog app fixtures - GET articles (many)" do
      config = TestFixtures.blog_app_config()

      endpoint =
        Enum.find(config["endpoints"], fn ep ->
          ep["method"] == "GET" and ep["path"] == "/articles"
        end)

      table_config = config["tables"]["articles"]

      assert {:ok, {query, params}} =
               QueryBuilder.build_query(endpoint, table_config, "blog_app", %{}, %{})

      assert query == "SELECT id, title, content FROM articles WHERE app_id = $1"
      assert params == ["blog_app"]
    end
  end
end
