defmodule SlackProfessor.Mixfile do
  use Mix.Project

  def project do
    [app: :slack_professor,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     # Docs
     name: "SlackProfessor",
     source_url: "https://github.com/lastcontinue/slack_professor",
     homepage_url: "https://github.com/lastcontinue/slack_professor",
     docs: [ main: "readme",
       extras: ["README.md"]]
    ]
  end

  def application do
    [applications: [:logger, :slack, :poolboy],
     mod: {SlackProfessor, []}]
  end

  defp deps do
    [{:slack, "~> 0.8.0"},
     {:poolboy, "~> 1.5"},
     {:pokerap, "~> 0.0.12"},
     {:ex_doc, "~> 0.14", only: :dev}
  ]
  end
end
