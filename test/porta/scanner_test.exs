defmodule Porta.ScannerTest do
  use ExUnit.Case, async: false

  alias Porta.Scanner

  defp start_server(port) do
    {:ok, listen} = :gen_tcp.listen(port, [:binary, active: false, reuseaddr: true])
    spawn(fn -> accept_loop(listen) end)
    listen
  end

  defp accept_loop(listen) do
    case :gen_tcp.accept(listen) do
      {:ok, socket} ->
        :gen_tcp.close(socket)
        accept_loop(listen)

      {:error, _} ->
        :ok
    end
  end

  test "detects open port" do
    listen = start_server(0)
    {:ok, {_ip, port}} = :inet.sockname(listen)

    results = Scanner.scan(["127.0.0.1"], [port], 1000, 10)
    assert {"127.0.0.1", ^port} = List.first(results)
    :gen_tcp.close(listen)
  end

  test "closed port returns no result" do
    # Pick a port unlikely open; use a high port and ensure no server
    port = 39871
    results = Scanner.scan(["127.0.0.1"], [port], 200, 10)
    assert results == []
  end

  test "multiple concurrent attempts consistent" do
    listen = start_server(0)
    {:ok, {_ip, port}} = :inet.sockname(listen)

    ports = [port, 39872, 39873]
    results = Scanner.scan(["127.0.0.1"], ports, 200, 10)
    assert length(results) == 1
    assert List.first(results) == {"127.0.0.1", port}
    :gen_tcp.close(listen)
  end
end
