defmodule SortedSet.Mixfile do
  use Mix.Project

  def project do
    [app: :sorted_set,
     version: "1.0.0",
     source_url: "https://github.com/SenecaSystems/sorted_set",
     elixir: "~> 1.0",
     description: "SortedSet implementation for Elixir",
     licenses: ["MIT"],
     deps: deps,
     package: package
     ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:red_black_tree, "~> 1.0"},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.7", only: :dev}
    ]
  end

  defp package do
    [
     files: ["lib", "mix.exs", "README.md", "LICENSE"],
     contributors: ["Seneca Systems"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/SenecaSystems/sorted_set"}
    ]
  end
end
