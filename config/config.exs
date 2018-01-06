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
  render_errors: [view: KuberaWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Kubera.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
