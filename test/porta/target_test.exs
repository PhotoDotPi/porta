defmodule Porta.TargetTest do
  use ExUnit.Case, async: true

  alias Porta.Target

  test "single ip" do
    assert {:ok, ["192.168.1.10"]} = Target.parse("192.168.1.10")
  end

  test "cidr /24" do
    assert {:ok, targets} = Target.parse("192.168.1.0/24")
    assert length(targets) == 256
    assert List.first(targets) == "192.168.1.0"
    assert List.last(targets) == "192.168.1.255"
  end

  test "cidr /32" do
    assert {:ok, ["10.0.0.5"]} = Target.parse("10.0.0.5/32")
  end

  test "cidr network alignment" do
    assert {:ok, targets} = Target.parse("192.168.1.100/30")
    assert targets == ["192.168.1.100", "192.168.1.101", "192.168.1.102", "192.168.1.103"]
  end

  test "invalid ip" do
    assert {:error, _} = Target.parse("256.1.1.1")
    assert {:error, _} = Target.parse("abc")
  end

  test "invalid cidr prefix" do
    assert {:error, _} = Target.parse("192.168.1.0/33")
    assert {:error, _} = Target.parse("192.168.1.0/0")
  end

  test "oversized range" do
    assert {:error, _} = Target.parse("10.0.0.0/8")
  end
end
