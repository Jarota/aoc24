import gleam/io
import internal/day11
import simplifile.{read}

pub fn main() {
  case read("./inputs/11.txt") {
    Ok(contents) -> io.println(day11.solve2(contents))
    Error(_) -> io.println_error("failed to read file")
  }
}
