defmodule SerialKodiRemote.Serial do
  use GenServer
  use SerialKodiRemote.TaggedLogger
  alias SerialKodiRemote.Buffer
  alias SerialKodiRemote.Delegator

  @registered_name __MODULE__
  @baud 115_200

  def start_link(port) do
    GenServer.start_link(__MODULE__, %{port: port, buffer: "", pid: nil}, name: @registered_name)
  end

  def send_out(m) do
    GenServer.cast(@registered_name, {:send, m})
  end

  # End of public API ----------

  def init(state) do
    {:ok, pid} = Circuits.UART.start_link()

    {:ok, do_connect(%{state | pid: pid})}
  end

  def do_connect(%{pid: pid, port: port} = state) do
    case connect(pid, port) do
      :ok ->
        state

      {:error, :enoent} ->
        log_warning(fn ->
          "cannot connect: device #{state.port} does not exist"
        end)

        exit(:unavailable)

      {:error, :eperm} ->
        log_warning(fn ->
          "no permissions to write to device #{state.port}"
        end)

        exit(:unavailable)

      {:error, reason} ->
        log_warning(fn -> "cannot connect: #{reason}" end)
        exit(:error)
    end
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
    log_debug(fn -> "mark OTA" end)
    write(pid, "U")
    Process.sleep(100)
    state
  end

  defp write(pid, l) do
    case Circuits.UART.write(pid, "<" <> l <> ">") do
      :ok ->
        :ok

      {:error, :ebadf} ->
        log_warning(fn -> "writing failed: Bad file descriptor" end)
        :ok
    end
  end

  defp connect(pid, port) do
    case Circuits.UART.open(pid, port, speed: @baud, active: true) do
      :ok ->
        log_info(fn -> "connected to #{port}" end)
        Delegator.from_serial(:connected)
        :ok

      other ->
        other
    end
  end
end
