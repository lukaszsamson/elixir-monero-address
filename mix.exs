defmodule MoneroAddress.MixProject do
  use Mix.Project

  @version "1.0.0"
  @source_url "https://github.com/lukaszsamson/elixir-monero-address"

  def project do
    [
      app: :monero_address,
      version: @version,
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "MoneroAddress",
      source_url: @source_url,
      docs: [extras: ["README.md"], main: "readme",
            source_ref: "v#{@version}",
            source_url: @source_url]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:sha3, github: "puzza007/erlang-sha3", branch: "develop"},
      {:ex_doc, "~> 0.19", only: :dev},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end

  defp description do
    """
    Library for decoding and validating Monero addresses.
    """
  end

  defp package do
    [
      name: :monero_address,
      files: ["lib", "mix.exs", ".formatter.exs", "README*", "LICENSE*"],
      maintainers: ["Łukasz Samson"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
    ]
  end
end
