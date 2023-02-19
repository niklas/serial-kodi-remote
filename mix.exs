defmodule SerialKodiRemote.MixProject do
  use Mix.Project

  def project do
    [
      app: :serial_kodi_remote,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      releases: releases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :websockex],
      mod: {SerialKodiRemote.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:circuits_uart, "~> 1.3"},
      {:websockex, "~> 0.4.2"},
      {:jason, "~> 1.1"},
      {:toml, "~> 0.6.1"},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false}
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
             transforms: []
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
