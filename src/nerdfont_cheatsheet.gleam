import argv
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import glyphs

fn print_all(glyphs: List(glyphs.Glyph)) -> Result(Nil, String) {
  list.each(glyphs, fn(glyph) {
    let line =
      glyphs.collection_to_string(glyph.collection)
      <> " "
      <> glyph.name
      <> " "
      <> glyph.symbol
      <> " "

    io.println(line)
  })

  Ok(Nil)
}

fn get_symbol(str: String) -> Result(Nil, String) {
  use symbol <- result.try(
    str
    |> string.split(on: " ")
    |> list.first()
    |> result.map_error(fn(_) { "could not parse symbol" }),
  )

  io.println(symbol)

  Ok(Nil)
}

pub fn main() -> Result(Nil, String) {
  use glyphs <- result.try(glyphs.get_glyphs())

  case argv.load().arguments {
    ["print"] -> print_all(glyphs)
    ["get", str] -> get_symbol(str)
    _ -> {
      io.println("usage: ./program <print> | <get> [str]")
      Ok(Nil)
    }
  }
}
