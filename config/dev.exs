import Config

config :serial_kodi_remote,
  kodi_ws_url: System.get_env("KODI_WEBSOCKET", "ws://user:password@kodihost:9090/jsonrpc"),
  serial_port: System.get_env("SERIAL_PORT", "/dev/ttyUSB0")
