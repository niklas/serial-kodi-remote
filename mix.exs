defmodule SerialKodiRemote.MixProject do
  use Mix.Project

  def project do
    [
      app: :serial_kodi_remote,
      version: "0.1.0",
      elixir: "~> 1.19",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      releases: releases(),
      aliases: aliases(),
      deps: deps(),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      listeners: [Phoenix.CodeReloader]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {SerialKodiRemote.Application, []},
      extra_applications: [:logger, :runtime_tools, :websockex]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
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
      {:circuits_uart, "~> 1.3"},
      {:websockex, "~> 0.5.1"},
      {:jason, "~> 1.2"},
      {:toml, "~> 0.7.0"},
      {:httpoison, "~> 2.2.1"},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:phoenix, "~> 1.8.7"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.1.0"},
      {:lazy_html, ">= 0.1.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.3", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 1.0"},
      {:dns_cluster, "~> 0.2.0"},
      {:bandit, "~> 1.5"}
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
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["compile", "tailwind serial_kodi_remote", "esbuild serial_kodi_remote"],
      "assets.deploy": [
        "tailwind serial_kodi_remote --minify",
        "esbuild serial_kodi_remote --minify",
        "phx.digest"
      ],
      precommit: ["compile --warnings-as-errors", "deps.unlock --unused", "format", "test"]
    ]
  end

  defp releases do
    [
      skr: [
        include_executables_for: [:unix],
        applications: [runtime_tools: :permanent],
        config_providers: [
          {Toml.Provider,
           [
             path: {:system, "HOME", "/.serial_kodi_remote/skr.toml"},
             transforms: [LogLevelStringToAtom]
           ]}
        ],
        steps: [:assemble, &copy_config_file/1, :tar]
      ]
    ]
  end

  defp copy_config_file(release) do
    release
  end
end
