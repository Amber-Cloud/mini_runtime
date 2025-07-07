defmodule DataApi.TestFixtures do
  @moduledoc """
  Shared test fixtures for DataAPI tests.

  Contains realistic config data that matches what DataCompiler
  would generate and ConfigLoader would return.
  """

  @doc """
  Returns individual app config for test_app.
  Used by ConfigLoader tests.
  """
  def test_app_config do
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
          "path" => "/users",
          "method" => "POST",
          "table" => "users",
          "cardinality" => "one",
          "app_id" => "test_app",
          "key" => "POST_test_app_users_one"
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
        }
      }
    }
  end

  @doc """
  Returns individual app config for blog_app.
  Used by ConfigLoader tests.
  """
  def blog_app_config do
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
        },
        %{
          "path" => "/articles/:id/comments",
          "method" => "GET",
          "table" => "comments",
          "cardinality" => "many",
          "app_id" => "blog_app",
          "key" => "GET_blog_app_articles_id_comments_many"
        },
        %{
          "path" => "/articles/:article_id/comments/:comment_id",
          "method" => "DELETE",
          "table" => "comments",
          "cardinality" => "one",
          "app_id" => "blog_app",
          "key" => "DELETE_blog_app_articles_article_id_comments_comment_id_one"
        }
      ],
      "tables" => %{
        "articles" => %{
          "name" => "articles",
          "columns" => [
            %{"name" => "id", "type" => "integer"},
            %{"name" => "title", "type" => "string"},
            %{"name" => "content", "type" => "text"}
          ]
        },
        "comments" => %{
          "name" => "comments",
          "columns" => [
            %{"name" => "id", "type" => "integer"},
            %{"name" => "content", "type" => "text"},
            %{"name" => "article_id", "type" => "integer"}
          ]
        }
      }
    }
  end

  @doc """
  Returns list of all app configs.
  Used by EndpointMatcher, QueryBuilder, etc. tests.
  """
  def all_app_configs do
    [test_app_config(), blog_app_config()]
  end
end
