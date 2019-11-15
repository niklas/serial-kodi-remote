defmodule SerialKodiRemote.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__.Supervisor)
  end

  def init(_) do
    all = Application.get_all_env(:serial_kodi_remote)

    # List all child processes to be supervised
    children = [
      {SerialKodiRemote.Delegator, []},
      {SerialKodiRemote.Kodi, all[:kodi_ws_url]},
      {SerialKodiRemote.Serial, all[:serial_port]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end

  def prep_stop(state) do
    SerialKodiRemote.Delegator.prep_stop()
    Process.sleep(100)
    state
  end
end
