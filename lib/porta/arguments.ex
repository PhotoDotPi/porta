defmodule Porta.Arguments do
  @moduledoc """
  CLI argument parsing and validation.
  """

  @max_concurrency 1000
  @default_timeout 1000
  @default_concurrency 50

  @switches [
    ports: :string,
    timeout: :integer,
    concurrency: :integer,
    help: :boolean,
    version: :boolean
  ]

  @aliases [
    h: :help,
    v: :version,
    p: :ports,
    t: :timeout,
    c: :concurrency
  ]

  @doc """
  Parses `argv` and validates all options.

  Returns `{:ok, options}`, `{:help}`, `{:version}`, or `{:error, message}`.
  """
  @spec parse([String.t()]) ::
          {:ok, map()} | {:help} | {:version} | {:error, String.t()}
  def parse(argv) do
    {opts, args, errors} = OptionParser.parse(argv, switches: @switches, aliases: @aliases)

    cond do
      errors != [] ->
        {:error, format_parse_errors(errors)}

      Keyword.get(opts, :help, false) ->
        {:help}

      Keyword.get(opts, :version, false) ->
        {:version}

      true ->
        validate(opts, args)
    end
  end

  defp validate(opts, args) do
    with {:ok, target} <- validate_target(args),
         {:ok, ports} <- validate_ports(Keyword.get(opts, :ports)),
         {:ok, timeout} <- validate_timeout(Keyword.get(opts, :timeout)),
         {:ok, concurrency} <- validate_concurrency(Keyword.get(opts, :concurrency)) do
      {:ok,
       %{
         target: target,
         ports: ports,
         timeout: timeout,
         concurrency: concurrency
       }}
    end
  end

  defp validate_target([target]) do
    case Porta.Target.parse(target) do
      {:ok, _} -> {:ok, target}
      {:error, _} = err -> err
    end
  end

  defp validate_target([]), do: {:error, "missing target argument"}
  defp validate_target([_ | _]), do: {:error, "expected a single target argument"}

  defp validate_ports(nil), do: {:ok, nil}

  defp validate_ports(str) do
    Porta.Ports.parse(str)
  end

  defp validate_timeout(nil), do: {:ok, @default_timeout}

  defp validate_timeout(n) when is_integer(n) and n > 0 and n <= 60_000 do
    {:ok, n}
  end

  defp validate_timeout(n) when is_integer(n) do
    {:error, "timeout must be between 1 and 60000 milliseconds"}
  end

  defp validate_timeout(_) do
    {:error, "timeout must be an integer"}
  end

  defp validate_concurrency(nil), do: {:ok, @default_concurrency}

  defp validate_concurrency(n) when is_integer(n) and n > 0 and n <= @max_concurrency do
    {:ok, n}
  end

  defp validate_concurrency(n) when is_integer(n) do
    {:error, "concurrency must be between 1 and #{@max_concurrency}"}
  end

  defp validate_concurrency(_) do
    {:error, "concurrency must be an integer"}
  end

  defp format_parse_errors(errors) do
    errors
    |> Enum.map(fn
      {opt, reason} -> "#{opt}: #{reason}"
      other -> to_string(other)
    end)
    |> Enum.join("; ")
  end
end
