defmodule Taiko.MixProject do
  use Mix.Project

  def project do
    [
      app: :taiko,
      version: "0.1.0",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Taiko.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools,
        :httpoison,
        :kazan,
        :porcelain
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.8.1"},
      {:phoenix_html, "~> 4.3.0"},
      {:phoenix_live_reload, "~> 1.6.1", only: :dev},
      {:phoenix_live_dashboard, "~> 0.8.7"},
      {:telemetry_metrics, "~> 1.1.0"},
      {:telemetry_poller, "~> 1.3.0"},
      {:gettext, "~> 1.0.0"},
      {:plug_cowboy, "~> 2.7.4"},

      # Data
      {:httpoison, "~> 2.2.3"},
      {:jason, "~> 1.4.4"},
      {:yaml_elixir, "~> 2.12"},
      # {:timex, "~> 3.7.13"},

      # Data Transforms
      {:morphix, "~> 0.8.1"},

      # Work with OS shells and processes
      {:porcelain, "~> 2.0.3"},

      # Integrations

      # Kubernetes Client
      # {:kazan, "~> 0.11"},
      # There are some unreleased code in master
      {:kazan, github: "obmarg/kazan", ref: "50aceb99c4d1c9bdf2170454cb85b3b1964b5187"},

      # Debugging
      {:recon, "~> 2.5"},
      {:observer_cli, "~> 1.8"},

      # Releases
      {:distillery, "~> 2.1"},

      # Metrics
      {:statix, github: "wschroeder/statix", ref: "cc3f93b73a24c585e5a8a55c987c8b845da40270"},

      # Testing
      {:ex_mock, "~> 0.1.1", only: :test},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get"]
    ]
  end
end
