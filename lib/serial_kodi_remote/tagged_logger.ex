defmodule SerialKodiRemote.TaggedLogger do
  defmacro __using__(_) do
    quote do
      require Logger

      def log_info(msgfn) do
        Logger.info(fn -> "#{__MODULE__}: #{msgfn.()}" end)
      end

      def log_warning(msgfn) do
        Logger.warning(fn -> "#{__MODULE__}: #{msgfn.()}" end)
      end

      def log_debug(msgfn) do
        Logger.debug(fn -> "#{__MODULE__}: #{msgfn.()}" end)
      end
    end
  end
end
