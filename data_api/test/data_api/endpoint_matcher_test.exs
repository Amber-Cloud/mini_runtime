defmodule DataApi.EndpointMatcherTest do
  use ExUnit.Case, async: true

  alias DataApi.EndpointMatcher
  alias DataApi.TestFixtures

  describe "match_endpoint/3 - successful matches" do
    test "matches exact path with no parameters" do
      configs = TestFixtures.all_app_configs()

      assert {:ok, {endpoint, table_config, path_params}} =
               EndpointMatcher.match_endpoint(configs, "GET", "/test_app/users")

      assert endpoint["path"] == "/users"
      assert endpoint["method"] == "GET"
      assert endpoint["app_id"] == "test_app"
      assert table_config["name"] == "users"
      assert path_params == %{}
    end

    test "matches path with a single parameter" do
      configs = TestFixtures.all_app_configs()

      assert {:ok, {endpoint, table_config, path_params}} =
               EndpointMatcher.match_endpoint(configs, "GET", "/test_app/users/123")

      assert endpoint["path"] == "/users/:id"
      assert endpoint["method"] == "GET"
      assert table_config["name"] == "users"
      assert path_params == %{"id" => "123"}
    end

    test "matches path with multiple parameters" do
      configs = TestFixtures.all_app_configs()

      assert {:ok, {endpoint, table_config, path_params}} =
               EndpointMatcher.match_endpoint(
                 configs,
                 "DELETE",
                 "/blog_app/articles/456/comments/789"
               )

      assert endpoint["path"] == "/articles/:article_id/comments/:comment_id"
      assert endpoint["method"] == "DELETE"
      assert endpoint["app_id"] == "blog_app"
      assert table_config["name"] == "comments"
      assert path_params == %{"article_id" => "456", "comment_id" => "789"}
    end

    test "matches different HTTP methods on same path" do
      configs = TestFixtures.all_app_configs()

      # GET /test_app/users
      assert {:ok, {get_endpoint, _, _}} =
               EndpointMatcher.match_endpoint(configs, "GET", "/test_app/users")

      assert get_endpoint["method"] == "GET"
      assert get_endpoint["cardinality"] == "many"

      # POST /test_app/users
      assert {:ok, {post_endpoint, _, _}} =
               EndpointMatcher.match_endpoint(configs, "POST", "/test_app/users")

      assert post_endpoint["method"] == "POST"
      assert post_endpoint["cardinality"] == "one"
    end

    test "normalizes HTTP method case" do
      configs = TestFixtures.all_app_configs()

      # Test lowercase
      assert {:ok, {endpoint, _, _}} =
               EndpointMatcher.match_endpoint(configs, "get", "/test_app/users")

      assert endpoint["method"] == "GET"

      # Test mixed case
      assert {:ok, {endpoint, _, _}} =
               EndpointMatcher.match_endpoint(configs, "Post", "/test_app/users")

      assert endpoint["method"] == "POST"
    end
  end

  describe "match_endpoint/3 - no matches found" do
    test "returns error for non-existent app" do
      configs = TestFixtures.all_app_configs()

      assert {:error, :app_not_found} =
               EndpointMatcher.match_endpoint(configs, "GET", "/unknown_app/users")
    end

    test "returns error for non-existent path" do
      configs = TestFixtures.all_app_configs()

      assert {:error, :endpoint_not_found} =
               EndpointMatcher.match_endpoint(configs, "GET", "/test_app/nonexistent")
    end

    test "returns error for wrong HTTP method" do
      configs = TestFixtures.all_app_configs()

      assert {:error, :endpoint_not_found} =
               EndpointMatcher.match_endpoint(configs, "PUT", "/test_app/users")
    end

    test "returns error for wrong number of path segments" do
      configs = TestFixtures.all_app_configs()

      # Too many segments for any endpoint
      assert {:error, :endpoint_not_found} =
               EndpointMatcher.match_endpoint(configs, "GET", "/test_app/users/123/extra")
    end

    test "returns error when no configs provided" do
      assert {:error, :app_not_found} =
               EndpointMatcher.match_endpoint([], "GET", "/test_app/users")
    end

    test "returns error for invalid path format" do
      configs = TestFixtures.all_app_configs()

      assert {:error, :invalid_path} =
               EndpointMatcher.match_endpoint(configs, "GET", "/")
    end
  end

  describe "match_endpoint/3 - edge cases" do
    test "handles path normalization correctly" do
      configs = TestFixtures.all_app_configs()

      # Trailing slash should be normalized away
      assert {:ok, {endpoint1, _, params1}} =
               EndpointMatcher.match_endpoint(configs, "GET", "/test_app/users")

      assert {:ok, {endpoint2, _, params2}} =
               EndpointMatcher.match_endpoint(configs, "GET", "/test_app/users/")

      # Should match the same endpoint
      assert endpoint1["path"] == endpoint2["path"]
      assert params1 == params2

      # Same with parameterized paths
      assert {:ok, {_, _, params3}} =
               EndpointMatcher.match_endpoint(configs, "GET", "/test_app/users/123")

      assert {:ok, {_, _, params4}} =
               EndpointMatcher.match_endpoint(configs, "GET", "/test_app/users/123/")

      assert params3 == params4
      assert params3 == %{"id" => "123"}
    end

    test "handles path parameters with special characters" do
      configs = TestFixtures.all_app_configs()

      assert {:ok, {_, _, path_params}} =
               EndpointMatcher.match_endpoint(configs, "GET", "/test_app/users/user-123_test")

      assert path_params == %{"id" => "user-123_test"}
    end

    test "handles numeric path parameters" do
      configs = TestFixtures.all_app_configs()

      assert {:ok, {_, _, path_params}} =
               EndpointMatcher.match_endpoint(configs, "GET", "/test_app/users/42")

      assert path_params == %{"id" => "42"}
    end
  end

  describe "match_endpoint/3 - configuration errors" do
    test "skips endpoints with missing table configuration" do
      broken_configs = [
        %{
          "app_id" => "broken_app",
          "endpoints" => [
            %{
              "path" => "/broken",
              "method" => "GET",
              "table" => "nonexistent_table",
              "app_id" => "broken_app"
            }
          ],
          "tables" => %{}
        }
      ]

      assert {:error, :endpoint_not_found} =
               EndpointMatcher.match_endpoint(broken_configs, "GET", "/broken_app/broken")
    end

    test "skips endpoints with missing app configuration" do
      broken_configs = [
        %{
          "app_id" => "test_app",
          "endpoints" => [
            %{
              "path" => "/test",
              "method" => "GET",
              "table" => "test_table",
              # references different app
              "app_id" => "different_app"
            }
          ],
          "tables" => %{
            "test_table" => %{"name" => "test_table", "columns" => []}
          }
        }
      ]

      assert {:error, :endpoint_not_found} =
               EndpointMatcher.match_endpoint(broken_configs, "GET", "/test_app/test")
    end
  end

  describe "match_endpoint/3 - multiple apps" do
    test "finds endpoint in specific app" do
      configs = TestFixtures.all_app_configs()

      assert {:ok, {endpoint1, _, _}} =
               EndpointMatcher.match_endpoint(configs, "GET", "/test_app/users")

      assert endpoint1["app_id"] == "test_app"

      assert {:ok, {endpoint2, _, _}} =
               EndpointMatcher.match_endpoint(configs, "GET", "/blog_app/articles/123/comments")

      assert endpoint2["app_id"] == "blog_app"
    end

    test "prevents cross-app access" do
      configs = TestFixtures.all_app_configs()

      # Cannot access blog_app endpoints via test_app
      assert {:error, :endpoint_not_found} =
               EndpointMatcher.match_endpoint(configs, "GET", "/test_app/articles")

      # Cannot access test_app endpoints via blog_app
      assert {:error, :endpoint_not_found} =
               EndpointMatcher.match_endpoint(configs, "GET", "/blog_app/users")
    end

    test "handles apps with same endpoint paths separately" do
      duplicate_configs = [
        %{
          "app_id" => "app1",
          "endpoints" => [
            %{
              "path" => "/duplicate",
              "method" => "GET",
              "table" => "table1",
              "app_id" => "app1"
            }
          ],
          "tables" => %{
            "table1" => %{"name" => "table1", "columns" => []}
          }
        },
        %{
          "app_id" => "app2",
          "endpoints" => [
            %{
              "path" => "/duplicate",
              "method" => "GET",
              "table" => "table2",
              "app_id" => "app2"
            }
          ],
          "tables" => %{
            "table2" => %{"name" => "table2", "columns" => []}
          }
        }
      ]

      # Access app1's endpoint
      assert {:ok, {endpoint1, table_config1, _}} =
               EndpointMatcher.match_endpoint(duplicate_configs, "GET", "/app1/duplicate")

      assert endpoint1["app_id"] == "app1"
      assert table_config1["name"] == "table1"

      # Access app2's endpoint
      assert {:ok, {endpoint2, table_config2, _}} =
               EndpointMatcher.match_endpoint(duplicate_configs, "GET", "/app2/duplicate")

      assert endpoint2["app_id"] == "app2"
      assert table_config2["name"] == "table2"
    end
  end
end
