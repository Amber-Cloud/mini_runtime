# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs

alias DataApi.Repo

# Clear existing data
Repo.delete_all("comments")
Repo.delete_all("articles")
Repo.delete_all("users")
Repo.delete_all("cats")

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

# Shelter app cats
Repo.insert_all("cats", [
  %{
    name: "Bambi",
    age: 5,
    breed: "Domestic Shorthair",
    color: "calico",
    gender: "female",
    adoption_status: "adopted",
    description: "Sweet calico girl, very affectionate but shy. Loves to curl up in her hammock.",
    photos: "[\"https://i.imgur.com/1bYi4Dt.jpeg\", \"https://i.imgur.com/7UYWf7r.jpeg\", \"https://i.imgur.com/KLcGTiI.jpeg\"]",
    app_id: "shelter_app",
    inserted_at: DateTime.utc_now() |> DateTime.to_iso8601(),
    updated_at: DateTime.utc_now() |> DateTime.to_iso8601()
  },
  %{
    name: "Viana",
    age: 5,
    breed: "Domestic Shorthair",
    color: "bicolor (white & grey)",
    gender: "female",
    adoption_status: "adopted",
    description: "Beautiful bicolor girl with the sweetest personality. Very cuddly and loves to play.",
    photos: "[\"https://i.imgur.com/NZKe7iq.jpeg\", \"https://i.imgur.com/endTX7n.jpeg\", \"https://i.imgur.com/Yd6SJZd.jpeg\"]",
    app_id: "shelter_app",
    inserted_at: DateTime.utc_now() |> DateTime.to_iso8601(),
    updated_at: DateTime.utc_now() |> DateTime.to_iso8601()
  },
  %{
    name: "Joep",
    age: 2,
    breed: "Domestic Shorthair",
    color: "orange",
    gender: "male",
    adoption_status: "adopted",
    description: "Playful young orange boy full of energy and love. Joepie was a stray kitten but he is now a happy indoor cat, very curious about people.",
    photos: "[\"https://i.imgur.com/5L8bKcF.jpeg\", \"https://i.imgur.com/fs7OsxU.jpeg\", \"https://i.imgur.com/PBQ8e3k.jpeg\"]",
    app_id: "shelter_app",
    inserted_at: DateTime.utc_now() |> DateTime.to_iso8601(),
    updated_at: DateTime.utc_now() |> DateTime.to_iso8601()
  },
  %{
    name: "Luna",
    age: 2,
    breed: "Domestic Shorthair",
    color: "black",
    gender: "female",
    adoption_status: "available",
    description: "Gentle black beauty who loves quiet moments and gentle pets. Perfect for a calm household.",
    photos: "[\"https://i.imgur.com/CdFVeJU.jpeg\", \"https://i.imgur.com/xDiQIyH.jpeg\"]",
    app_id: "shelter_app",
    inserted_at: DateTime.utc_now() |> DateTime.to_iso8601(),
    updated_at: DateTime.utc_now() |> DateTime.to_iso8601()
  },
  %{
    name: "Milo",
    age: 3,
    breed: "Domestic Shorthair",
    color: "grey tabby",
    gender: "male",
    adoption_status: "available",
    description: "Independent but affectionate tabby boy. Great with other cats and loves sunny windowsills.",
    photos: "[\"https://i.imgur.com/csYNeeq.jpeg\", \"https://i.imgur.com/U9BXe8f.jpeg\"]",
    app_id: "shelter_app",
    inserted_at: DateTime.utc_now() |> DateTime.to_iso8601(),
    updated_at: DateTime.utc_now() |> DateTime.to_iso8601()
  },
  %{
    name: "Bella",
    age: 1,
    breed: "Domestic Shorthair",
    color: "tortoiseshell",
    gender: "female",
    adoption_status: "reserved",
    description: "Playful young tortie with lots of personality. Loves to chase toys and cuddle up at night.",
    photos: "[\"https://i.imgur.com/VJpAt5V.jpeg\", \"https://i.imgur.com/XgaSyY5.jpeg\"]",
    app_id: "shelter_app",
    inserted_at: DateTime.utc_now() |> DateTime.to_iso8601(),
    updated_at: DateTime.utc_now() |> DateTime.to_iso8601()
  },
  %{
    name: "Piksha",
    age: 4,
    breed: "Domestic Shorthair",
    color: "brown tabby",
    gender: "female",
    adoption_status: "available",
    description: "Mature, calm girl who would love a quiet home. Great lap cat and very gentle.",
    photos: "[\"https://i.imgur.com/ch5BoKb.jpeg\", \"https://i.imgur.com/9JUOQFV.jpeg\"]",
    app_id: "shelter_app",
    inserted_at: DateTime.utc_now() |> DateTime.to_iso8601(),
    updated_at: DateTime.utc_now() |> DateTime.to_iso8601()
  },
  %{
    name: "Archie",
    age: 5,
    breed: "Domestic Shorthair",
    color: "black",
    adoption_status: "reserved",
    description: "Sweet and playful adult boy who loves to lounge and enjoys belly rubs.",
    photos: "[\"https://i.imgur.com/G2iz4cY.jpeg\", \"https://i.imgur.com/uaOjW50.jpeg\", \"https://i.imgur.com/yp4diCj.jpeg\"]",
    app_id: "shelter_app",
    inserted_at: DateTime.utc_now() |> DateTime.to_iso8601(),
    updated_at: DateTime.utc_now() |> DateTime.to_iso8601()
  }
])

IO.puts("Database seeded successfully!")
