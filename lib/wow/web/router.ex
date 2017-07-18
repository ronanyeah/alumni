defmodule Wow.Web.Router do
  use Wow.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Wow.Web do
    pipe_through :api
  end
end
