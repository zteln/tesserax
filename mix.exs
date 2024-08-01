defmodule Tesserax.MixProject do
  use Mix.Project

  def project do
    [
      app: :tesserax,
      version: "0.1.4",
      elixir: "~> 1.14",
      compilers: [:elixir_make] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      package: package(),
      name: "Tesserax",
      description: description(),
      deps: deps(),
      docs: docs(),
      source_url: "https://github.com/zteln/tesserax"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      name: "tesserax",
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE src Makefile),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/zteln/tesserax"}
    ]
  end

  defp description do
    "A wrapper around the [Tesseract OCR Engine](https://github.com/tesseract-ocr/tesseract)."
  end

  defp docs do
    [
      main: "Tesserax",
      extras: ["README.md", "LICENSE"]
    ]
  end

  defp deps do
    [
      {:elixir_make, "~> 0.8.4", runtime: false},
      {:ex_doc, "~> 0.34.2", only: :dev, runtime: false}
    ]
  end
end
