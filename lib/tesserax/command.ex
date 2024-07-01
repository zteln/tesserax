defmodule Tesserax.Command do
  @moduledoc """
  Builds a command to pass to Tesserax.
  """
  defstruct [
    :psm,
    :oem,
    :dpi,
    :log_level,
    :tessdata_dir,
    :user_words,
    :user_patterns,
    :config_file,
    config_variables: [],
    language: [],
    image_path: "-",
    output_path: "-",
    list_languages: false
  ]

  @type t :: %__MODULE__{}

  @log_levels [:all, :trace, :debug, :info, :warn, :error, :fatal, :off]

  @spec new() :: t()
  def new() do
    %__MODULE__{}
  end

  @spec put_image_path(t(), binary()) :: t()
  def put_image_path(%__MODULE__{} = command, image_path) when is_binary(image_path) do
    %{command | image_path: image_path}
  end

  @spec put_language(t(), binary() | list()) :: t()
  def put_language(%__MODULE__{language: languages} = command, language)
      when is_binary(language) do
    %{command | language: [language | languages]}
  end

  def put_language(%__MODULE__{} = command, languages) when is_list(languages) do
    languages
    |> Enum.reverse()
    |> Enum.reduce(command, &put_language(&2, &1))
  end

  @spec put_psm(t(), integer()) :: t()
  def put_psm(%__MODULE__{} = command, psm) when is_integer(psm) do
    %{command | psm: psm}
  end

  @spec put_oem(t(), integer()) :: t()
  def put_oem(%__MODULE__{} = command, oem) when is_integer(oem) do
    %{command | oem: oem}
  end

  @spec put_output_path(t(), binary()) :: t()
  def put_output_path(%__MODULE__{} = command, output_path) when is_binary(output_path) do
    %{command | output_path: output_path}
  end

  @spec put_log_level(t(), atom()) :: t()
  def put_log_level(%__MODULE__{} = command, log_level) when log_level in @log_levels do
    %{command | log_level: log_level}
  end

  @spec put_tessdata_dir(t(), binary()) :: t()
  def put_tessdata_dir(%__MODULE__{} = command, tessdata_dir) when is_binary(tessdata_dir) do
    %{command | tessdata_dir: tessdata_dir}
  end

  @spec put_user_words(t(), binary()) :: t()
  def put_user_words(%__MODULE__{} = command, user_words) when is_binary(user_words) do
    %{command | user_words: user_words}
  end

  @spec put_user_patterns(t(), binary()) :: t()
  def put_user_patterns(%__MODULE__{} = command, user_patterns) when is_binary(user_patterns) do
    %{command | user_patterns: user_patterns}
  end

  @spec put_config_variable(t(), atom(), binary()) :: t()
  def put_config_variable(
        %__MODULE__{config_variables: config_variables} = command,
        type,
        value
      ) do
    config_variables = Keyword.put(config_variables, type, value)
    %{command | config_variables: config_variables}
  end

  @spec put_config_file(t(), binary()) :: t()
  def put_config_file(%__MODULE__{} = command, config_file) when is_binary(config_file) do
    %{command | config_file: config_file}
  end

  @spec list_languages(t()) :: t()
  def list_languages(%__MODULE__{} = command) do
    %{command | list_languages: true}
  end

  @spec convert_to_args(t()) :: list()
  def convert_to_args(%__MODULE__{list_languages: true} = command) do
    ["--list-langs"]
    |> pass_tessdata_dir(command)
  end

  def convert_to_args(%__MODULE__{} = command) do
    []
    |> pass_config_file(command)
    |> pass_log_level(command)
    |> pass_oem(command)
    |> pass_psm(command)
    |> pass_tessdata_dir(command)
    |> pass_config_variables(command)
    |> pass_language(command)
    |> pass_output_path(command)
    |> pass_image_path(command)
  end

  defp pass_image_path(args, %{image_path: image_path}) do
    [image_path | args]
  end

  defp pass_output_path(args, %{output_path: output_path}) do
    [output_path | args]
  end

  defp pass_language(args, %{language: []}), do: args

  defp pass_language(args, %{language: language}) do
    ["-l", convert_language(language) | args]
  end

  defp pass_psm(args, %{psm: nil}), do: args

  defp pass_psm(args, %{psm: psm}) do
    ["--psm", to_string(psm) | args]
  end

  defp pass_oem(args, %{oem: nil}), do: args

  defp pass_oem(args, %{oem: oem}) do
    ["--oem", to_string(oem) | args]
  end

  defp pass_log_level(args, %{log_level: nil}), do: args

  defp pass_log_level(args, %{log_level: log_level}) do
    ["--loglevel", to_string(log_level) | args]
  end

  defp pass_tessdata_dir(args, %{tessdata_dir: nil}), do: args

  defp pass_tessdata_dir(args, %{tessdata_dir: tessdata_dir}) do
    ["--tessdata-dir", tessdata_dir | args]
  end

  defp pass_config_variables(args, %{config_variables: config_variables}) do
    Enum.reduce(config_variables, args, &pass_config_variable(&2, &1))
  end

  defp pass_config_variable(args, {var, val}) do
    ["-c", "#{to_string(var)}=#{val}" | args]
  end

  defp pass_config_file(args, %{config_file: nil}), do: args

  defp pass_config_file(args, %{config_file: config_file}) do
    [config_file | args]
  end

  defp convert_language([language]), do: language

  defp convert_language([language | languages]) do
    "#{language}+#{convert_language(languages)}"
  end
end
