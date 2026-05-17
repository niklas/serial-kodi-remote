defmodule SerialKodiRemote.Broadcaster do

  alias Phoenix.PubSub
  alias SerialKodiRemote.PubSub, as: SKR

  def subscribe(:serial) do
    PubSub.subscribe(SKR, "serial")
  end

  def serial(msg) do
    broadcast("serial", msg)
  end

  def serial_problem(msg) do
    serial({:problem, msg})
  end

  def serial_connected() do
    serial(:connected)
  end

  defp broadcast(topic, message) do
    PubSub.broadcast(SKR, topic, message)
  end
end
