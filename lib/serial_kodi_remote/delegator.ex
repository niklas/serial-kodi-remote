defmodule SerialKodiRemote.Delegator do
  use GenServer
  require Logger
  @registered_name __MODULE__

  alias SerialKodiRemote.Kodi
  alias SerialKodiRemote.Serial
  alias SerialKodiRemote.KodiRPC, as: RPC

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{playing: false}, name: @registered_name)
  end

  def from_kodi(method, params) do
    GenServer.cast(@registered_name, {:from_kodi, method, params})
  end

  def from_serial(what) do
    GenServer.cast(@registered_name, {:from_serial, what})
  end

  # End of public API ----------

  def init(state) do
    Process.flag(:trap_exit, true)
    {:ok, state}
  end

  def handle_cast({:from_kodi, method, params}, state) do
    handle_kodi(method, params, state)
  end

  def handle_cast({:from_serial, {:remote_key, key}}, %{playing: playing} = state) do
    frame =
      case key do
        "v" ->
          RPC.volume_down()

        "V" ->
          RPC.volume_up()

        "m" ->
          RPC.mute()

        "p" ->
          RPC.pause()

        "C" ->
          RPC.up()

        "c" ->
          RPC.down()

        "r" ->
          if playing do
            RPC.seek_right()
          else
            RPC.right()
          end

        "l" ->
          if playing do
            RPC.seek_left()
          else
            RPC.left()
          end

        "O" ->
          RPC.select()

        "b" ->
          RPC.back()

        "i" ->
          RPC.info()

        "t" ->
          RPC.subtitle()

        _ ->
          false
      end

    Kodi.send_frame(frame)
    {:noreply, state}
  end

  def handle_cast({:from_serial, :connected}, state) do
    Kodi.send_frame(RPC.request_player_state())
    {:noreply, state}
  end

  def handle_cast(:prep_stop, state) do
    {:noreply, state}
  end

  # PRIVATE --------------------

  defp handle_kodi("Player.OnPause", _params, state) do
    Logger.debug(fn -> "paused" end)
    Serial.send_out("d")
    {:noreply, Map.replace!(state, :playing, true)}
  end

  defp handle_kodi("Player.OnPlay", _params, state) do
    Logger.debug(fn -> "play" end)
    Serial.send_out("D")
    {:noreply, Map.replace!(state, :playing, true)}
  end

  defp handle_kodi("Player.OnStop", _params, state) do
    Logger.debug(fn -> "stop" end)
    Serial.send_out("d")
    {:noreply, Map.replace!(state, :playing, false)}
  end

  defp handle_kodi("Player.OnResume", _params, state) do
    Logger.debug(fn -> "unpaused" end)
    Serial.send_out("D")
    {:noreply, Map.replace!(state, :playing, true)}
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
    Serial.send_out("S")
    {:noreply, state}
  end

  defp handle_kodi("GUI.OnScreensaverDeactivated", _params, state) do
    Logger.debug(fn -> "Screensaver deactivated" end)
    Serial.send_out("s")
    {:noreply, state}
  end

  defp handle_kodi("result", %{"speed" => 1}, state) do
    Logger.debug(fn -> "already playing" end)
    Serial.send_out("D")
    {:noreply, Map.replace!(state, :playing, true)}
  end

  defp handle_kodi("result", %{"speed" => 0}, state) do
    Logger.debug(fn -> "nothing is playing" end)
    Serial.send_out("d")
    {:noreply, Map.replace!(state, :playing, false)}
  end

  defp handle_kodi(method, params, state) do
    Logger.debug(fn -> "Received #{method} #{inspect(params)}" end)
    {:noreply, state}
  end
end
