defmodule SerialKodiRemote.Kodi do
  use WebSockex
  require Logger
  alias SerialKodiRemote.Delegator

  @registered_name __MODULE__

  def start_link(url) do
    WebSockex.start_link(url, __MODULE__, %{}, name: @registered_name)
  end

  def send_frame(frame) do
    send(@registered_name, {:send_frame, frame})
  end

  # End of public API ----------

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

  def handle_info({:send_frame, frame}, state) do
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
    Delegator.from_kodi(method, params)
    {:ok, state}
  end

  defp handle_message(msg, state) do
    Logger.debug(fn -> "Received unhandled json: #{inspect(msg)}" end)
    {:ok, state}
  end
end
