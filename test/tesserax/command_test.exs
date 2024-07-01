defmodule Tesserax.CommandTest do
  use ExUnit.Case, async: true
  alias Tesserax.Command

  test "new/0" do
    assert %Command{} = Command.new()
  end

  describe "convert_to_args/1" do
    test "recognition command" do
      command =
        Command.new()
        |> Command.put_image_path("image_path")
        |> Command.put_output_path("output_path")
        |> Command.put_language("lang1")
        |> Command.put_language("lang2")
        |> Command.put_oem(1)
        |> Command.put_psm(2)
        |> Command.put_log_level(:info)
        |> Command.put_tessdata_dir("tessdata_dir")
        |> Command.put_user_words("user_words")
        |> Command.put_user_patterns("user_patterns")
        |> Command.put_config_variable(:var1, "val1")
        |> Command.put_config_variable(:var2, "val2")
        |> Command.put_config_file("config_file")

      assert command |> Command.convert_to_args() == [
               "image_path",
               "output_path",
               "-l",
               "lang2+lang1",
               "-c",
               "var1=val1",
               "-c",
               "var2=val2",
               "--tessdata-dir",
               "tessdata_dir",
               "--psm",
               "2",
               "--oem",
               "1",
               "--loglevel",
               "info",
               "config_file"
             ]
    end

    test "list languages" do
      command =
        Command.new()
        |> Command.list_languages()

      assert command |> Command.convert_to_args() == ["--list-langs"]
    end
  end
end
