defmodule FleetApi.Mixfile do
  use Mix.Project

  def project do
    [app: :fleet_api,
     version: "0.0.2",
     elixir: "~> 1.0",
     deps: deps,
     description: description,
     package: package,
     docs: [readme: "README.md",
            main: "README",
            source_url: "https://github.com/jordan0day/fleet-api"]]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [ applications: [:logger, :httpoison],
      env: [etcd: [fix_port_number: true, api_port: 7002]]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:httpoison, "0.6.2"},
      {:poison, "1.3.1"},
      {:exvcr, "0.4.0", only: :test},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.7", only: :dev}]
  end

  defp description do
    "A simple wrapper for the Fleet API. Can be used with etcd tokens or via direct node URLs."
  end

  defp package do
    [contributors: ["Jordan Day"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/jordan0day/fleet-api.git"}]
  end
end
