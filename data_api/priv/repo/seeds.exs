# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs

alias DataApi.Repo

# Clear existing data
Repo.delete_all("comments")
Repo.delete_all("articles")
Repo.delete_all("users")

# Test app users
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

# Blog app users
Repo.insert_all("users", [
  %{
    name: "Alice Writer",
    email: "alice@blog.com",
    app_id: "blog_app",
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  }
])

# Blog app articles
{_, [article1]} =
  Repo.insert_all(
    "articles",
    [
      %{
        title: "First Article",
        content: "This is the first article content.",
        app_id: "blog_app",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      }
    ],
    returning: [:id]
  )

{_, [article2]} =
  Repo.insert_all(
    "articles",
    [
      %{
        title: "Second Article",
        content: "This is the second article content.",
        app_id: "blog_app",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      }
    ],
    returning: [:id]
  )

# Blog app comments
Repo.insert_all("comments", [
  %{
    content: "Great article!",
    article_id: article1.id,
    app_id: "blog_app",
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  },
  %{
    content: "Thanks for sharing!",
    article_id: article1.id,
    app_id: "blog_app",
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  },
  %{
    content: "Looking forward to more!",
    article_id: article2.id,
    app_id: "blog_app",
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  }
])

IO.puts("Database seeded successfully!")
