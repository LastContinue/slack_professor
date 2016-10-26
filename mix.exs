defmodule SlackProfessor.Mixfile do
  use Mix.Project

  def project do
    [app: :slack_professor,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()
   ]
  end

  def application do
    [applications: [:logger, :slack, :poolboy],
     mod: {SlackProfessor, []}]
  end

  defp deps do
    [{:slack, "~> 0.7.1"},
     {:poolboy, "~> 1.5"},
     {:websocket_client, git: "https://github.com/jeremyong/websocket_client"},
     {:pokerap, "~> 0.0.11"},
     {:ex_doc, "~> 0.14", only: :dev}
  ]
  end
end
