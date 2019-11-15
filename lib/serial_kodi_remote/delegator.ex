defmodule SerialKodiRemote.Delegator do
  use GenServer
  require Logger
  @registered_name __MODULE__

  alias SerialKodiRemote.Kodi
  alias SerialKodiRemote.Serial
  alias SerialKodiRemote.KodiRPC, as: RPC

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: @registered_name)
  end

  def from_kodi(method, params) do
    GenServer.cast(@registered_name, {:from_kodi, method, params})
  end

  def from_serial(what) do
    GenServer.cast(@registered_name, what)
  end

  def prep_stop() do
    GenServer.cast(@registered_name, :prep_stop)
  end

  # End of public API ----------

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:from_kodi, method, params}, state) do
    handle_kodi(method, params, state)
  end

  def handle_cast({:remote_key, key}, state) do
    frame =
      case key do
        "v" -> RPC.volume_down()
        "V" -> RPC.volume_up()
        "m" -> RPC.mute()
        "p" -> RPC.pause()
        "C" -> RPC.up()
        "c" -> RPC.down()
        "O" -> RPC.select()
        "b" -> RPC.back()
        "i" -> RPC.info()
        _ -> false
      end

    Kodi.send_frame(frame)
    {:noreply, state}
  end

  def handle_cast(:prep_stop, state) do
    Serial.send_out("U")
    {:noreply, state}
  end

  # PRIVATE --------------------

  defp handle_kodi("Player.OnPause", _params, state) do
    Logger.debug(fn -> "paused" end)
    Serial.send_out("d")
    {:noreply, state}
  end

  defp handle_kodi("Player.OnResume", _params, state) do
    Logger.debug(fn -> "unpaused" end)
    Serial.send_out("D")
    {:noreply, state}
  end

  defp handle_kodi(
         "Application.OnVolumeChanged",
         %{"data" => %{"muted" => true}},
         state
       ) do
    Logger.debug(fn -> "muted" end)
    {:noreply, state}
  end

  defp handle_kodi(
         "Application.OnVolumeChanged",
         %{"data" => %{"muted" => false}},
         state
       ) do
    Logger.debug(fn -> "unmuted" end)
    {:noreply, state}
  end

  defp handle_kodi("GUI.OnScreensaverActivated", _params, state) do
    Logger.debug(fn -> "Screensaver activated" end)
    {:noreply, state}
  end

  defp handle_kodi("GUI.OnScreensaverDeactivated", _params, state) do
    Logger.debug(fn -> "Screensaver deactivated" end)
    {:noreply, state}
  end

  defp handle_kodi(method, params, state) do
    Logger.debug(fn -> "Received #{method} #{inspect(params)}" end)
    {:noreply, state}
  end
end
