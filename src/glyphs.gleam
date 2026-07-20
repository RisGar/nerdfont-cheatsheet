import gleam/dict
import gleam/erlang/application
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import gsv
import simplifile

pub fn collection_to_string(collection: Collection) -> String {
  case collection {
    Codicons -> "Codicons"
    Devicons -> "Devicons"
    FiraCodeProgressIndicators -> "FiraCode Progress Indicators"
    FontAwesome -> "FontAwesome"
    FontAwesomeExtension -> "FontAwesome Extensions"
    IECPowerSymbols -> "ICE Power Symbols"
    FontLogos -> "Font Logos"
    MaterialDesignIcons -> "Material Design Icons"
    Octicons -> "Octicons"
    PowerlineExtraSymbols -> "Powerline Extra Symbols"
    Pomicons -> "Pomicons"
    SetiUI -> "SetiUI"
    WeatherIcons -> "Weather Icons"
  }
}

pub type Collection {
  Codicons
  Devicons
  FiraCodeProgressIndicators
  FontAwesome
  FontAwesomeExtension
  IECPowerSymbols
  FontLogos
  MaterialDesignIcons
  Octicons
  PowerlineExtraSymbols
  Pomicons
  SetiUI
  WeatherIcons
}

pub type Glyph {
  Glyph(collection: Collection, symbol: String, name: String)
}

pub fn get_glyphs() -> Result(List(Glyph), String) {
  use filepath <- result.try(
    application.priv_directory("nerdfont_cheatsheet")
    |> result.map_error(fn(err) {
      "failed to get bundled files: " <> string.inspect(err)
    }),
  )

  use file <- result.try(
    { filepath <> "/glyphs.csv" }
    |> simplifile.read()
    |> result.map_error(fn(err) {
      "failed to read file: " <> string.inspect(err)
    }),
  )

  use lst <- result.try(
    file
    |> gsv.to_dicts(separator: ",")
    |> result.map_error(fn(err) {
      "failed to parse CSV: " <> string.inspect(err)
    }),
  )

  use opts <- result.try(lst |> list.try_map(parse_glyph))

  Ok(list.filter_map(opts, fn(x) { option.to_result(x, Nil) }))
}

fn parse_glyph(
  entry: dict.Dict(String, String),
) -> Result(option.Option(Glyph), String) {
  use symbol <- result.try(
    dict.get(entry, "glyph")
    |> result.map_error(fn(_) { "missing 'glyph' column" }),
  )
  use raw_name <- result.try(
    dict.get(entry, "name")
    |> result.map_error(fn(_) { "missing 'name' column" }),
  )

  use #(col_str, name) <- result.try(
    raw_name
    |> string.drop_start(up_to: 2)
    |> string.split_once(on: "_")
    |> result.map_error(fn(_) { "invalid name format" }),
  )

  let col_opt = case col_str {
    "cod" -> option.Some(Codicons)
    "dev" -> option.Some(Devicons)
    "extra" -> option.Some(FiraCodeProgressIndicators)
    "fa" -> option.Some(FontAwesome)
    "fae" -> option.Some(FontAwesomeExtension)
    "iec" -> option.Some(IECPowerSymbols)
    "linux" -> option.Some(FontLogos)
    "md" -> option.Some(MaterialDesignIcons)
    "oct" -> option.Some(Octicons)
    "ple" -> option.Some(PowerlineExtraSymbols)
    "pom" -> option.Some(Pomicons)
    "seti" -> option.Some(SetiUI)
    "weather" -> option.Some(WeatherIcons)
    _ -> option.None
  }

  Ok(option.map(col_opt, fn(collection) { Glyph(collection, symbol, name) }))
}
