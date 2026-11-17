defmodule Porta do
  @moduledoc """
  Porta is a lightweight TCP port scanner for authorized local networks.
  """

  @version "0.1.0"

  @doc "Returns the application version."
  @spec version() :: String.t()
  def version, do: @version
end
