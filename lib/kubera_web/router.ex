defmodule KuberaWeb.Router do
  use KuberaWeb, :router

  alias KuberaWeb.Plugs

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", KuberaWeb do
    pipe_through [:api, Plugs.AuthAccessPipeline]

    resources "/users", UserController, except: [:new, :edit]
    get "/profile", UserController, :show
    get "/coins", CoinController, :index
    get "/coins/:symbol/hist", CoinController, :price
  end

  scope "/api/v1/auth", KuberaWeb do
    pipe_through :api

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end
end
