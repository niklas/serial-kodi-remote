defmodule SerialKodiRemote.Serial do
  use GenServer
  require Logger
  alias SerialKodiRemote.Buffer
  alias SerialKodiRemote.Delegator

  @registered_name __MODULE__

  def start_link(_) do
    port = Application.get_env(:serial_kodi_remote, :serial_port)
    GenServer.start_link(__MODULE__, %{port: port, buffer: "", pid: nil}, name: @registered_name)
  end

  def init(state) do
    {:ok, pid} = Circuits.UART.start_link()
    Circuits.UART.open(pid, state.port, speed: 9600, active: true)
    Logger.debug("Connected to #{state.port}")

    {:ok, %{state | pid: pid}}
  end

  def handle_info({:circuits_uart, _port, data}, %{buffer: buffer} = state) do
    {keys, remaining} = Buffer.parse(buffer <> data)

    keys
    |> Enum.map(fn key -> Delegator.from_serial({:remote_key, key}) end)

    {:noreply, %{state | buffer: remaining}}
  end
end
