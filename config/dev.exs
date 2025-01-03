import Config

config :serial_kodi_remote,
  transmission_rpc_url:
    System.get_env(
      "TRANSMISSION_RPC",
      "http://user:password@transmission-host:9091/transmission/rpc"
    ),
  kodi_ws_url: System.get_env("KODI_WEBSOCKET", "ws://user:password@kodihost:9090/jsonrpc"),
  serial_port: System.get_env("SERIAL_PORT", "/dev/ttyUSB0")
