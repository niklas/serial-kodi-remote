defmodule SerialKodiRemoteWeb.PageController do
  use SerialKodiRemoteWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
