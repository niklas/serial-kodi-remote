defmodule SerialKodiRemote.Serial do
  use GenServer
  require Logger
  alias SerialKodiRemote.Buffer
  alias SerialKodiRemote.Delegator

  @registered_name __MODULE__
  @baud 115200
  @wait 5 * 1000

  def start_link(port) do
    GenServer.start_link(__MODULE__, %{port: port, buffer: "", pid: nil}, name: @registered_name)
  end

  def send_out(m) do
    GenServer.cast(@registered_name, {:send, m})
  end

  # End of public API ----------

  def init(state) do
    {:ok, pid} = Circuits.UART.start_link()
    Process.flag(:trap_exit, true)
    schedule_connect()

    {:ok, %{state | pid: pid}}
  end

  def handle_info(:connect, state) do
    case connect(state.pid, state.port) do
      :ok ->
        :ok
      {:error, :enoent} ->
        Logger.warn(fn -> "#{__MODULE__} cannot connect: device #{state.port} does not exist" end)
        Process.sleep(@wait * 10)
        schedule_connect()
      {:error, :eperm} ->
        Logger.warn(fn -> "#{__MODULE__} cannot connect: no permissions to write to device #{state.port}" end)
        Process.sleep(@wait * 10)
        schedule_connect()
      {:error, reason} ->
        Logger.warn(fn -> "#{__MODULE__} cannot connect: #{reason}" end)
        schedule_connect()
    end
    {:noreply, state}
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

  defp schedule_connect() do
    Process.send_after(self(), :connect, @wait)
  end

  defp connect(pid, port) do
    case Circuits.UART.open(pid, port, speed: @baud, active: true) do
      :ok ->
        Logger.info(fn -> "#{__MODULE__} connected to #{port}" end)
        Delegator.from_serial(:connected)
        :ok
      other ->
        other
    end
  end
end
