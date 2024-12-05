import gleam/io
import internal/day4
import simplifile.{read}

pub fn main() {
  case read("./inputs/4.txt") {
    Ok(contents) -> io.println(day4.solve2(contents))
    Error(_) -> io.println_error("failed to read file")
  }
}
