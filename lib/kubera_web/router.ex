defmodule KuberaWeb.Router do
  use KuberaWeb, :router

  alias KuberaWeb.Plugs

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", KuberaWeb do
    pipe_through [:api]

    get "/coins", CoinController, :index
    get "/coins/history/:freq/:symbol", CoinController, :price
    get "/coins/sparklines", CoinController, :sparklines
    get "/coins/:symbol", CoinController, :show
  end

  scope "/api/v1", KuberaWeb do
    pipe_through [:api, Plugs.AuthAccessPipeline]

    get "/profile", UserController, :show
    resources "/users", UserController, except: [:new, :edit, :show]

    resources "/groups", GroupController, except: [:new, :edit]
    post "/groups/:uid/join", GroupController, :join
  end

  scope "/api/v1/auth", KuberaWeb do
    pipe_through :api

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end
end
