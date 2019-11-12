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

  def command(meth, params) do
    %{
      "jsonrpc" => "2.0",
      "method" => meth,
      "params" => params,
      "id" => 1
    }
  end
end
