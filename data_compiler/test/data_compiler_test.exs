defmodule DataCompilerTest do
  use ExUnit.Case
  doctest DataCompiler

  # Start a redis connection for testing
  setup_all do
    {:ok, conn} = Redix.start_link()
    on_exit(fn -> Redix.stop(conn) end)
    %{conn: conn}
  end

  # Clean up Redis before each test
  setup %{conn: conn} do
    Redix.command(conn, ["DEL", "config:test_app"])
    Redix.command(conn, ["DEL", "config:blog_app"])
    :ok
  end

  # Test data fixtures
  defp valid_input_map do
    %{
      "app_id" => "test_app",
      "endpoints" => [
        %{
          "path" => "/users",
          "method" => "GET",
          "table" => "users",
          "cardinality" => "many"
        },
        %{
          "path" => "/users/:id",
          "method" => "GET",
          "table" => "users",
          "cardinality" => "one"
        },
        %{
          "path" => "/posts",
          "method" => "POST",
          "table" => "posts",
          "cardinality" => "one"
        }
      ],
      "tables" => %{
        "users" => %{
          "name" => "users",
          "columns" => [
            %{"name" => "id", "type" => "integer"},
            %{"name" => "name", "type" => "string"},
            %{"name" => "email", "type" => "string"}
          ]
        },
        "posts" => %{
          "name" => "posts",
          "columns" => [
            %{"name" => "id", "type" => "integer"},
            %{"name" => "title", "type" => "string"},
            %{"name" => "content", "type" => "string"},
            %{"name" => "user_id", "type" => "integer"}
          ]
        }
      }
    }
  end

  defp valid_input_json do
    valid_input_map() |> Jason.encode!()
  end

  defp expected_compiled_output do
    %{
      "app_id" => "test_app",
      "endpoints" => [
        %{
          "path" => "/users",
          "method" => "GET",
          "table" => "users",
          "cardinality" => "many",
          "app_id" => "test_app",
          "key" => "GET_test_app_users_many"
        },
        %{
          "path" => "/users/:id",
          "method" => "GET",
          "table" => "users",
          "cardinality" => "one",
          "app_id" => "test_app",
          "key" => "GET_test_app_users_id_one"
        },
        %{
          "path" => "/posts",
          "method" => "POST",
          "table" => "posts",
          "cardinality" => "one",
          "app_id" => "test_app",
          "key" => "POST_test_app_posts_one"
        }
      ],
      "tables" => %{
        "users" => %{
          "name" => "users",
          "columns" => [
            %{"name" => "id", "type" => "integer"},
            %{"name" => "name", "type" => "string"},
            %{"name" => "email", "type" => "string"}
          ]
        },
        "posts" => %{
          "name" => "posts",
          "columns" => [
            %{"name" => "id", "type" => "integer"},
            %{"name" => "title", "type" => "string"},
            %{"name" => "content", "type" => "string"},
            %{"name" => "user_id", "type" => "integer"}
          ]
        }
      }
    }
  end

  defp invalid_input_missing_fields do
    %{
      "app_id" => "test_app",
      "endpoints" => []
    }
  end

  defp invalid_json_string do
    "{invalid json syntax"
  end

  describe "process_input/1 with JSON strings" do
    test "handles valid JSON string" do
      result = DataCompiler.process_input(valid_input_json())
      assert {:ok, compiled} = result
      assert compiled == expected_compiled_output()
    end

    test "invalid JSON string returns an error" do
      result = DataCompiler.process_input(invalid_json_string())
      assert {:error, error_msg} = result
      assert String.contains?(error_msg, "Invalid JSON")
    end
  end

  describe "process_input/1 with maps" do
    test "handles valid map" do
      result = DataCompiler.process_input(valid_input_map())
      assert {:ok, compiled} = result
      assert compiled == expected_compiled_output()
    end

    test "invalid map structure returns an error" do
      result = DataCompiler.process_input(invalid_input_missing_fields())
      assert {:error, "Invalid input format"} = result
    end

    test "empty map returns an error" do
      result = DataCompiler.process_input(%{})
      assert {:error, "Invalid input format"} = result
    end
  end

  describe "endpoint key generation" do
    test "generates keys for complex paths" do
      input = %{
        "app_id" => "blog_app",
        "endpoints" => [
          %{
            "path" => "/api/v1/users/:id/posts",
            "method" => "GET",
            "table" => "posts",
            "cardinality" => "many"
          }
        ],
        "tables" => %{
          "posts" => %{
            "name" => "posts",
            "columns" => [%{"name" => "id", "type" => "integer"}]
          }
        }
      }

      {:ok, compiled} = DataCompiler.process_input(input)
      [endpoint] = compiled["endpoints"]
      assert endpoint["key"] == "GET_blog_app_api_v1_users_id_posts_many"
      assert endpoint["app_id"] == "blog_app"
    end
  end

  describe "Redis integration" do
    test "stores and retrieves data", %{conn: conn} do
      {:ok, compiled} = DataCompiler.process_input(valid_input_map())

      # Check data was stored in Redis
      {:ok, stored_data} = Redix.command(conn, ["GET", "config:test_app"])
      assert stored_data != nil

      # Verify stored data matches compiled output
      {:ok, decoded} = Jason.decode(stored_data)
      assert decoded == compiled
    end
  end

  describe "edge cases and error handling" do
    test "raises on nil input" do
      assert_raise FunctionClauseError, fn ->
        DataCompiler.process_input(nil)
      end
    end

    test "rejects empty endpoints array" do
      input = %{
        "app_id" => "test_app",
        "endpoints" => [],
        "tables" => %{
          "users" => %{
            "name" => "users",
            "columns" => [%{"name" => "id", "type" => "integer"}]
          }
        }
      }

      result = DataCompiler.process_input(input)
      assert {:error, "No endpoints provided"} = result
    end

    test "rejects empty tables object" do
      input = %{
        "app_id" => "test_app",
        "endpoints" => [
          %{
            "path" => "/test",
            "method" => "GET",
            "table" => "test",
            "cardinality" => "one"
          }
        ],
        "tables" => %{}
      }

      result = DataCompiler.process_input(input)
      assert {:error, "No tables defined"} = result
    end
  end

  describe "column type validation" do
    test "accepts valid column types (integer and string)" do
      input = %{
        "app_id" => "test_app",
        "endpoints" => [
          %{
            "path" => "/users",
            "method" => "GET",
            "table" => "users",
            "cardinality" => "many"
          }
        ],
        "tables" => %{
          "users" => %{
            "name" => "users",
            "columns" => [
              %{"name" => "id", "type" => "integer"},
              %{"name" => "name", "type" => "string"}
            ]
          }
        }
      }

      result = DataCompiler.process_input(input)
      assert {:ok, _compiled} = result
    end

    test "rejects invalid column types and includes table name in error" do
      input = %{
        "app_id" => "test_app",
        "endpoints" => [
          %{
            "path" => "/products",
            "method" => "GET",
            "table" => "products",
            "cardinality" => "many"
          }
        ],
        "tables" => %{
          "products" => %{
            "name" => "products",
            "columns" => [
              %{"name" => "id", "type" => "integer"},
              %{"name" => "price", "type" => "float"}
            ]
          }
        }
      }

      result = DataCompiler.process_input(input)
      assert {:error, error_msg} = result
      assert String.contains?(error_msg, "Table 'products':")
      assert String.contains?(error_msg, "Invalid column type 'float'")
      assert String.contains?(error_msg, "column 'price'")
      assert String.contains?(error_msg, "Supported types: integer, string")
    end

    test "rejects when columns is not a list" do
      input = %{
        "app_id" => "test_app",
        "endpoints" => [
          %{
            "path" => "/test",
            "method" => "GET",
            "table" => "test",
            "cardinality" => "one"
          }
        ],
        "tables" => %{
          "test" => %{
            "name" => "test",
            "columns" => "not_a_list"
          }
        }
      }

      result = DataCompiler.process_input(input)
      assert {:error, error_msg} = result
      assert String.contains?(error_msg, "Columns must be a list")
    end
  end
end
