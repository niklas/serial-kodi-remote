defmodule LogLevelStringToAtom do
  use Toml.Transform

  def transform(:level, "emergency"), do: :emergency
  def transform(:level, "alert"), do: :alert
  def transform(:level, "critical"), do: :critical
  def transform(:level, "error"), do: :error
  def transform(:level, "warning"), do: :warning
  def transform(:level, "notice"), do: :notice
  def transform(:level, "info"), do: :info
  def transform(:level, "debug"), do: :debug
end
