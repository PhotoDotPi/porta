defmodule Porta.PortsTest do
  use ExUnit.Case, async: true

  alias Porta.Ports

  test "single" do
    assert {:ok, [80]} = Ports.parse("80")
  end

  test "multiple" do
    assert {:ok, [22, 80, 443]} = Ports.parse("22,80,443")
  end

  test "range" do
    assert {:ok, [1, 2, 3]} = Ports.parse("1-3")
  end

  test "mixed and dedup" do
    assert {:ok, [22, 80, 443, 8000, 8001]} = Ports.parse("22,80,443,8000-8001,80")
  end

  test "reversed range invalid" do
    assert {:error, _} = Ports.parse("5-1")
  end

  test "out of range" do
    assert {:error, _} = Ports.parse("0")
    assert {:error, _} = Ports.parse("65536")
  end

  test "malformed" do
    assert {:error, _} = Ports.parse("abc")
    assert {:error, _} = Ports.parse("1-")
    assert {:error, _} = Ports.parse("")
  end

  test "default" do
    assert is_list(Ports.default())
    assert Enum.all?(Ports.default(), &(&1 >= 1 and &1 <= 65535))
  end
end
