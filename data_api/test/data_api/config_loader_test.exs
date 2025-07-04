defmodule DataApi.ConfigLoaderTest do
  use ExUnit.Case, async: true

  alias DataApi.ConfigLoader

  setup_all do
    {:ok, conn} = Redix.start_link()
    on_exit(fn -> Redix.stop(conn) end)
    %{conn: conn}
  end

  setup %{conn: conn} do
    Redix.command(conn, ["DEL", "config:test_app"])
    Redix.command(conn, ["DEL", "config:blog_app"])

    # Store test configs in Redis
    Redix.command(conn, ["SET", "config:test_app", Jason.encode!(app_config_1())])
    Redix.command(conn, ["SET", "config:blog_app", Jason.encode!(app_config_2())])

    :ok
  end

  # Test data fixtures (copied from DataCompiler tests)
  defp app_config_1 do
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
            %{"name" => "content", "type" => "text"},
            %{"name" => "user_id", "type" => "integer"}
          ]
        }
      }
    }
  end

  defp app_config_2 do
    %{
      "app_id" => "blog_app",
      "endpoints" => [
        %{
          "path" => "/articles",
          "method" => "GET",
          "table" => "articles",
          "cardinality" => "many",
          "app_id" => "blog_app",
          "key" => "GET_blog_app_articles_many"
        }
      ],
      "tables" => %{
        "articles" => %{
          "name" => "articles",
          "columns" => [
            %{"name" => "id", "type" => "integer"},
            %{"name" => "title", "type" => "string"}
          ]
        }
      }
    }
  end

  describe "load_all_configs/0" do
    test "loads multiple valid configurations" do
      {:ok, configs} = ConfigLoader.load_all_configs()

      assert length(configs) == 2

      # Find configs by app_id
      test_app_config = Enum.find(configs, fn config -> config["app_id"] == "test_app" end)
      blog_app_config = Enum.find(configs, fn config -> config["app_id"] == "blog_app" end)

      assert test_app_config == app_config_1()
      assert blog_app_config == app_config_2()
    end

    test "loads single configuration when only one exists", %{conn: conn} do
      # Remove one config
      Redix.command(conn, ["DEL", "config:blog_app"])

      {:ok, configs} = ConfigLoader.load_all_configs()

      assert length(configs) == 1
      assert hd(configs)["app_id"] == "test_app"
    end

    test "handles mix of valid and invalid configs", %{conn: conn} do
      # Add configs with invalid JSON and invalid structure
      Redix.command(conn, ["SET", "config:invalid_app", "{broken json"])
      Redix.command(conn, ["SET", "config:empty_app", "{}"])

      {:ok, configs} = ConfigLoader.load_all_configs()

      # Should return only the 2 valid configs
      assert length(configs) == 2
      app_ids = Enum.map(configs, fn config -> config["app_id"] end)
      assert "test_app" in app_ids
      assert "blog_app" in app_ids
      refute "invalid_app" in app_ids
      refute Enum.any?(configs, fn config -> config == %{} end)
    end

    test "returns error when no configs exist", %{conn: conn} do
      # Remove all configs
      Redix.command(conn, ["DEL", "config:test_app"])
      Redix.command(conn, ["DEL", "config:blog_app"])

      assert {:error, "No valid configurations found"} = ConfigLoader.load_all_configs()
    end

    test "returns error when all configs are invalid", %{conn: conn} do
      Redix.command(conn, ["SET", "config:test_app", "{broken json"])
      Redix.command(conn, ["SET", "config:blog_app", "{}"])

      assert {:error, "No valid configurations found"} = ConfigLoader.load_all_configs()
    end
  end
end
