import gleam/io
import internal/day2
import simplifile.{read}

pub fn main() {
  case read("./inputs/2.txt") {
    Ok(contents) -> io.println(day2.solve2(contents))
    Error(_) -> io.println_error("failed to read file")
  }
}
