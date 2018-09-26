defmodule MoneroAddress do
  @moduledoc """
  MoneroAddress implements functions decoding and validating Monero base58 encoded addresses.
  Monero uses different address format than bicoin. The address contains 1 byte network prefix,
  2 32 byte public keys - spend key and view key and 4 byte checksm. Address is encoded in 8 byte
  chunks (11 base58 characters), optionally '0'-padded ('1' in base58). The address is ths allways
  95 character long. Checksm is computed by taking first 4 bytes of keccak-256 hash. Note that Monero
  does not use official SHA3 but original keccak-256.
  """

  b58_alphabet = Enum.with_index('123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz')

  for {encoding, value} <- b58_alphabet do
    defp do_encode58(unquote(value)), do: unquote(encoding)
    defp do_decode58(unquote(encoding)), do: unquote(value)
  end

  defp do_decode58(c), do: raise(ArgumentError, "illegal character #{c}")

  @b58base 58

  encodedBlockSizes = Enum.with_index([0, 2, 3, 5, 6, 7, 9, 10, 11])

  for {size, index} <- encodedBlockSizes do
    defp decoded_block_size(unquote(size)), do: unquote(index)
  end

  @fullEncodedBlockSize 11

  defp decode58([], acc), do: acc

  defp decode58([c | code], acc) do
    decode58(code, acc * @b58base + do_decode58(c))
  end

  defp decode_block(block) do
    decoded_bin = decode58(block, 0) |> :binary.encode_unsigned()
    size = byte_size(decoded_bin)
    needed_size = decoded_block_size(length(block))

    padding =
      if size < needed_size do
        for _ <- 1..(needed_size - size), into: <<>>, do: <<0>>
      else
        <<>>
      end

    padding <> decoded_bin
  end

  @doc """
  Decodes Monero specific base58 encoded binary.

  ## Examples

      iex> MoneroAddress.base58_decode!("55LTR8KniP")
      <<107, 134, 160, 20, 146, 167, 244>>

  """
  def base58_decode!(code) when is_binary(code) do
    # this function differs from btc
    # split payload into blocks of 11 codepoints (8 bytes)
    blocks =
      to_charlist(code)
      |> Enum.chunk_every(@fullEncodedBlockSize)

    for block <- blocks, do: decode_block(block), into: <<>>
  end

  def base58_decode!(_code), do: raise(ArgumentError, "expects base58-encoded binary")

  @doc """
  Decodes and validates Monero address. Returns tuple containing network prefix (encoded as integer),
  public spend key (hex encoded) and public view key (hex encoded)

  ## Examples

      iex> MoneroAddress.decode_address!("44AFFq5kSiGBoZ4NMDwYtN18obc8AemS33DBLWs3H7otXft3XjrpDtQGv7SqSsaBYBb98uNbr2VBBEt7f2wfn3RVGQBEP3A", :main)
      {18,
             "42f18fc61586554095b0799b5c4b6f00cdeb26a93b20540d366932c6001617b7",
             "5db35109fbba7d5f275fef4b9c49e0cc1c84b219ec6ff652fda54f89f7f63c88", :address}

  """
  def decode_address!(code, network) do
    case String.length(code) do
      95 -> decode_simple_address!(code, network)
      106 -> decode_integrated_v2_address!(code, network)
      139 -> decode_integrated_v1_address!(code, network)
      _ -> raise(ArgumentError, "invalid length")
    end
  end

  defp decode_simple_address!(code, network) do
    <<prefix::binary-size(1), public_spend_key::binary-size(32), public_view_key::binary-size(32),
      checksum::binary-size(4)>> = base58_decode!(code)

    payload = prefix <> public_spend_key <> public_view_key

    unless checksum_valid?(payload, checksum), do: raise(ArgumentError, "checksum does not match")

    <<prefix_code>> = prefix

    type = cond do
      prefix_code == network_prefix(network, :address) -> :address
      prefix_code == network_prefix(network, :subaddress) -> :subaddress
      true -> raise(ArgumentError, "invalid network prefix #{prefix_code}")
    end

    {prefix_code, public_spend_key |> Base.encode16(case: :lower),
     public_view_key |> Base.encode16(case: :lower), type}
  end

  defp decode_integrated_v1_address!(code, network) do
    <<prefix::binary-size(1), public_spend_key::binary-size(32), public_view_key::binary-size(32),
      payment_id::binary-size(32),
      checksum::binary-size(4)>> = base58_decode!(code)

    payload = prefix <> public_spend_key <> public_view_key <> payment_id

    unless checksum_valid?(payload, checksum), do: raise(ArgumentError, "checksum does not match")

    <<prefix_code>> = prefix

    if prefix_code != network_prefix(network, :integrated_address),
      do: raise(ArgumentError, "invalid network prefix #{prefix_code}")

    {prefix_code, public_spend_key |> Base.encode16(case: :lower),
     public_view_key |> Base.encode16(case: :lower), {:integrated, payment_id |> Base.encode16(case: :lower)}}
  end

  defp decode_integrated_v2_address!(code, network) do
    <<prefix::binary-size(1), public_spend_key::binary-size(32), public_view_key::binary-size(32),
      payment_id::binary-size(8),
      checksum::binary-size(4)>> = base58_decode!(code)

    payload = prefix <> public_spend_key <> public_view_key <> payment_id

    unless checksum_valid?(payload, checksum), do: raise(ArgumentError, "checksum does not match")

    <<prefix_code>> = prefix

    if prefix_code != network_prefix(network, :integrated_address),
      do: raise(ArgumentError, "invalid network prefix #{prefix_code}")

    {prefix_code, public_spend_key |> Base.encode16(case: :lower),
     public_view_key |> Base.encode16(case: :lower), {:integrated, payment_id |> Base.encode16(case: :lower)}}
  end

  defp checksum_valid?(payload, checksum) do
    # monero uses original keccak-256 not the NIST official sha3
    <<prefix::binary-size(4), _::binary-size(28)>> = :sha3.hash(256, payload)
    prefix == checksum
  end

  defp network_prefix(:main, :address), do: 18
  defp network_prefix(:main, :integrated_address), do: 19
  defp network_prefix(:main, :subaddress), do: 42
  defp network_prefix(:stage, :address), do: 24
  defp network_prefix(:stage, :integrated_address), do: 25
  defp network_prefix(:stage, :subaddress), do: 36
  defp network_prefix(:test, :address), do: 53
  defp network_prefix(:test, :integrated_address), do: 54
  defp network_prefix(:test, :subaddress), do: 63
end
