defmodule DataApiWeb.ApiControllerTest do
  # async: false because this test uses Redis, which is shared global state
  # and can interfere with other tests that also use Redis
  use DataApiWeb.ConnCase, async: false

  alias DataApi.Repo
  alias DataApi.TestFixtures

  setup_all do
    {:ok, conn} = Redix.start_link(database: 1)
    on_exit(fn -> Redix.stop(conn) end)
    %{redis_conn: conn}
  end

  setup %{redis_conn: redis_conn} do
    # Clear Redis
    Redix.command(redis_conn, ["DEL", "config:test_app"])
    Redix.command(redis_conn, ["DEL", "config:blog_app"])

    # Store test configs in Redis
    Redix.command(redis_conn, ["SET", "config:test_app", Jason.encode!(TestFixtures.test_app_config())])
    Redix.command(redis_conn, ["SET", "config:blog_app", Jason.encode!(TestFixtures.blog_app_config())])

    # Add test data to database
    Repo.insert_all("users", [
      %{
        id: 1,
        name: "John Doe",
        email: "john@test.com",
        app_id: "test_app",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        id: 2,
        name: "Jane Smith",
        email: "jane@test.com",
        app_id: "test_app",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      }
    ])

    Repo.insert_all("articles", [
      %{
        id: 1,
        title: "First Article",
        content: "Article content",
        app_id: "blog_app",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      }
    ])

    :ok
  end

  describe "api_controller GET requests - successful scenarios" do
    test "GET /app_id/users returns all users for app", %{conn: conn} do
      conn = get(conn, "/test_app/users")

      assert json_response(conn, 200)
      results = json_response(conn, 200)
      assert length(results) == 2

      names = Enum.map(results, fn user -> user["name"] end)
      assert "John Doe" in names
      assert "Jane Smith" in names
    end

    test "GET /app_id/users/:id returns specific user", %{conn: conn} do
      conn = get(conn, "/test_app/users/1")

      user = json_response(conn, 200)
      assert is_map(user)
      assert user["id"] == 1
      assert user["name"] == "John Doe"
      assert user["email"] == "john@test.com"
    end

    test "GET with query parameters filters results", %{conn: conn} do
      conn = get(conn, "/test_app/users?name=John Doe")

      results = json_response(conn, 200)
      assert length(results) == 1

      [user] = results
      assert user["name"] == "John Doe"
    end


    test "GET returns null when no results found for single resource", %{conn: conn} do
      conn = get(conn, "/test_app/users/999")

      result = json_response(conn, 200)
      # Should return null for cardinality: "one" when not found
      assert result == nil
    end
  end

  describe "api_controller GET requests - error scenarios" do
    test "GET /unknown_app/users returns 404", %{conn: conn} do
      conn = get(conn, "/unknown_app/users")

      assert json_response(conn, 404) == %{"error" => "Application not found"}
    end

    test "GET /app_id/unknown_endpoint returns 404", %{conn: conn} do
      conn = get(conn, "/test_app/nonexistent")

      assert json_response(conn, 404) == %{"error" => "Endpoint not found"}
    end

    test "GET / (root path) returns 400", %{conn: conn} do
      conn = get(conn, "/")

      assert json_response(conn, 400) == %{"error" => "Invalid path format. Expected: /app_id/endpoint_path"}
    end

    test "GET /app_id/users/invalid_id returns 400", %{conn: conn} do
      conn = get(conn, "/test_app/users/invalid_id")

      response = json_response(conn, 400)
      assert String.contains?(response["error"], "cannot convert 'invalid_id' to integer")
    end
  end

  describe "api_controller GET requests - data isolation" do
    test "apps only see their own data", %{conn: conn} do
      # Add user with same name in different app
      Repo.insert_all("users", [
        %{
          id: 3,
          name: "Alice",
          email: "alice@blog.com",
          app_id: "blog_app",
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      ])

      # Query test_app - should not return blog_app user
      conn = get(conn, "/test_app/users")
      results = json_response(conn, 200)

      assert length(results) == 2
      names = Enum.map(results, fn user -> user["name"] end)
      refute "Alice" in names
    end
  end

  describe "api_controller GET requests - Redis configuration issues" do
    test "handles no valid configurations", %{conn: conn, redis_conn: redis_conn} do
      # Clear all configs
      Redix.command(redis_conn, ["DEL", "config:test_app"])
      Redix.command(redis_conn, ["DEL", "config:blog_app"])

      conn = get(conn, "/test_app/users")

      response = json_response(conn, 400)
      assert String.contains?(response["error"], "No valid configurations found")
    end
  end

  describe "api_controller - unsupported HTTP methods" do
    test "POST returns 405 method not allowed", %{conn: conn} do
      conn = post(conn, "/test_app/users", %{})

      assert json_response(conn, 405) == %{"error" => "Method not allowed. Only GET requests are supported."}
    end

    test "PUT returns 405 method not allowed", %{conn: conn} do
      conn = put(conn, "/test_app/users/1", %{})

      assert json_response(conn, 405) == %{"error" => "Method not allowed. Only GET requests are supported."}
    end

    test "DELETE returns 405 method not allowed", %{conn: conn} do
      conn = delete(conn, "/test_app/users/1")

      assert json_response(conn, 405) == %{"error" => "Method not allowed. Only GET requests are supported."}
    end
  end

  describe "api_controller - content type handling" do
    test "returns JSON content type", %{conn: conn} do
      conn = get(conn, "/test_app/users")

      assert response_content_type(conn, :json)
      assert json_response(conn, 200)
    end

    test "handles requests with query parameters in URL", %{conn: conn} do
      conn = get(conn, "/test_app/users?email=john@test.com")

      results = json_response(conn, 200)
      assert length(results) == 1

      [user] = results
      assert user["email"] == "john@test.com"
    end
  end
end
