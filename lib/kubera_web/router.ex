defmodule KuberaWeb.Router do
  use KuberaWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", KuberaWeb do
    pipe_through :api
  end
end
