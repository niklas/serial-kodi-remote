defmodule SerialKodiRemote.Serial do
  use GenServer
  require Logger

  @registered_name __MODULE__

  def start_link(port) do
    GenServer.start_link(__MODULE__, %{port: port}, name: @registered_name)
  end

  def init(state) do
    {:ok, pid} = Circuits.UART.start_link()
    Circuits.UART.open(pid, state.port, speed: 9600, active: true)
    Logger.debug("Connected to #{state.port}")

    {:ok, state |> Map.put(:pid, pid)}
  end

  def handle_info({:circuits_uart, _port, data}, state) do
    Regex.scan(~r/^rem:(.)$/m, data)
    |> Enum.map(fn code -> Logger.debug("Received #{code}") end)

    {:noreply, state}
  end
end
