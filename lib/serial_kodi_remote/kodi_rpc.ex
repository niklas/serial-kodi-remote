defmodule SerialKodiRemote.KodiRPC do
  def volume_down do
    volume("decrement")
  end

  def volume_up do
    volume("increment")
  end

  def volume(value) do
    command("Application.SetVolume", %{"volume" => value})
  end

  def mute() do
    command("Application.SetMute", %{"mute" => "toggle"})
  end

  def pause do
    command("Player.PlayPause", %{"play" => "toggle", "playerid" => 1})
  end

  def up do
    command("Input.Up", [])
  end

  def down do
    command("Input.Down", [])
  end

  def select do
    command("Input.Select", [])
  end

  def home do
    command("Input.Home", [])
  end

  def info do
    command("Input.Info", [])
  end

  def command(meth, params) do
    %{
      "jsonrpc" => "2.0",
      "method" => meth,
      "params" => params,
      "id" => 1
    }
  end
end
