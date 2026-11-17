defmodule Porta.CLI do
  @moduledoc """
  Command-line entry point for Porta.
  """

  alias Porta.{Arguments, Formatter, Ports, Scanner, Target}

  @help_text """
  Usage: porta TARGET [options]

  TARGET is an IPv4 address or CIDR range (e.g. 192.168.1.10 or 192.168.1.0/24).

  Options:
    --ports, -p        Comma-separated ports and/or ranges (e.g. 22,80,443 or 1-1024)
    --timeout, -t      TCP connection timeout in milliseconds (default: 1000)
    --concurrency, -c  Maximum concurrent connection tasks (default: 50)
    --help, -h         Show this help message
    --version, -v      Show version information

  Examples:
    porta 192.168.1.10
    porta 192.168.1.10 --ports 22,80,443
    porta 192.168.1.0/24 --ports 80,443 --timeout 1000
    porta 192.168.1.10 --ports 1-1024 --concurrency 100
  """

  def main(argv) do
    _ = Application.ensure_all_started(:porta)

    case Arguments.parse(argv) do
      {:help} ->
        IO.puts(:stderr, @help_text)
        System.halt(0)

      {:version} ->
        IO.puts("Porta #{Porta.version()}")
        System.halt(0)

      {:error, message} ->
        IO.puts(:stderr, "Error: #{message}")
        System.halt(1)

      {:ok, opts} ->
        run(opts)
    end
  end

  defp run(opts) do
    IO.puts(Porta.Formatter.banner())

    case Target.parse(opts.target) do
      {:ok, targets} ->
        ports =
          case opts.ports do
            nil -> Ports.default()
            list when is_list(list) -> list
          end

        IO.puts("Target: #{opts.target}")
        IO.puts("Ports:  #{Formatter.format_ports(ports)}")
        IO.puts("Status: Scan completed")
        IO.puts("")

        results = Scanner.scan(targets, ports, opts.timeout, opts.concurrency)

        IO.puts(Formatter.table(results))
        IO.puts("")
        IO.puts("#{length(results)} open ports found.")
        IO.puts("Scan completed successfully.")
        System.halt(0)

      {:error, message} ->
        IO.puts(:stderr, "Error: #{message}")
        System.halt(1)
    end
  rescue
    e ->
      IO.puts(:stderr, "Error: #{Exception.message(e)}")
      System.halt(1)
  end
end
