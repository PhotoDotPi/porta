defmodule Porta.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :porta,
      version: @version,
      elixir: "~> 1.20",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  def application do
    [
      mod: {Porta.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    []
  end

  defp escript do
    [
      main_module: Porta.CLI,
      name: "porta"
    ]
  end
end
