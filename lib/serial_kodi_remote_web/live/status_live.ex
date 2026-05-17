defmodule SerialKodiRemoteWeb.StatusLive do
  use SerialKodiRemoteWeb, :live_view

  alias SerialKodiRemote.Broadcaster
  alias SerialKodiRemote.RetryWorker

  def render(assigns) do
    ~H"""
    <Layouts.app flash={%{}}>
      <div class="flex flex-col gap-4">
        <div class="w-full">
          <.part title="Serial" resource={@serial} />
        </div>
      </div>
    </Layouts.app>
    """
  end

  def part(assigns) do
    ~H"""
     <div class={["flex flex-col gap-2 p-4 border rounded", border_color(@resource.status)]}>
       <h2 class="text-xl font-bold">{@title}</h2>
       <span class={text_color(@resource.status)}>{@resource.status}</span>
       <p>{@resource.message}</p>
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
    }
  end

  def handle_info({:serial, msg}, socket) do
    handle_serial(msg, socket)
  end

  defp init_serial() do
    {status, message} = RetryWorker.status(SerialKodiRemote.Serial)
    %{
     subscription: Broadcaster.subscribe(:serial),
     status: status,
     message: message
    }
  end

  defp handle_serial({:unavailable, msg}, socket) do
    {:noreply, assign(socket, :serial, %{status: :unavailable, message: msg})}
  end

  defp handle_serial(:connected, socket) do
    {:noreply, assign(socket, :serial, %{status: :connected, message: nil})}
  end
end
