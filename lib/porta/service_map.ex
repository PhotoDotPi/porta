defmodule Porta.ServiceMap do
  @moduledoc """
  Lightweight mapping of common TCP ports to conventional service names.
  """

  @services %{
    21 => "FTP",
    22 => "SSH",
    23 => "Telnet",
    25 => "SMTP",
    53 => "DNS",
    80 => "HTTP",
    110 => "POP3",
    135 => "MSRPC",
    139 => "NetBIOS",
    143 => "IMAP",
    443 => "HTTPS",
    445 => "SMB",
    993 => "IMAPS",
    995 => "POP3S",
    1433 => "MSSQL",
    1521 => "Oracle",
    3306 => "MySQL",
    3389 => "RDP",
    5432 => "PostgreSQL",
    5900 => "VNC",
    6379 => "Redis",
    8080 => "HTTP-ALT",
    8443 => "HTTPS-ALT"
  }

  @doc """
  Returns the conventional service name for a port, or `"unknown"`.
  """
  @spec lookup(pos_integer()) :: String.t()
  def lookup(port) when is_integer(port) do
    Map.get(@services, port, "unknown")
  end

  def lookup(_), do: "unknown"
end
