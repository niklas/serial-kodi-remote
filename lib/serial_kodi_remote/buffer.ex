defmodule SerialKodiRemote.Buffer do
  @doc """
  Extracts keys from a string received from Serial connections

  ## Examples

      iex> SerialKodiRemote.Buffer.parse("garbage")
      {[], "garbage"}

      iex> SerialKodiRemote.Buffer.parse("garbage\r\nrem:1\r\nfoo")
      {["1"], "\r\nfoo"}

      iex> SerialKodiRemote.Buffer.parse("garbage\r\nrem:1\r\nfoo\r\nrem:V\r\nbar")
      {["1", "V"], "\r\nbar"}

  """
  def parse("") do
    {[], ""}
  end

  def parse(<<"rem:", key::utf8, rest::binary>>) do
    {keys, rem} = parse(rest)

    {[key | keys], rem}
  end

  def parse(<<c::utf8, rest::binary>>) do
    {keys, rem} = parse(rest)
    {keys, c <> rem}
  end
end
