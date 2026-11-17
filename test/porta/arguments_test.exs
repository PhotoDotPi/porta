defmodule Porta.ArgumentsTest do
  use ExUnit.Case, async: true

  alias Porta.Arguments

  test "parses a bare target" do
    assert {:ok, opts} = Arguments.parse(["192.168.1.10"])
    assert opts.target == "192.168.1.10"
    assert opts.ports == nil
    assert opts.timeout == 1000
    assert opts.concurrency == 50
  end

  test "parses ports, timeout, concurrency" do
    assert {:ok, opts} =
             Arguments.parse([
               "10.0.0.1",
               "--ports",
               "22,80",
               "--timeout",
               "500",
               "--concurrency",
               "10"
             ])

    assert opts.ports == [22, 80]
    assert opts.timeout == 500
    assert opts.concurrency == 10
  end

  test "help flag" do
    assert Arguments.parse(["--help"]) == {:help}
  end

  test "version flag" do
    assert Arguments.parse(["--version"]) == {:version}
  end

  test "missing target" do
    assert {:error, _} = Arguments.parse([])
  end

  test "invalid target" do
    assert {:error, _} = Arguments.parse(["999.1.1.1"])
  end

  test "invalid cidr" do
    assert {:error, _} = Arguments.parse(["192.168.1.0/33"])
  end

  test "invalid port spec" do
    assert {:error, _} = Arguments.parse(["127.0.0.1", "--ports", "0"])
  end

  test "invalid timeout" do
    assert {:error, _} = Arguments.parse(["127.0.0.1", "--timeout", "0"])
  end

  test "invalid concurrency" do
    assert {:error, _} = Arguments.parse(["127.0.0.1", "--concurrency", "0"])
  end

  test "too many positional args" do
    assert {:error, _} = Arguments.parse(["127.0.0.1", "127.0.0.2"])
  end
end
