defmodule MoneroAddressTest do
  use ExUnit.Case, async: true
  doctest MoneroAddress

  test "should decode valid addresses" do
    assert {18, _, _} = "44AFFq5kSiGBoZ4NMDwYtN18obc8AemS33DBLWs3H7otXft3XjrpDtQGv7SqSsaBYBb98uNbr2VBBEt7f2wfn3RVGQBEP3A"
    |> MoneroAddress.decode_address!(:main)

    assert {24, _, _} = "55LTR8KniP4LQGJSPtbYDacR7dz8RBFnsfAKMaMuwUNYX6aQbBcovzDPyrQF9KXF9tVU6Xk3K8no1BywnJX6GvZX8yJsXvt"
    |> MoneroAddress.decode_address!(:stage)

    assert {53, psk, pvk} =
    "9zxM5uUAZxDDbGPDtBBpga2eLKhuK5WWJDcLQ3brGwHpiDmro8TrXkpUEd5rHyZecCaeYen7rou6KW1ySfCvU69eG2Bmsiz"
    |> MoneroAddress.decode_address!(:test)

    assert psk == "cd8235338c6d9a4b467d97d20e6ea309d3af16f845abf74b62b48d616ba00ff6"
    assert pvk == "708dae560daacda2d39d0c0b5586edc92a0fa918f0a444ad7ae029ff1ae81185"
  end

  test "too short" do
    error = assert_raise(ArgumentError, fn ->
      "44AFFq5kSiGBoZ4NMDwYtN18obc8AemS33DBLWs3H7otXft3XjrpDtQGv7SqSsaBYBb98uNbr2VBBEt7f2wfn3RVGQBEP"
      |> MoneroAddress.decode_address!(:main)
    end)
    assert error.message == "invalid length"
  end

  test "too long" do
    error = assert_raise(ArgumentError, fn ->
      "44AFFq5kSiGBoZ4NMDwYtN18obc8AemS33DBLWs3H7otXft3XjrpDtQGv7SqSsaBYBb98uNbr2VBBEt7f2wfn3RVGQBEP4234324234223432"
      |> MoneroAddress.decode_address!(:main)
    end)
    assert error.message == "invalid length"
  end

  test "invalid prefix" do
    error = assert_raise(ArgumentError, fn ->
      "9zxM5uUAZxDDbGPDtBBpga2eLKhuK5WWJDcLQ3brGwHpiDmro8TrXkpUEd5rHyZecCaeYen7rou6KW1ySfCvU69eG2Bmsiz"
      |> MoneroAddress.decode_address!(:main)
    end)
    assert error.message == "invalid network prefix 53"
  end

  test "invalid checksm" do
    error = assert_raise(ArgumentError, fn ->
      "9zxM5uUAZxDDbGPDtBBpga2eLKhuK5WWJDcLQ3brGwHpiDmro8TrXkpUEd5rHyZecCaeYen7rou6KW1ySfCvU69eG2Bmsi1"
      |> MoneroAddress.decode_address!(:test)
    end)
    assert error.message == "checksum does not match"
  end

  test "invalid codepoint" do
    error = assert_raise(ArgumentError, fn ->
      "0zxM5uUAZxDDbGPDtBBpga2eLKhuK5WWJDcLQ3brGwHpiDmro8TrXkpUEd5rHyZecCaeYen7rou6KW1ySfCvU69eG2Bmsiz"
      |> MoneroAddress.decode_address!(:test)
    end)
    assert error.message == "illegal character 48"
  end

end
