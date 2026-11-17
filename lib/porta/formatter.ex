defmodule Porta.Formatter do
  @moduledoc """
  Terminal formatting helpers for scan results.
  """

  alias Porta.ServiceMap

  @doc """
  Returns the application banner.
  """
  @spec banner() :: String.t()
  def banner do
    [
      "                                        ▄▄▄▀▀▀█",
      "                                         █   █",
      "  ▀▄▄▄▄▄▄▄▀     ▀▄▄▄▄▄▄▄▀     ▀▄▄▄▄▄▄▄▀  █ ░ █▄▄▄    ▄▀▀▒▀▀▄█▄▄▄▄▄",
      " ██▓██▀██▓██   ██▓██▀██▓██   ██▓██▀██▓█  █░▒░▀▓█▀▀  █ ░ █   ░█▓██",
      "█▓▒▓     ▓▒▓█ █▓▒▓     ▓▒▓█ █▓▒▓ ▌ ▐ ▓▒  █▒▓▒██░█  █░▒░█    █▓▒▓█",
      "█▒░▒▓   ▓▒░▒█ █▒░▒▓   ▓▒░▒█ █▒░▒▓        █▓█▓░▒▀   █▒▓▒█    █▒░▒░",
      "█░ ░▓   ▓░ ░█ █░ ░▓   ▓░ ░█ █░ ░▓        █ ░ ▒░    █▓█▓█    █░ ░▒",
      "██ ░▒ ▄ ▒░ █   █ ░▒ ▄ ▒░ █  ██ ░░        █░▒░▓▓▄■▄  █░▒░ ▄ ▄█ ░ ▓",
      "█░█░■▄■▄▄▄▀     ▀▄▄▄■▄▄▄▀   ▄▄▀▄▄        ■▀▀▀▄▀▀▀▀    ▀▀▀▀▀  ▀■▄█▄",
      "█▒█▒█                                   ▀▀",
      "█▓▄▓█",
      "▀▀▀▀▀",
      "  Porta v#{Porta.version()}",
      "  Local Network Scanner"
    ]
    |> Enum.join("\n")
    |> Kernel.<>("\n")
  end

  @doc """
  Renders open ports as an aligned table.

  Each result is a `{ip, port}` tuple.
  """
  @spec table([{String.t(), pos_integer()}]) :: String.t()
  def table([]) do
    "No open ports found."
  end

  def table(results) when is_list(results) do
    rows =
      Enum.map(results, fn {ip, port} ->
        [ip, Integer.to_string(port), ServiceMap.lookup(port)]
      end)

    headers = ["IP Address", "Port", "Service"]
    all_rows = [headers | rows]

    widths =
      all_rows
      |> Enum.zip()
      |> Enum.map(fn column ->
        column
        |> Tuple.to_list()
        |> Enum.map(&String.length/1)
        |> Enum.max()
      end)

    [h_ip, h_port, h_service] = widths

    top =
      "┌" <>
        String.duplicate("─", h_ip + 2) <>
        "┬" <>
        String.duplicate("─", h_port + 2) <> "┬" <> String.duplicate("─", h_service + 2) <> "┐"

    header_line =
      "│ " <>
        pad(headers |> Enum.at(0), h_ip) <>
        " │ " <>
        pad(headers |> Enum.at(1), h_port) <>
        " │ " <> pad(headers |> Enum.at(2), h_service) <> " │"

    separator =
      "├" <>
        String.duplicate("─", h_ip + 2) <>
        "┼" <>
        String.duplicate("─", h_port + 2) <> "┼" <> String.duplicate("─", h_service + 2) <> "┤"

    bottom =
      "└" <>
        String.duplicate("─", h_ip + 2) <>
        "┴" <>
        String.duplicate("─", h_port + 2) <> "┴" <> String.duplicate("─", h_service + 2) <> "┘"

    body =
      Enum.map(rows, fn [ip, port, service] ->
        "│ " <>
          pad(ip, h_ip) <> " │ " <> pad(port, h_port) <> " │ " <> pad(service, h_service) <> " │"
      end)

    ([top, header_line, separator] ++ body ++ [bottom])
    |> Enum.join("\n")
  end

  defp pad(value, width) do
    value <> String.duplicate(" ", width - String.length(value))
  end

  @doc """
  Formats a comma-separated port list for display.
  """
  @spec format_ports([pos_integer()]) :: String.t()
  def format_ports(ports) do
    Enum.map_join(ports, ", ", &Integer.to_string/1)
  end
end
