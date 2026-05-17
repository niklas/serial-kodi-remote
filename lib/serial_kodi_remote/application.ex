defmodule SerialKodiRemote.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    all = Application.get_all_env(:serial_kodi_remote)
    children = [
      {Phoenix.PubSub, name: SerialKodiRemote.PubSub},
      {SerialKodiRemote.Delegator, []},
      {SerialKodiRemote.RetryWorker, {SerialKodiRemote.Transmission, :transmission, all[:transmission_rpc_url]}},
      {SerialKodiRemote.RetryWorker, {SerialKodiRemote.Kodi, :kodi, all[:kodi_ws_url]}},
      {SerialKodiRemote.RetryWorker, {SerialKodiRemote.Serial, :serial, all[:serial_port]}},
      SerialKodiRemoteWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:serial_kodi_remote, :dns_cluster_query) || :ignore},
      # Start a worker by calling: SerialKodiRemote.Worker.start_link(arg)
      # {SerialKodiRemote.Worker, arg},
      # Start to serve requests, typically the last entry
      SerialKodiRemoteWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SerialKodiRemote.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SerialKodiRemoteWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
