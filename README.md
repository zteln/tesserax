# Tesserax

An Elixir application that wraps the [Tesseract OCR Engine](https://github.com/tesseract-ocr/tesseract).

One utilizes this application by creating commands and feeding them to Tesseract wrappers.
The wrapper can be used via `Tesserax.read_from_mem/1` or `Tesserax.read_from_file/1` and needs a `%Tesserax.Command{}` struct as argument.
`Tesserax.read_from_mem/1` reads text from an image loaded in memory, `Tesserax.read_from_file/1` reads text from the image provided by the image path.
```elixir
# Reading text from memory
Tesserax.Command.make_command(
    image: <<...>>, # image binary data
    languages: ["eng", "hin"], 
    tessdata: "path/to/tessdata/dir", 
    config: "path/to/config/file", 
    psm: 0, 
    oem: 0
)
|> Tesserax.read_from_mem()

# Reading text from a file
Tesserax.Command.make_command(
    image: "path/to/image", 
    languages: ["eng", "hin"], 
    tessdata: "path/to/tessdata/dir", 
    config: "path/to/config/file", 
    psm: 0, 
    oem: 0
)
|> Tesserax.read_from_file()
```
An image loaded in memory needs to be in PNG format.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `tesserax` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tesserax, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/tesserax>.

## See also
- [tesseract](https://github.com/tesseract-ocr/tesseract)
- [tesseract-ocr-elixir](https://github.com/dannnylo/tesseract-ocr-elixir).
