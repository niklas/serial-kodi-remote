defmodule SerialKodiRemoteWeb.StatusLive do
  use SerialKodiRemoteWeb, :live_view

  alias SerialKodiRemote.Broadcaster
  alias SerialKodiRemote.RetryWorker

  def render(assigns) do
    ~H"""
    <Layouts.app flash={%{}}>
      <div class="flex flex-row gap-4">
        <.part class="w-full" title="Serial" resource={@serial} />
        <.part class="w-full" title="Transmission" resource={@transmission} />
        <.part class="w-full" title="Kodi" resource={@kodi} />
      </div>
    </Layouts.app>
    """
  end

  def part(assigns) do
    ~H"""
     <div class={[@class, "flex flex-col gap-2 p-4 border rounded", border_color(@resource.status)]}>
       <h2 class="text-xl font-bold">{@title}</h2>
       <span class={text_color(@resource.status)}>{@resource.status}</span>
       <p class="text-sm">{@resource.message}</p>
    </div>
    """
  end

  defp border_color(:connected), do: "border-green-500"
  defp border_color(:unavailable), do: "border-red-500"
  defp border_color(:starting), do: "border-yellow-500"
  defp border_color(_), do: "border-gray-500"

  defp text_color(:connected), do: "text-green-500"
  defp text_color(:unavailable), do: "text-red-500"
  defp text_color(:starting), do: "text-yellow-500"
  defp text_color(_), do: "text-gray-500"

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:serial, init_serial())
     |> assign(:kodi, init_kodi())
     |> assign(:transmission, init_transmission())
    }
  end

  def handle_info({resource, {status, msg}}, socket) do
    {:noreply, assign(socket, resource, %{status: status, message: msg})}
  end

  def handle_info({resource, status}, socket) when is_atom(status) do
    {:noreply, assign(socket, resource, %{status: status, message: nil})}
  end

  defp init_serial() do
    {status, message} = RetryWorker.status(SerialKodiRemote.Serial)
    %{
     subscription: Broadcaster.subscribe(:serial),
     status: status,
     message: message
    }
  end
  defp init_kodi() do
    {status, message} = RetryWorker.status(SerialKodiRemote.Kodi)
    %{
      subscription: Broadcaster.subscribe(:kodi),
      status: status,
      message: message
    }
  end
  defp init_transmission() do
    {status, message} = RetryWorker.status(SerialKodiRemote.Transmission)
    %{
     subscription: Broadcaster.subscribe(:transmission),
     status: status,
     message: message
    }
  end
end
