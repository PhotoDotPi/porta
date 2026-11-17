defmodule Porta.Ports do
  @moduledoc """
  Parses and normalizes TCP port specifications.
  """

  @min_port 1
  @max_port 65535

  @doc """
  Returns the default list of ports to scan when none are specified.
  """
  @spec default() :: [pos_integer()]
  def default do
    [
      21,
      22,
      23,
      25,
      53,
      80,
      110,
      135,
      139,
      143,
      443,
      445,
      993,
      995,
      1433,
      1521,
      3306,
      3389,
      5432,
      5900,
      6379,
      8080,
      8443
    ]
  end

  @doc """
  Parses a port specification string into a sorted, de-duplicated list.

  Supports single ports, comma-separated lists, and ranges such as `1-1024`.
  """
  @spec parse(String.t()) :: {:ok, [pos_integer()]} | {:error, String.t()}
  def parse(input) when is_binary(input) do
    input = String.trim(input)

    if input == "" do
      {:error, "port specification must not be empty"}
    else
      parts = String.split(input, ",", trim: true)

      with {:ok, collected} <- collect_parts(parts, []),
           normalized <- collected |> Enum.sort() |> Enum.uniq() do
        if normalized == [] do
          {:error, "port specification must not be empty"}
        else
          {:ok, normalized}
        end
      end
    end
  end

  def parse(_), do: {:error, "port specification must be a string"}

  defp collect_parts([], acc), do: {:ok, acc}

  defp collect_parts([part | rest], acc) do
    part = String.trim(part)

    cond do
      part == "" ->
        {:error, "empty port entry"}

      String.contains?(part, "-") ->
        case parse_range(part) do
          {:ok, range_ports} -> collect_parts(rest, acc ++ range_ports)
          {:error, _} = err -> err
        end

      true ->
        case parse_single(part) do
          {:ok, port} -> collect_parts(rest, [port | acc])
          {:error, _} = err -> err
        end
    end
  end

  defp parse_single(part) do
    case Integer.parse(part) do
      {n, ""} when n >= @min_port and n <= @max_port ->
        {:ok, n}

      {n, ""} ->
        {:error, "port out of range (1-65535): #{n}"}

      _ ->
        {:error, "invalid port: #{part}"}
    end
  end

  defp parse_range(part) do
    case String.split(part, "-", parts: 2) do
      [a_str, b_str] ->
        with {a, ""} <- Integer.parse(String.trim(a_str)),
             {b, ""} <- Integer.parse(String.trim(b_str)),
             true <- a >= @min_port and a <= @max_port,
             true <- b >= @min_port and b <= @max_port,
             true <- a <= b do
          {:ok, Enum.to_list(a..b)}
        else
          {_, _} -> {:error, "invalid port range: #{part}"}
          false -> {:error, "invalid port range: #{part}"}
          _ -> {:error, "invalid port range: #{part}"}
        end

      _ ->
        {:error, "invalid port range: #{part}"}
    end
  end
end
