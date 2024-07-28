defmodule Tesserax.Command do
  @moduledoc """
  Builds a command containing information about Tesseract and which image to read.

  ## Examples
      
      command = Tesserax.Command.make_command(
                  image: File.read("path/to/image"), 
                  languages: ["eng", "hin"], 
                  tessdata: "path/to/tessdata/dir",
                  config: "path/to/config/file",
                  psm: psm_value,
                  oem: oem_value
                )

      Tesserax.Command.image(command)
      #=> <<...>>

      Tesserax.Command.languages(command)
      #=> "eng+hin"

      Tesserax.Command.tessdata(command)
      #=> "path/to/tessdata/dir"

      Tesserax.Command.config(command)
      #=> "path/to/config/file"

      Tesserax.Command.psm(command)
      #=> psm_value

      Tesserax.Command.oem(command)
      #=> oem_value
  """
  defstruct [
    :image,
    :languages,
    :tessdata,
    :config,
    :psm,
    :oem
  ]

  @type t :: %__MODULE__{
          image: binary(),
          languages: String.t(),
          tessdata: String.t(),
          config: String.t(),
          psm: integer(),
          oem: integer()
        }

  @doc """
  Builds a command with available options: `:image`, `:languages`, `:tessdata`, `:config`, `:psm`, `:oem`.
    * `:image` is either the contents of an image (PNG format), or the path to an image.
    * `:languages` is the languages that Tesseract should recognize with, either a list or a string.
    * `:tessdata` is the path to tessdata dir.
    * `:config` is the path to the config file.
    * `:psm` is an integer representing Page Segmentation Mode in Tesseract.
    * `:oem` is an integer representing Ocr Engine Mode in Tesseract.
  Ignores invalid options.

  ## Examples

      Tesserax.Command.make_command(image: File.read!("path/to/image"), languages: ["eng", "hin"], tessdata: "path/to/tessdata/dir", config: "path/to/config/file", psm: 0, oem: 0)
  """
  @spec make_command(t(), keyword()) :: t()
  def make_command(command \\ %__MODULE__{}, opts) do
    opts
    |> Keyword.take([:image, :languages, :tessdata, :config, :psm, :oem])
    |> Enum.reduce(command, fn opt, command ->
      case cast_opt(opt) do
        {key, val} -> %{command | {key, val}}
        :invalid_opt -> command
      end
    end)
  end

  defp cast_opt({:image, image} = opt) when is_binary(image), do: opt
  defp cast_opt({:languages, languages}) when is_binary(languages), do: {:languages, languages}
  defp cast_opt({:languages, languages}), do: {:languages, Enum.join(languages, "+")}
  defp cast_opt({:tessdata, tessdata} = opt) when is_binary(tessdata), do: opt
  defp cast_opt({:config, config} = opt) when is_binary(config), do: opt
  defp cast_opt({:psm, psm} = opt) when is_integer(psm), do: opt
  defp cast_opt({:oem, oem} = opt) when is_integer(oem), do: opt
  defp cast_opt(_opt), do: :invalid_opt

  @doc """
  Fetches image field from the command.
  """
  @spec image(t()) :: binary()
  def image(%__MODULE__{image: image}), do: image

  @doc """
  Fetches the languages from the command.
  """
  @spec languages(t()) :: String.t()
  def languages(%__MODULE__{languages: languages}), do: languages

  @doc """
  Fetches the tessdata path from the command.
  """
  @spec tessdata(t()) :: String.t()
  def tessdata(%__MODULE__{tessdata: tessdata}), do: tessdata

  @doc """
  Fetches the config file path from the command.
  """
  @spec config(t()) :: String.t()
  def config(%__MODULE__{config: config}), do: config

  @doc """
  Fetches the psm value from the command.
  """
  @spec psm(t()) :: integer()
  def psm(%__MODULE__{psm: psm}), do: psm

  @doc """
  Fetches the oem value from the command.
  """
  @spec oem(t()) :: integer()
  def oem(%__MODULE__{oem: oem}), do: oem

  @doc """
  Fetches all values from a command.
  """
  @spec values(t()) :: list()
  def values(%__MODULE__{} = command) do
    command
    |> Map.from_struct()
    |> Map.to_list()
  end

  @doc """
  Prepares a command. Returns a map with non-`nil` values from the command.
  """
  @spec prepare_command(t()) :: map()
  def prepare_command(command) do
    command
    |> values()
    |> Enum.reject(&is_nil(elem(&1, 1)))
    |> Enum.into(%{})
  end
end
