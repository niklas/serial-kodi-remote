defmodule SerialKodiRemote.Transmission do
  use GenServer
  require Logger

  @registered_name __MODULE__

  def start_link(url) do
    GenServer.start_link(__MODULE__, url, name: @registered_name)
  end

  def enable_slow_mode do
    rpc("session-set", %{"alt-speed-enabled" => true})
  end

  def disable_slow_mode do
    rpc("session-set", %{"alt-speed-enabled" => false})
  end

  def rpc(meth, args) do
    GenServer.cast(@registered_name, {:rpc, {meth, args}})
  end

  def init(url) do
    {:ok, %{url: url, session_id: nil, last_result: nil}}
  end

  def handle_cast({:rpc, margs}, state), do: do_rpc(margs, state)

  def do_rpc({meth, args}, %{url: url, session_id: session_id} = state) do
    body =
      Jason.encode!(%{
        "arguments" => args,
        "method" => meth
      })

    headers = [
      "X-Transmission-Session-Id": session_id
    ]

    last_result =
      case HTTPoison.post(url, body, headers) do
        {:ok, %{status_code: 200} = response} ->
          {:ok, %{"result" => "success"}} = Jason.decode(response.body)
          :ok

        {:ok, %{status_code: 401}} ->
          Logger.warning(fn -> "#{__MODULE__}: Unauthorized" end)
          {:error, "unauthorized"}

        {:ok, %{status_code: 409, headers: headers}} ->
          [new_session_id] = for {"x-transmission-session-id", id} <- headers, do: id
          Logger.debug(fn -> "#{__MODULE__}: Conflict, retrying with new session id" end)
          do_rpc({meth, args}, Map.put(state, :session_id, new_session_id))

        {:ok, %{status_code: 301, headers: headers}} ->
          [location] = for {"location", l} <- headers, do: l
          Logger.warning(fn -> "#{__MODULE__}: Redirect to #{location}" end)
          {:error, "redirected to #{location}"}
      end

    new_state =
      state
      |> Map.put(:last_result, last_result)
      |> Map.put(:session_id, session_id)

    {:noreply, new_state}
  end
end