defmodule DataApi.ConfigLoaderTest do
  # async: false because this test uses Redis, which is shared global state
  # and can interfere with other tests that also use Redis
  use ExUnit.Case, async: false

  alias DataApi.ConfigLoader
  alias DataApi.TestFixtures

  setup_all do
    # Use Redis database 1 for tests to avoid conflicts with development data
    {:ok, conn} = Redix.start_link(database: 1)
    on_exit(fn -> Redix.stop(conn) end)
    %{conn: conn}
  end

  setup %{conn: conn} do
    Redix.command(conn, ["DEL", "config:test_app"])
    Redix.command(conn, ["DEL", "config:blog_app"])

    # Store test configs in Redis
    Redix.command(conn, ["SET", "config:test_app", Jason.encode!(TestFixtures.test_app_config())])
    Redix.command(conn, ["SET", "config:blog_app", Jason.encode!(TestFixtures.blog_app_config())])

    :ok
  end

  describe "load_all_configs/0" do
    test "loads multiple valid configurations" do
      {:ok, configs} = ConfigLoader.load_all_configs()

      assert length(configs) == 2

      # Find configs by app_id
      test_app_config = Enum.find(configs, fn config -> config["app_id"] == "test_app" end)
      blog_app_config = Enum.find(configs, fn config -> config["app_id"] == "blog_app" end)

      assert test_app_config == TestFixtures.test_app_config()
      assert blog_app_config == TestFixtures.blog_app_config()
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

      {:ok, keys} = Redix.command(conn, ["KEYS", "config:*"])
      IO.inspect(keys, label: "Redis keys")

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

    test "rejects configs with invalid column types", %{conn: conn} do
      invalid_config = %{
        "app_id" => "invalid_types_app",
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
              %{"name" => "price", "type" => "float"},
              %{"name" => "name", "type" => "string"}
            ]
          }
        }
      }

      Redix.command(conn, ["SET", "config:invalid_types_app", Jason.encode!(invalid_config)])

      {:ok, configs} = ConfigLoader.load_all_configs()

      # Should only return the 2 valid configs, not the invalid one
      assert length(configs) == 2
      app_ids = Enum.map(configs, fn config -> config["app_id"] end)
      refute "invalid_types_app" in app_ids
    end
  end
end
