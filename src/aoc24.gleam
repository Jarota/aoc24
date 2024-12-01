import gleam/io
import internal/day1
import simplifile.{read}

pub fn main() {
  case read("./inputs/1.txt") {
    Ok(contents) -> io.println(day1.solve2(contents))
    Error(_) -> io.println_error("failed to read file")
  }
}
