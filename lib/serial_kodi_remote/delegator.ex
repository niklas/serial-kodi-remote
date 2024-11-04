defmodule SerialKodiRemote.Delegator do
  use GenServer
  require Logger
  @registered_name __MODULE__

  alias SerialKodiRemote.Kodi
  alias SerialKodiRemote.Serial
  alias SerialKodiRemote.KodiRPC
  alias SerialKodiRemote.Transmission

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{playing: false, subtitles: []}, name: @registered_name)
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

  def handle_cast({:from_serial, {:remote_key, key}}, state) do
    handle_remote_key(key, state)
    |> Kodi.send_frame()

    {:noreply, state}
  end

  def handle_cast({:from_serial, :connected}, state) do
    Kodi.send_frame(KodiRPC.request_player_state())
    Kodi.send_frame(KodiRPC.notify("Remote Control", "connected"))
    {:noreply, state}
  end

  def handle_cast(:prep_stop, state) do
    {:noreply, state}
  end

  # PRIVATE --------------------

  defp handle_remote_key("v", _state), do: KodiRPC.volume_down()
  defp handle_remote_key("V", _state), do: KodiRPC.volume_up()
  defp handle_remote_key("m", _state), do: KodiRPC.mute()
  defp handle_remote_key("p", _state), do: KodiRPC.pause()
  defp handle_remote_key("P", _state), do: KodiRPC.stop()
  defp handle_remote_key("C", _state), do: KodiRPC.up()
  defp handle_remote_key("c", _state), do: KodiRPC.down()
  defp handle_remote_key("r", _state), do: KodiRPC.right()
  defp handle_remote_key("l", _state), do: KodiRPC.left()
  defp handle_remote_key("S", _state), do: KodiRPC.seek_left()
  defp handle_remote_key("s", _state), do: KodiRPC.seek_right()
  defp handle_remote_key("O", _state), do: KodiRPC.select()
  defp handle_remote_key("b", _state), do: KodiRPC.back()
  defp handle_remote_key("i", _state), do: KodiRPC.info()
  defp handle_remote_key("n", _state), do: KodiRPC.next_item()
  defp handle_remote_key("N", _state), do: KodiRPC.previous_item()

  defp handle_remote_key("t", state) do
    if Enum.empty?(state.subtitles) do
      KodiRPC.open_subtitle_download_dialog()
    else
      KodiRPC.next_subtitle()
    end
  end

  defp handle_remote_key(key, _state) do
    if String.match?(key, ~r/\A\d\z/) do
      KodiRPC.notify("Crystal", "Color Scheme #{key}")
    else
      false
    end
  end

  defp handle_kodi("Player.OnPause", _params, state) do
    Logger.debug(fn -> "paused" end)
    Serial.send_out("d")
    {:noreply, Map.replace!(state, :playing, true)}
  end

  defp handle_kodi("Player.OnPlay", _params, state) do
    Logger.debug(fn -> "play" end)
    KodiRPC.get_subtitles() |> Kodi.send_frame()
    Serial.send_out("D")
    {:noreply, Map.replace!(state, :playing, true)}
  end

  defp handle_kodi("Player.OnStop", _params, state) do
    Logger.debug(fn -> "stop" end)
    Serial.send_out("i")
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
    Transmission.disable_slow_mode()
    {:noreply, state}
  end

  defp handle_kodi("GUI.OnScreensaverDeactivated", _params, state) do
    Logger.debug(fn -> "Screensaver deactivated" end)
    Serial.send_out("s")
    Transmission.enable_slow_mode()
    {:noreply, state}
  end

  defp handle_kodi("result", data, state), do: handle_kodi_result(data, state)

  defp handle_kodi(method, params, state) do
    Logger.debug(fn -> "Received #{method} #{inspect(params)}" end)
    {:noreply, state}
  end

  defp handle_kodi_result("OK", state) do
    {:noreply, state}
  end

  defp handle_kodi_result(%{"speed" => 1}, state) do
    Logger.debug(fn -> "already playing" end)
    Serial.send_out("D")
    KodiRPC.get_subtitles() |> Kodi.send_frame()
    {:noreply, Map.replace!(state, :playing, true)}
  end

  defp handle_kodi_result(%{"speed" => 0}, state) do
    Logger.debug(fn -> "nothing is playing" end)
    Serial.send_out("d")
    {:noreply, Map.replace!(state, :playing, false)}
  end

  defp handle_kodi_result(%{"subtitles" => subtitles}, state) do
    {:noreply, Map.replace!(state, :subtitles, subtitles)}
  end

  defp handle_kodi_result(result, state) do
    Logger.debug(fn -> "unhandleds result from kodi: #{inspect(result)}" end)
    {:noreply, state}
  end
end
