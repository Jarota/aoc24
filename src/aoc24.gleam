import gleam/io
import internal/day6
import simplifile.{read}

pub fn main() {
  case read("./inputs/6.txt") {
    Ok(contents) -> io.println(day6.solve2(contents))
    Error(_) -> io.println_error("failed to read file")
  }
}
