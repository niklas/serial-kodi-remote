defmodule SerialKodiRemoteWeb.StatusLive do
  use SerialKodiRemoteWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={%{}}>
      <div class="flex flex-col gap-4">
        hohoihoi
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
