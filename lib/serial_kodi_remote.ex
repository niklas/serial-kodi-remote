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
    SerialKodiRemote.Serial.start_link(port)
  end
end
