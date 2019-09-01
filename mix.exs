defmodule Solution.MixProject do
  use Mix.Project

  @source_url "https://github.com/Qqwy/elixir_solution"

  def project do
    [
      app: :solution,
      version: "1.0.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      description: description(),
      package: package(),
      source_url: @source_url,
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:stream_data, "~> 0.1", only: :test},
      {:ex_doc, "~> 0.19", only: [:docs], runtime: false},
      # Inch CI documentation quality test.
      {:inch_ex, ">= 0.0.0", only: [:docs]}
    ]
  end

  defp elixirc_paths(_), do: ["lib"]

  defp description do
    """
    A Macro-based solution to working with ok/error tuples (AKA result tuples, success tuples or tagged statuses) in `case` and `with` statements and in collections.
    """
  end

  defp package do
    # These are the default files included in the package
    [
      name: :solution,
      files: ["lib", "mix.exs", "README*", "LICENSE"],
      maintainers: ["Wiebe-Marten Wijnja/Qqwy"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      main: "readme",
      logo: "brand/logo_inverted.png",
      extras: ["README.md"]
    ]
  end
end
