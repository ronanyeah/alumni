defmodule AlumniWeb.Router do
  use AlumniWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", AlumniWeb do
    pipe_through :api
  end

  forward "/graph", Absinthe.Plug,
    schema: Alumni.Schema

  forward "/graphiql", Absinthe.Plug.GraphiQL,
    schema: Alumni.Schema
end
