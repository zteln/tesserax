defmodule Tesserax do
  @moduledoc """
  Execute commands against the Tesseract OCR Engine.
  Able to either recognize text in images loaded in memory or by providing a path to the image.
  """
  alias Tesserax.{Command, NIF}

  @doc """
  Runs a command against the NIF with the image loaded in memory. Requires the image to be image/png format.

  ## Examples

      {:ok, %{text: text, confidence: confidence}} = Tesserax.read_from_mem(command)
  """
  @spec read_from_mem(Command.t()) :: {:ok, map()} | {:error, atom()}
  def read_from_mem(command) do
    command
    |> Command.prepare_command()
    |> NIF.run_mem()
  end

  @doc """
  Runs a command against the NIF with a path to image. 

  ## Examples

      {:ok, %{text: text, confidence: confidence}} = Tesserax.read_from_file(command)
  """
  @spec read_from_file(Command.t()) :: {:ok, map()} | {:error, atom()}
  def read_from_file(%Command{} = command) do
    command
    |> Command.prepare_command()
    |> NIF.run_file()
  end

  @doc """
  Lists the languages available to tesseract via NIF.
  Accepts path to tessdata (optional).

  ## Examples 

      {:ok, languages} = Tesserax.list_languages()

      {:ok, languages} = Tesserax.list_languages("/path/to/tessdata/dir/")
  """
  @spec list_languages(binary() | nil) :: {:ok, list()} | {:error, atom()}
  def list_languages(tessdata \\ %{})

  def list_languages(tessdata) when is_binary(tessdata) do
    list_languages(%{tessdata: tessdata})
  end

  def list_languages(tessdata) do
    NIF.list_languages(tessdata)
  end
end
