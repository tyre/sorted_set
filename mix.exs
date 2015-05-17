defmodule SortedSet.Mixfile do
  use Mix.Project

  def project do
    [app: :sorted_set,
     version: "0.1.0",
     source_url: "https://github.com/SenecaSystems/sorted_set",
     elixir: "~> 1.0",
     description: "SortedSet implementation for Elixir",
     licenses: ["MIT"],
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.7", only: :dev}
    ]
  end
end
