defmodule SerialKodiRemote.Kodi do
  use WebSockex
  require Logger
  alias SerialKodiRemote.KodiRPC, as: RPC

  def start_link(url) do
    WebSockex.start_link(url, __MODULE__, %{}, debug: [:trace])
  end

  def handle_frame({type, msg}, state) do
    Logger.debug(fn -> "Received Message - Type: #{inspect(type)} -- Message: #{inspect(msg)}" end)

    {:ok, state}
  end

  def handle_info({:remote_key, key}, state) do
    Logger.debug(fn -> "Kodi: #{key}" end)

    frame =
      case key do
        "v" -> RPC.volume_down()
        "V" -> RPC.volume_up()
        _ -> nil
      end

    if frame do
      {:reply, {:text, Jason.encode!(frame)}, state}
    else
      {:noreply, state}
    end
  end
end
