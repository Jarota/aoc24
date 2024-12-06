import gleam/io
import internal/day5
import simplifile.{read}

pub fn main() {
  case read("./inputs/5.txt") {
    Ok(contents) -> io.println(day5.solve2(contents))
    Error(_) -> io.println_error("failed to read file")
  }
}
