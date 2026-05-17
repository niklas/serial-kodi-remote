# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :serial_kodi_remote,
  generators: [timestamp_type: :utc_datetime]

# Configure the endpoint
config :serial_kodi_remote, SerialKodiRemoteWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: SerialKodiRemoteWeb.ErrorHTML, json: SerialKodiRemoteWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: SerialKodiRemote.PubSub,
  live_view: [signing_salt: "tdr/atED"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  serial_kodi_remote: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.12",
  serial_kodi_remote: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# third-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :serial_kodi_remote, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:serial_kodi_remote, :key)
#
# You can also configure a third-party app:
#
#     config :logger, level: :info
#
config :serial_kodi_remote,
  kodi_ws_url: "ws://login:password@kodihost:9090/jsonrpc",
  serial_port: "/dev/ttyUSB0"

config :logger, :console, format: "$time [$level] $message \n"

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
