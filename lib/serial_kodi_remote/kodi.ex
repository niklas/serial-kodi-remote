defmodule SerialKodiRemote.Kodi do
  use GenServer
  require Logger

  @registered_name __MODULE__

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: @registered_name)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:remote_key, key}, state) do
    Logger.debug("Kodi: #{key}")
    {:noreply, state}
  end
end
