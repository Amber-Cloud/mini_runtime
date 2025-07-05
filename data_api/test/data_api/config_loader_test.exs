defmodule DataApi.ConfigLoaderTest do
  use ExUnit.Case, async: true

  alias DataApi.ConfigLoader
  alias DataApi.TestFixtures

  setup_all do
    {:ok, conn} = Redix.start_link()
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
