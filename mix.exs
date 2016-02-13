defmodule Proxy.Mixfile do
  use Mix.Project

  def project do
    [app: :proxy,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     aliases: aliases
   ]
  end

  defp aliases do
    [serve: ["run", &Proxy.serve/1]]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications:
      [
        :logger,
        :cowboy,
        :plug,
        :httpoison,
        :socket
      ],
      mod: {Proxy, []}
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:cowboy,    "~> 1.0.4"},
      {:plug,      "~> 1.1.0"},
      {:httpoison, "~> 0.8.0"},
      {:socket,    "~> 0.3.0"}
    ]
  end
end
