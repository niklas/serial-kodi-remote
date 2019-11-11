defmodule SerialKodiRemoteTest do
  use ExUnit.Case
  doctest SerialKodiRemote

  test "greets the world" do
    assert SerialKodiRemote.hello() == :world
  end
end
