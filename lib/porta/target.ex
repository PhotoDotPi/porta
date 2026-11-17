defmodule Porta.Target do
  @moduledoc """
  Parses and expands IPv4 target specifications.
  """

  @max_targets 1024

  @doc """
  Parses a target string into a list of IPv4 address strings.

  Supports a single IPv4 address or CIDR notation.
  """
  @spec parse(String.t()) :: {:ok, [String.t()]} | {:error, String.t()}
  def parse(input) when is_binary(input) do
    input = String.trim(input)

    if String.contains?(input, "/") do
      parse_cidr(input)
    else
      parse_single(input)
    end
  end

  def parse(_), do: {:error, "target must be a string"}

  defp parse_single(input) do
    case :inet.parse_address(String.to_charlist(input)) do
      {:ok, {a, b, c, d}}
      when is_integer(a) and is_integer(b) and is_integer(c) and is_integer(d) ->
        {:ok, [input]}

      _ ->
        {:error, "invalid IPv4 address: #{input}"}
    end
  end

  defp parse_cidr(input) do
    with [ip_str, prefix_str] <- String.split(input, "/", parts: 2),
         {:ok, {a, b, c, d}} <- :inet.parse_address(String.to_charlist(ip_str)),
         {prefix, ""} <- Integer.parse(String.trim(prefix_str)),
         true <- prefix >= 1 and prefix <= 32 do
      ip_int = ip_to_int({a, b, c, d})
      host_bits = 32 - prefix

      mask =
        if prefix == 0,
          do: 0,
          else: Bitwise.bsl(0xFFFFFFFF, host_bits) |> Bitwise.band(0xFFFFFFFF)

      network = Bitwise.band(ip_int, mask)
      broadcast = Bitwise.bor(network, Bitwise.bsl(1, host_bits) - 1)
      count = broadcast - network + 1

      if count > @max_targets do
        {:error,
         "target range contains #{count} hosts, which exceeds the limit of #{@max_targets}"}
      else
        targets =
          for n <- network..broadcast do
            int_to_ip(n)
          end

        {:ok, targets}
      end
    else
      _ -> {:error, "invalid CIDR notation: #{input}"}
    end
  end

  defp ip_to_int({a, b, c, d}) do
    Bitwise.bsl(a, 24) + Bitwise.bsl(b, 16) + Bitwise.bsl(c, 8) + d
  end

  defp int_to_ip(n) do
    a = Bitwise.band(Bitwise.bsr(n, 24), 0xFF)
    b = Bitwise.band(Bitwise.bsr(n, 16), 0xFF)
    c = Bitwise.band(Bitwise.bsr(n, 8), 0xFF)
    d = Bitwise.band(n, 0xFF)
    "#{a}.#{b}.#{c}.#{d}"
  end
end
