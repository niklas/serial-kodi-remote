defmodule SerialKodiRemote do
  @moduledoc """
  Documentation for SerialKodiRemote.
  """

  @doc """
  Starts listening to a serial port.

  ## Examples

      SerialKodiRemote.start("/dev/ttyUSB0")
      {:ok, #PID}

  """
  def start(port) do
    {:ok, kodi} = SerialKodiRemote.Kodi.start_link("ws://name:password@host:9090/jsonrpc")
    SerialKodiRemote.Serial.start_link(port, kodi)
  end
end
