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
      escript: escript(),
      docs: docs()
    ]
  end

  def application do
    [
      mod: {Porta.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.38", only: :dev, runtime: false}
    ]
  end

  defp escript do
    [
      main_module: Porta.CLI,
      name: "porta"
    ]
  end

  defp docs do
    [
      main: "Porta",
      name: "Porta",
      source_url: "https://github.com/PhotoDotPi/porta",
      homepage_url: "https://photodotpi.github.io/porta/"
    ]
  end
end
