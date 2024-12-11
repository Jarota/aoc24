import gleam/io
import internal/day10
import simplifile.{read}

pub fn main() {
  case read("./inputs/10.txt") {
    Ok(contents) -> io.println(day10.solve2(contents))
    Error(_) -> io.println_error("failed to read file")
  }
}
