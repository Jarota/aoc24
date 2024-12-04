import gleam/io
import internal/day3
import simplifile.{read}

pub fn main() {
  case read("./inputs/3.txt") {
    Ok(contents) -> io.println(day3.solve2(contents))
    Error(_) -> io.println_error("failed to read file")
  }
}
