defmodule Tesserax.NIF do
  @moduledoc false
  @on_load :load_nifs

  @app Mix.Project.config()[:app]

  @doc false
  def load_nifs do
    @app
    |> :code.priv_dir()
    |> :lists.append(~c"/tesseract_api")
    |> :erlang.load_nif(0)
  end

  @doc false
  @spec run_mem(map()) :: {:ok, map()} | {:error, atom()}
  def run_mem(_command),
    do: :erlang.nif_error(:nif_not_loaded)

  @doc false
  @spec run_file(map()) :: {:ok, map()} | {:error, atom()}
  def run_file(_command),
    do: :erlang.nif_error(:nif_not_loaded)

  @doc false
  @spec list_languages(charlist()) :: {:ok, list()} | {:error, atom()}
  def list_languages(_tessdata), do: :erlang.nif_error(:nif_not_loaded)
end
