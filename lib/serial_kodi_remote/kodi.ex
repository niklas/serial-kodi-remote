defmodule SerialKodiRemote.Kodi do
  use WebSockex
  require Logger
  alias SerialKodiRemote.KodiRPC, as: RPC

  def start_link(url) do
    WebSockex.start_link(url, __MODULE__, %{})
  end

  def handle_frame({:text, json}, state) do
    msg = Jason.decode!(json)
    handle_message(msg, state)
  end

  def handle_frame({type, msg}, state) do
    Logger.debug(fn ->
      "Received #{inspect(type)} -- Message: #{inspect(msg)}"
    end)

    {:ok, state}
  end

  def handle_info({:remote_key, key}, state) do
    Logger.debug(fn -> "Kodi: #{key}" end)

    frame =
      case key do
        "v" -> RPC.volume_down()
        "V" -> RPC.volume_up()
        "m" -> RPC.mute()
        "p" -> RPC.pause()
        _ -> false
      end

    if frame do
      {:reply, {:text, Jason.encode!(frame)}, state}
    else
      {:ok, state}
    end
  end

  defp handle_message(%{"result" => result}, state) do
    Logger.debug(fn -> "Received result: #{inspect(result)}" end)
    {:ok, state}
  end

  defp handle_message(%{"method" => method, "params" => params}, state) do
    handle_method_response(method, params, state)
  end

  defp handle_message(msg, state) do
    Logger.debug(fn -> "Received unhandled json: #{inspect(msg)}" end)
    {:ok, state}
  end

  defp handle_method_response("Player.OnPause", _params, state) do
    Logger.debug(fn -> "paused" end)
    {:ok, state}
  end

  defp handle_method_response("Player.OnResume", _params, state) do
    Logger.debug(fn -> "unpaused" end)
    {:ok, state}
  end

  defp handle_method_response(
         "Application.OnVolumeChanged",
         %{"data" => %{"muted" => true}},
         state
       ) do
    Logger.debug(fn -> "muted" end)
    {:ok, state}
  end

  defp handle_method_response(
         "Application.OnVolumeChanged",
         %{"data" => %{"muted" => false}},
         state
       ) do
    Logger.debug(fn -> "unmuted" end)
    {:ok, state}
  end

  defp handle_method_response("GUI.OnScreensaverActivated", _params, state) do
    Logger.debug(fn -> "Screensaver activated" end)
    {:ok, state}
  end

  defp handle_method_response("GUI.OnScreensaverDeactivated", _params, state) do
    Logger.debug(fn -> "Screensaver deactivated" end)
    {:ok, state}
  end

  defp handle_method_response(method, params, state) do
    Logger.debug(fn -> "Received #{method} #{inspect(params)}" end)
    {:ok, state}
  end
end
