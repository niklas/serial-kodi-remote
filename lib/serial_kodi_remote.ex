defmodule SerialKodiRemote do
  @moduledoc """
  Documentation for SerialKodiRemote.
  """

  @doc """
  Starts listening to a serial port.

  ## Examples

      SerialKodiRemote.start()
      {:ok, #PID}

  """
  def start() do
    {:ok, _} = SerialKodiRemote.Delegator.start_link()
    {:ok, _} = SerialKodiRemote.Kodi.start_link()
    {:ok, _} = SerialKodiRemote.Serial.start_link()
  end
end
