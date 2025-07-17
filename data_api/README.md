# DataApi

Dynamic API system that serves database content based on Redis-stored configurations.

## Overview

DataApi is a Phoenix application that dynamically generates API endpoints based on configurations stored in Redis. It supports multiple applications with different database schemas and endpoint configurations.

## Architecture

- **ConfigLoader**: Loads compiled application configurations from Redis
- **EndpointMatcher**: Matches incoming HTTP requests to configured endpoints
- **QueryBuilder**: Builds SQL queries based on endpoint configuration and request parameters
- **DatabaseExecutor**: Executes queries and returns formatted JSON responses

## API Usage

The API accepts requests in the format: `/app_id/endpoint_path`

Examples:

- `GET /shelter_app/cats` - Returns all cats from the shelter application
- `GET /blog_app/articles` - Returns all articles from the blog application

## Local Development

```bash
# Install dependencies
mix deps.get

# Set up database
mix ecto.setup

# Seed database (optional)
mix run priv/repo/seeds.exs

# Start server
mix phx.server
```

The API will be available at `http://localhost:4000`

## Configuration

Application configurations are compiled by the DataCompiler service and stored in Redis. The DataApi reads these configurations to determine available endpoints and database schemas.

## Testing

mix test
