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

  def handle_message(%{"result" => result}, state) do
    Logger.debug(fn -> "Received result: #{inspect(result)}" end)
    {:ok, state}
  end

  def handle_message(%{"method" => method, "params" => params}, state) do
    Logger.debug(fn -> "Received #{method} #{inspect(params)}" end)
    {:ok, state}
  end

  def handle_message(msg, state) do
    Logger.debug(fn -> "Received unhandled json: #{inspect(msg)}" end)
    {:ok, state}
  end
end
