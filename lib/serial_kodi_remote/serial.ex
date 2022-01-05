defmodule SerialKodiRemote.Serial do
  use GenServer
  require Logger
  alias SerialKodiRemote.Buffer
  alias SerialKodiRemote.Delegator

  @registered_name __MODULE__
  @baud 115200

  def start_link(port) do
    GenServer.start_link(__MODULE__, %{port: port, buffer: "", pid: nil}, name: @registered_name)
  end

  def send_out(m) do
    GenServer.cast(@registered_name, {:send, m})
  end

  # End of public API ----------

  def init(state) do
    {:ok, pid} = Circuits.UART.start_link()
    :ok = Circuits.UART.open(pid, state.port, speed: @baud, active: true)
    Process.flag(:trap_exit, true)
    Logger.info(fn -> "#{__MODULE__} connected to #{state.port}" end)
    Delegator.from_serial(:connected)

    {:ok, %{state | pid: pid}}
  end

  def handle_info({:circuits_uart, _port, data}, %{buffer: buffer} = state) do
    {keys, remaining} = Buffer.parse(buffer <> data)

    keys
    |> Enum.map(fn key -> Delegator.from_serial({:remote_key, key}) end)

    {:noreply, %{state | buffer: remaining}}
  end

  def handle_cast({:send, m}, %{pid: pid} = state) do
    write(pid, m)
    {:noreply, state}
  end

  def terminate(_, %{pid: pid} = state) do
    Logger.debug(fn -> "mark OTA" end)
    write(pid, "U")
    Process.sleep(100)
    state
  end

  defp write(pid, l) do
    :ok = Circuits.UART.write(pid, "<" <> l <> ">")
  end
end
