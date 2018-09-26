defmodule MoneroAddressTest do
  use ExUnit.Case, async: true
  doctest MoneroAddress

  test "should decode valid addresses" do
    assert {18, _, _, :address} =
             "44AFFq5kSiGBoZ4NMDwYtN18obc8AemS33DBLWs3H7otXft3XjrpDtQGv7SqSsaBYBb98uNbr2VBBEt7f2wfn3RVGQBEP3A"
             |> MoneroAddress.decode_address!(:main)

    assert {24, _, _, :address} =
             "55LTR8KniP4LQGJSPtbYDacR7dz8RBFnsfAKMaMuwUNYX6aQbBcovzDPyrQF9KXF9tVU6Xk3K8no1BywnJX6GvZX8yJsXvt"
             |> MoneroAddress.decode_address!(:stage)

    assert {53, psk, pvk, :address} =
             "9zxM5uUAZxDDbGPDtBBpga2eLKhuK5WWJDcLQ3brGwHpiDmro8TrXkpUEd5rHyZecCaeYen7rou6KW1ySfCvU69eG2Bmsiz"
             |> MoneroAddress.decode_address!(:test)

    assert psk == "cd8235338c6d9a4b467d97d20e6ea309d3af16f845abf74b62b48d616ba00ff6"
    assert pvk == "708dae560daacda2d39d0c0b5586edc92a0fa918f0a444ad7ae029ff1ae81185"
  end

  test "should decode valid subaddresses" do
    assert {63, psk, pvk, :subaddress} =
             "BenuGf8eyVhjZwdcxEJY1MHrUfqHjPvE3d7Pi4XY5vQz53VnVpB38bCBsf8AS5rJuZhuYrqdG9URc2eFoCNPwLXtLENT4R7"
             |> MoneroAddress.decode_address!(:test)

    assert psk == "ae7e136f46f618fe7f4a6b323ed60864c20070bf110978d7e3868686d5677318"
    assert pvk == "2bf801cdaf3a8b41020098a6d5e194f48fa62129fe9d8f09d19fee9260665baa"
  end

  test "should decode valid integrated addresses" do
    assert {54, psk, pvk, {:integrated, payment_id}} =
             "ABySz66nm1QUhPiwoAbR2tXU9LJu2U6fJjcsv3rxgkVRWU6tEYcn6C1NBc7wqCv5V7NW3zeYuzKf6RGGgZTFTpVC623BT1ptXvVU2GjR1B"
             |> MoneroAddress.decode_address!(:test)

    assert psk == "ae7e136f46f618fe7f4a6b323ed60864c20070bf110978d7e3868686d5677318"
    assert pvk == "2bf801cdaf3a8b41020098a6d5e194f48fa62129fe9d8f09d19fee9260665baa"
    assert payment_id == "00000feedbadbeef"
  end

  test "too short" do
    error =
      assert_raise(ArgumentError, fn ->
        "44AFFq5kSiGBoZ4NMDwYtN18obc8AemS33DBLWs3H7otXft3XjrpDtQGv7SqSsaBYBb98uNbr2VBBEt7f2wfn3RVGQBEP"
        |> MoneroAddress.decode_address!(:main)
      end)

    assert error.message == "invalid length"
  end

  test "too long" do
    error =
      assert_raise(ArgumentError, fn ->
        "44AFFq5kSiGBoZ4NMDwYtN18obc8AemS33DBLWs3H7otXft3XjrpDtQGv7SqSsaBYBb98uNbr2VBBEt7f2wfn3RVGQBEP4234324234223432"
        |> MoneroAddress.decode_address!(:main)
      end)

    assert error.message == "invalid length"
  end

  test "invalid prefix" do
    error =
      assert_raise(ArgumentError, fn ->
        "9zxM5uUAZxDDbGPDtBBpga2eLKhuK5WWJDcLQ3brGwHpiDmro8TrXkpUEd5rHyZecCaeYen7rou6KW1ySfCvU69eG2Bmsiz"
        |> MoneroAddress.decode_address!(:main)
      end)

    assert error.message == "invalid network prefix 53"
  end

  test "invalid checksm" do
    error =
      assert_raise(ArgumentError, fn ->
        "9zxM5uUAZxDDbGPDtBBpga2eLKhuK5WWJDcLQ3brGwHpiDmro8TrXkpUEd5rHyZecCaeYen7rou6KW1ySfCvU69eG2Bmsi1"
        |> MoneroAddress.decode_address!(:test)
      end)

    assert error.message == "checksum does not match"
  end

  test "invalid codepoint" do
    error =
      assert_raise(ArgumentError, fn ->
        "0zxM5uUAZxDDbGPDtBBpga2eLKhuK5WWJDcLQ3brGwHpiDmro8TrXkpUEd5rHyZecCaeYen7rou6KW1ySfCvU69eG2Bmsiz"
        |> MoneroAddress.decode_address!(:test)
      end)

    assert error.message == "illegal character 48"
  end
end
