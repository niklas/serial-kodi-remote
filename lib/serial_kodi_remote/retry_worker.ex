defmodule SerialKodiRemote.RetryWorker do
  use GenServer
  require Logger

  @initial_delay 1000
  @max_delay 30_000

  def start_link({mod, args}) do
    GenServer.start_link(
      __MODULE__,
      {mod, args, @initial_delay},
      name: Module.concat(mod, RetryWorker)
    )
  end

  def init({mod, args, delay}) do
    try_start(mod, args, delay)
    {:ok, %{mod: mod, args: args, delay: delay}}
  end

  def handle_info(:retry, %{mod: mod, args: args, delay: delay} = state) do
    new_delay = min(@max_delay, delay * 2)
    try_start(mod, args, new_delay)
    {:noreply, %{state | delay: new_delay}}
  end

  defp try_start(mod, args, delay) do
    case DynamicSupervisor.start_child(SerialKodiRemote.DynamicSupervisor, {mod, args}) do
      {:ok, _pid} ->
        # TODO: reset delay?
        :ok

      {:error, reason} ->
        Logger.warning(fn ->
          "RetryWorker: failed #{mod}\n  with: #{inspect(reason)}\n  restarting in #{delay}ms"
        end)

        # Retry with updated delay
        Process.send_after(self(), :retry, delay)
        :ok
    end
  end

  def child_spec(opts = {mod, _args}) do
    %{
      id: Module.concat(mod, RetryWorker),
      start: {__MODULE__, :start_link, [opts]}
    }
  end
end
