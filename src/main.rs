use std::{error::Error, fs::File, io::BufReader};

fn main() {
  let glyphs = parse_glyphs();
  println!("#{glyphs}");
}

#[derive(Debug)]
struct Glyph {
  glyph: String,
  name: String,
  collection: String,
}

fn parse_glyphs() -> Result<Vec<Glyph>, Box<dyn Error>> {
  let file = File::open("./glyphs/glyphs.csv")?;
  let file_reader = BufReader::new(file);

  let mut csv_reader = csv::Reader::from_reader(file_reader);

  let strings = csv_reader.records().collect::<Result<Vec<_>, _>>()?;

  let glyphs = strings
    .iter()
    .map(|record| -> Result<Glyph, Box<dyn Error>> {
      let glyph = record.get(0).ok_or("Invalid line data")?.to_owned();
      let name = record
        .get(1)
        .ok_or("Invalid line data")?
        .strip_prefix("i_")
        .ok_or("Glyph name does not start with i_")?
        .to_owned();

      Ok::<Glyph, Box<dyn Error>>(Glyph {
        glyph,
        name,
        collection: "".to_owned(),
      })
    })
    .collect::<Result<Vec<Glyph>, _>>()?;

  Ok(glyphs)
}
