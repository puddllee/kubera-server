# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :kubera,
  ecto_repos: [Kubera.Repo]

# Configures the endpoint
config :kubera, KuberaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "fbwTnJwfyPKDOlZ3roJxD+4wY4DNSORwHvhX/LfQP5CG8dylS5cU6FJnk6MXVj5M",
  render_errors: [view: KuberaWeb.ErrorView, accepts: ~w(json html)],
  pubsub: [name: Kubera.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :kubera, Kubera.Crypto.Scheduler,
  jobs: [
    {"*/15 * * * *", {Kubera.Crypto, :save_coinlist, []}}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ueberauth, Ueberauth,
  base_path: "/api/v1/auth",
  providers: [
    google: {Ueberauth.Strategy.Google, [
                default_scope: "email profile",
                callback_url: System.get_env("GOOGLE_CALLBACK_URL")
              ]}
  ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
  redirect_uri: System.get_env("GOOGLE_CALLBACK_URL"),
  callback_url: System.get_env("GOOGLE_CALLBACK_URL")

config :kubera, Kubera.Guardian,
  allowed_algos: ["HS512"],
  verify_module: Guardian.JWT,
  issuer: "Kubera",
  ttl: {30, :days},
  allowed_drift: 2000,
  verify_issuer: true,
  secret_key: System.get_env("GUARDIAN_SECRET") || "rFtDNsugNi8jNJLOfvcN4jVyS/V7Sh+9pBtc/J30W8h4MYTcbiLYf/8CEVfdgU6/",
  serializer: Kubera.Guardian


config :kubera, KuberaWeb.Plugs.AuthAccessPipeline,
  module: Kubera.Guardian,
  error_handler: KuberaWeb.AuthController

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
