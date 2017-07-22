defmodule Wow.Web.Router do
  use Wow.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Wow.Web do
    pipe_through :api
  end

  forward "/graph", Absinthe.Plug,
    schema: Wow.Schema

  forward "/graphiql", Absinthe.Plug.GraphiQL,
    schema: Wow.Schema
end
