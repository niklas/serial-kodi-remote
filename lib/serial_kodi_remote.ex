defmodule SerialKodiRemote do
  @moduledoc """
  Documentation for SerialKodiRemote.
  """

  @doc """
  Starts listening to a serial port.

  ## Examples

      iex> SerialKodiRemote.start("/dev/ttyUSB0")
      {:ok, pid}

  """
  def start(port) do
    SerialKodiRemote.Serial.start_link(port)
  end
end
