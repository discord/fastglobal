defmodule FastGlobal.Mixfile do
  use Mix.Project

  def project do
    [
      app: :fastglobal,
      version: "0.0.1",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      applications: [:syntax_tools]
    ]
  end

  defp deps do
    [
      {:benchfella, "~> 0.3.0", only: :dev}
    ]
  end
end
