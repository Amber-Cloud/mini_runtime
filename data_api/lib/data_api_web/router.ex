defmodule DataApiWeb.Router do
  use DataApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Main API routes - handles all requests based on Redis configurations
  scope "/", DataApiWeb do
    pipe_through :api

    get "/*path", ApiController, :handle_request
    post "/*path", ApiController, :method_not_allowed
    put "/*path", ApiController, :method_not_allowed
    patch "/*path", ApiController, :method_not_allowed
    delete "/*path", ApiController, :method_not_allowed
  end
end
