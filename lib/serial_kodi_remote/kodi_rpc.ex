defmodule SerialKodiRemote.KodiRPC do
  @seek_seconds 23

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

  def right do
    command("Input.Right", [])
  end

  def left do
    command("Input.Left", [])
  end

  def select do
    command("Input.Select", [])
  end

  def home do
    command("Input.Home", [])
  end

  def back do
    command("Input.Back", [])
  end

  def info do
    command("Input.Info", [])
  end

  def subtitle do
    s = "next"
    command("Player.SetSubtitle", %{"playerid" => 1, "subtitle" => s})
  end

  def request_player_state do
    command("Player.GetProperties", %{"playerid" => 1, "properties" => ["speed"]})
  end

  def seek_left do
    seek_seconds(-@seek_seconds)
  end

  def seek_right do
    seek_seconds(@seek_seconds)
  end

  defp seek_seconds(seconds) do
    command("Player.Seek", %{"playerid" => 1, "value" => %{"seconds" => seconds}})
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
