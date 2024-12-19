defmodule SerialKodiRemote.RetryWorker do
  use GenServer
  use SerialKodiRemote.TaggedLogger

  @initial_delay 1000
  @max_delay 30_000

  def start_link({mod, args}) do
    name = Module.concat(mod, RetryWorker)

    GenServer.start_link(
      __MODULE__,
      {mod, args, name},
      name: Module.concat(mod, RetryWorker)
    )
  end

  def init({mod, args, name}) do
    Process.flag(:trap_exit, true)
    state = %{mod: mod, args: args, delay: @initial_delay, name: name}
    {:ok, try_start(state)}
  end

  def handle_info({:EXIT, _pid, reason}, %{mod: mod, delay: delay} = state) do
    log_warning(fn -> "EXIT #{mod} because #{inspect(reason)}" end, state.name)
    schedule_retry(delay, state.name)
    {:noreply, state}
  end

  def handle_info(:retry, state) do
    attempt_restart_with_increasing_delay(state)
  end

  defp try_start(%{mod: mod, args: args, name: name} = state) do
    log_debug(fn -> "trying to start #{mod}" end, name)

    case mod.start_link(args) do
      {:ok, _pid} ->
        # TODO: reset delay?
        log_info(fn -> "started #{mod} successfully" end, name)
        %{state | delay: @initial_delay}

      {:error, {:already_started, _pid}} ->
        log_warning(fn -> "already started" end, name)
        state

      {:error, :unavailable} ->
        schedule_retry(state.delay, name)
        state

      {:error, reason} ->
        log_warning(
          fn ->
            "failed #{mod}\n  with: #{inspect(reason)}"
          end,
          name
        )

        state
    end
  end

  defp attempt_restart_with_increasing_delay(%{mod: mod, delay: delay, name: name} = state) do
    new_delay = min(@max_delay, delay * 2)
    log_debug(fn -> "retrying #{mod} with #{new_delay}ms holdoff" end, name)
    {:noreply, try_start(%{state | delay: new_delay})}
  end

  defp schedule_retry(delay, name) do
    log_info(fn -> "will retry in #{delay}ms" end, name)
    Process.send_after(self(), :retry, delay)
  end

  def child_spec(opts = {mod, _args}) do
    %{
      id: Module.concat(mod, RetryWorker),
      start: {__MODULE__, :start_link, [opts]}
    }
  end
end
