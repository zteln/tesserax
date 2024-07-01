defmodule Tesserax do
  @moduledoc """
  A wrapper around Tesseract OCR command line program.
  """
  alias Tesserax.Command
  require Logger

  @spec run(Command.t() | list()) ::
          {:ok, term()} | {:error, :non_zero_exit_status}
  @spec run(Command.t() | list(), fun()) ::
          {:ok, term()} | {:error, :non_zero_exit_status}
  def run(command_or_args, parser \\ &parse_data/1)

  def run(%Command{} = command, parser) do
    Command.convert_to_args(command)
    |> run(parser)
  end

  def run(args, parser) when is_list(args) do
    args
    |> open_tesseract_port()
    |> await_response()
    |> handle_response(parser)
  end

  defp handle_response(response, parser) do
    case response do
      {:ok, data} ->
        {:ok, parser.(data)}

      {:error, _exit_status} ->
        {:error, :non_zero_exit_status}
    end
  end

  defp open_tesseract_port(args) do
    Port.open({:spawn_executable, tesseract_executable()}, [:binary, :exit_status, args: args])
  end

  defp await_response(port, data \\ "") do
    receive do
      {^port, {:data, data}} ->
        await_response(port, data)

      {^port, {:exit_status, 0}} ->
        {:ok, data}

      {^port, {:exit_status, exit_status}} ->
        Logger.error("Received exit status #{exit_status} from Tesseract OCR.")
        {:error, exit_status}
    end
  end

  defp parse_data(data) do
    String.split(data, "\n", trim: true)
  end

  defp tesseract_executable,
    do:
      Application.get_env(:tesserax, :tesseract_path, System.find_executable("tesseract")) ||
        raise("Tesseract OCR executable not found or provided")
end
