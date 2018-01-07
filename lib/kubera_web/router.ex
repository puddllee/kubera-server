defmodule KuberaWeb.Router do
  use KuberaWeb, :router

  import KuberaWeb.Plugs.UserPlug

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.EnsureAuthenticated, handler: KuberaWeb.AuthController
    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureResource, handler: KuberaWeb.AuthController
    plug :load_user
  end

  scope "/api/v1", KuberaWeb do
    pipe_through :api_auth

    resources "/users", UserController, except: [:new, :edit]
    get "/coins", CoinController, :index
  end

  scope "/api/v1/auth", KuberaWeb do
    pipe_through :api

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end
end
