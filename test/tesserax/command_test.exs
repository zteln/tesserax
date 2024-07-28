defmodule Tesserax.CommandTest do
  use ExUnit.Case, async: true
  alias Tesserax.Command

  test "make_command/1/2" do
    command =
      Command.make_command(image: "image")
      |> Command.make_command(languages: "language")
      |> Command.make_command(tessdata: "tessdata")
      |> Command.make_command(config: "config")
      |> Command.make_command(psm: 0)
      |> Command.make_command(oem: 0)

    assert "image" == Command.image(command)
    assert "language" == Command.languages(command)
    assert "tessdata" == Command.tessdata(command)
    assert "config" == Command.config(command)
    assert 0 == Command.psm(command)
    assert 0 == Command.oem(command)
  end

  test "prepare_command/1" do
    command_with_image = Command.make_command(image: "image")
    assert %{image: "image"} == Command.prepare_command(command_with_image)

    command_with_languages = Command.make_command(languages: "languages")
    assert %{languages: "languages"} == Command.prepare_command(command_with_languages)

    command_with_tessdata = Command.make_command(tessdata: "tessdata")
    assert %{tessdata: "tessdata"} == Command.prepare_command(command_with_tessdata)

    command_with_config = Command.make_command(config: "config")
    assert %{config: "config"} == Command.prepare_command(command_with_config)

    command_with_psm = Command.make_command(psm: 0)
    assert %{psm: 0} == Command.prepare_command(command_with_psm)

    command_with_oem = Command.make_command(oem: 0)
    assert %{oem: 0} == Command.prepare_command(command_with_oem)
  end
end
