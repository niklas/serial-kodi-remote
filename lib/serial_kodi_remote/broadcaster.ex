defmodule SerialKodiRemote.Broadcaster do

  alias Phoenix.PubSub
  alias SerialKodiRemote.PubSub, as: SKR

  def subscribe(:serial) do
    PubSub.subscribe(SKR, "serial")
  end
  def subscribe(:transmission) do
    PubSub.subscribe(SKR, "transmission")
  end
  def subscribe(:kodi) do
    PubSub.subscribe(SKR, "kodi")
  end

  def serial(msg) do
    broadcast("serial", msg)
  end

  def broadcast(topic, message) do
    PubSub.broadcast(SKR, topic, message)
  end
end
