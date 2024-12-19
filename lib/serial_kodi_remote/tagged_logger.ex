defmodule SerialKodiRemote.TaggedLogger do
  defmacro __using__(_) do
    quote do
      require Logger

      def log_info(msgfn, name \\ __MODULE__) do
        Logger.info(fn -> "#{name}: #{msgfn.()}" end)
      end

      def log_warning(msgfn, name \\ __MODULE__) do
        Logger.warning(fn -> "#{name}: #{msgfn.()}" end)
      end

      def log_debug(msgfn, name \\ __MODULE__) do
        Logger.debug(fn -> "#{name}: #{msgfn.()}" end)
      end
    end
  end
end
