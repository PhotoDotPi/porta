defmodule Porta.FormatterTest do
  use ExUnit.Case, async: true

  alias Porta.Formatter

  test "empty results" do
    assert Formatter.table([]) == "No open ports found."
  end

  test "table contains entries and unknown service" do
    out = Formatter.table([{"127.0.0.1", 9999}])
    assert String.contains?(out, "127.0.0.1")
    assert String.contains?(out, "9999")
    assert String.contains?(out, "unknown")
  end

  test "table multiple rows" do
    out = Formatter.table([{"10.0.0.1", 22}, {"10.0.0.1", 80}])
    assert String.contains?(out, "SSH")
    assert String.contains?(out, "HTTP")
  end

  test "format_ports" do
    assert Formatter.format_ports([22, 80, 443]) == "22, 80, 443"
  end

  test "banner" do
    assert String.contains?(Formatter.banner(), "Porta")
  end
end
