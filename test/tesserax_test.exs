defmodule TesseraxTest do
  use ExUnit.Case
  alias Tesserax.Command

  @test_image "./test/fixtures/test.png"
  @output_test_pdf "./test/fixtures/test_output.pdf"

  setup_all do
    on_exit(fn -> File.rm(@output_test_pdf) end)
    :ok
  end

  test "tesseract --list-langs" do
    command = Command.new() |> Command.list_languages()

    assert {:ok, result} = Tesserax.run(command)
    assert is_list(result)
  end

  test "tesseract ./test/fixtures/test.png - -l eng" do
    command =
      Command.new()
      |> Command.put_image_path(@test_image)
      |> Command.put_language("eng")

    assert {:ok, ["Elixir"]} == Tesserax.run(command)
  end

  test "tesseract ./test/fixtures/test.png ./test/fixtures/test_output -l eng pdf" do
    command =
      Command.new()
      |> Command.put_image_path(@test_image)
      |> Command.put_output_path("./test/fixtures/test_output")
      |> Command.put_language("eng")
      |> Command.put_config_file("pdf")

    assert {:ok, _result} = Tesserax.run(command)
    assert File.exists?(@output_test_pdf)
  end
end
