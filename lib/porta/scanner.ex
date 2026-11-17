defmodule Porta.Scanner do
  @moduledoc """
  Bounded-concurrency TCP connect scanner.
  """

  @default_timeout 1000

  @doc """
  Scans the given targets and ports, returning a list of `{ip, port}` tuples
  for ports that accepted a TCP connection.
  """
  @spec scan([String.t()], [pos_integer()], pos_integer(), pos_integer()) ::
          [{String.t(), pos_integer()}]
  def scan(targets, ports, timeout, concurrency)
      when is_list(targets) and is_list(ports) do
    timeout = if is_integer(timeout) and timeout > 0, do: timeout, else: @default_timeout
    concurrency = normalize_concurrency(concurrency)

    ensure_supervisor()

    work_items =
      for ip <- targets, port <- ports do
        {ip, port}
      end

    work_items
    |> Task.async_stream(
      fn {ip, port} -> check(ip, port, timeout) end,
      max_concurrency: concurrency,
      timeout: timeout + 500,
      on_timeout: :kill_task
    )
    |> Enum.reduce([], fn
      {:ok, {:open, ip, port}}, acc -> [{ip, port} | acc]
      {:ok, _}, acc -> acc
      {:exit, _}, acc -> acc
    end)
    |> Enum.reverse()
  end

  def scan(_, _, _, _), do: []

  defp normalize_concurrency(n) when is_integer(n) and n > 0 and n <= 1000, do: n
  defp normalize_concurrency(_), do: 50

  defp ensure_supervisor do
    case Process.whereis(Porta.TaskSupervisor) do
      nil ->
        {:ok, _pid} = Task.Supervisor.start_link(name: Porta.TaskSupervisor)
        :ok

      _ ->
        :ok
    end
  rescue
    _ -> :ok
  end

  @doc false
  @spec check(String.t(), pos_integer(), pos_integer()) ::
          {:open, String.t(), pos_integer()} | {:closed, String.t(), pos_integer()}
  def check(ip, port, timeout) do
    opts = [:binary, active: false]

    result =
      try do
        case :gen_tcp.connect(String.to_charlist(ip), port, opts, timeout) do
          {:ok, socket} ->
            :gen_tcp.close(socket)
            {:open, ip, port}

          {:error, _reason} ->
            {:closed, ip, port}
        end
      rescue
        _ -> {:closed, ip, port}
      catch
        :exit, _ -> {:closed, ip, port}
      end

    result
  end
end
