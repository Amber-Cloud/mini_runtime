defmodule DataApi do
  @moduledoc """
  Dynamic API system that serves database content based on Redis-stored configurations.

  DataApi reads compiled application configurations from Redis and dynamically
  serves API endpoints that query database tables according to the configuration.
  It supports multiple applications with different endpoint and table schemas.

  ## Main Components
  - `ConfigLoader` - Loads compiled configurations from Redis
  - `EndpointMatcher` - Matches incoming requests to configured endpoints
  - `QueryBuilder` - Builds SQL queries based on endpoint configuration
  - `DatabaseExecutor` - Executes queries and returns formatted results

  ## Usage
  The API accepts requests in the format: `/app_id/endpoint_path`
  Example: `GET /shelter_app/cats` returns all cats from the shelter application
  """
end
