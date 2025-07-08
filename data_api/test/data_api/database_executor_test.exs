defmodule DataApi.DatabaseExecutorTest do
  use ExUnit.Case, async: true
  use DataApi.DataCase

  alias DataApi.DatabaseExecutor
  alias DataApi.Repo

  describe "execute_query/2" do
    test "executes simple SELECT query and returns results as maps" do
      Repo.insert_all("users", [
        %{
          name: "John Doe",
          email: "john@test.com",
          app_id: "test_app",
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        },
        %{
          name: "Jane Smith",
          email: "jane@test.com",
          app_id: "test_app",
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      ])

      sql = "SELECT id, name, email FROM users WHERE app_id = $1"
      params = ["test_app"]

      assert {:ok, results} = DatabaseExecutor.execute_query(sql, params)
      assert length(results) == 2

      names = Enum.map(results, fn user -> user["name"] end)
      emails = Enum.map(results, fn user -> user["email"] end)

      assert "Jane Smith" in names
      assert "John Doe" in names
      assert "jane@test.com" in emails
      assert "john@test.com" in emails
    end

    test "executes query with multiple parameters" do
      Repo.insert_all("users", [
        %{
          name: "Alice",
          email: "alice@test.com",
          app_id: "test_app",
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      ])

      sql = "SELECT name, email FROM users WHERE app_id = $1 AND email = $2"
      params = ["test_app", "alice@test.com"]

      assert {:ok, results} = DatabaseExecutor.execute_query(sql, params)
      assert length(results) == 1

      [user] = results
      assert user["name"] == "Alice"
      assert user["email"] == "alice@test.com"
    end

    test "returns empty list when no results found" do
      sql = "SELECT * FROM users WHERE app_id = $1 AND id = $2"
      params = ["nonexistent_app", 999]

      assert {:ok, results} = DatabaseExecutor.execute_query(sql, params)
      assert results == []
    end

    test "handles queries with LIMIT clause" do
      Repo.insert_all("users", [
        %{
          name: "User 1",
          email: "user1@test.com",
          app_id: "test_app",
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        },
        %{
          name: "User 2",
          email: "user2@test.com",
          app_id: "test_app",
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      ])

      sql = "SELECT name FROM users WHERE app_id = $1 LIMIT 1"
      params = ["test_app"]

      assert {:ok, [result]} = DatabaseExecutor.execute_query(sql, params)
      assert result["name"] == "User 1"
    end

    test "works with articles table" do
      Repo.insert_all("articles", [
        %{
          title: "Test Article",
          content: "This is test content",
          app_id: "blog_app",
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      ])

      sql = "SELECT title, content FROM articles WHERE app_id = $1"
      params = ["blog_app"]

      assert {:ok, [article]} = DatabaseExecutor.execute_query(sql, params)

      assert article["title"] == "Test Article"
      assert article["content"] == "This is test content"
    end

    test "works with comments table and foreign keys" do
      {_, [article]} =
        Repo.insert_all(
          "articles",
          [
            %{
              title: "Article with Comments",
              content: "Article content",
              app_id: "blog_app",
              inserted_at: DateTime.utc_now(),
              updated_at: DateTime.utc_now()
            }
          ],
          returning: [:id]
        )

      Repo.insert_all("comments", [
        %{
          content: "Great article!",
          article_id: article.id,
          app_id: "blog_app",
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      ])

      sql = "SELECT content, article_id FROM comments WHERE app_id = $1 AND article_id = $2"
      params = ["blog_app", article.id]

      assert {:ok, [comment]} = DatabaseExecutor.execute_query(sql, params)

      assert comment["content"] == "Great article!"
      assert comment["article_id"] == article.id
    end

    test "handles invalid SQL gracefully" do
      sql = "SELECT * FROM nonexistent_table"
      params = []

      assert {:error, error_message} = DatabaseExecutor.execute_query(sql, params)
      assert String.contains?(error_message, "Database error:")
    end

    test "handles invalid parameters gracefully" do
      sql = "SELECT * FROM users WHERE app_id = $1 AND id = $2"
      # Missing second parameter
      params = ["test_app"]

      assert {:error, error_message} = DatabaseExecutor.execute_query(sql, params)
      assert String.contains?(error_message, "Database error:")
    end

    test "handles SQL injection attempts safely" do
      # This should be handled safely by parameterized queries
      sql = "SELECT * FROM users WHERE app_id = $1"
      params = ["test_app'; DROP TABLE users; --"]

      # This should not cause an error, just return no results
      assert {:ok, results} = DatabaseExecutor.execute_query(sql, params)
      assert results == []
    end
  end

  describe "execute_query/2 - data isolation" do
    test "isolates data between different apps" do
      # Insert data for two different apps
      Repo.insert_all("users", [
        %{
          name: "Test App User",
          email: "test@test.com",
          app_id: "test_app",
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        },
        %{
          name: "Blog App User",
          email: "blog@blog.com",
          app_id: "blog_app",
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      ])

      # Query test_app data
      sql = "SELECT name FROM users WHERE app_id = $1"
      assert {:ok, test_results} = DatabaseExecutor.execute_query(sql, ["test_app"])
      assert length(test_results) == 1
      assert hd(test_results)["name"] == "Test App User"

      # Query blog_app data
      assert {:ok, blog_results} = DatabaseExecutor.execute_query(sql, ["blog_app"])
      assert length(blog_results) == 1
      assert hd(blog_results)["name"] == "Blog App User"

      # Verify they are different
      refute hd(test_results)["name"] == hd(blog_results)["name"]
    end
  end

  describe "execute_query/2 - integration with QueryBuilder output" do
    test "handles typical QueryBuilder SELECT output" do
      Repo.insert_all("users", [
        %{
          name: "John Doe",
          email: "john@test.com",
          app_id: "test_app",
          id: 1,
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      ])

      sql = "SELECT id, name, email FROM users WHERE app_id = $1 AND id = $2 LIMIT 1"
      params = ["test_app", 1]

      assert {:ok, [user]} = DatabaseExecutor.execute_query(sql, params)

      assert is_map(user)
      assert Map.has_key?(user, "id")
      assert Map.has_key?(user, "name")
      assert Map.has_key?(user, "email")
      assert user["name"] == "John Doe"
      assert user["email"] == "john@test.com"
    end
  end
end
