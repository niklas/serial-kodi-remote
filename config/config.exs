# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
import Config

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
if Mix.env() != :prod do
  import_config "#{Mix.env()}.exs"
end
