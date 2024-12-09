import gleam/io
import internal/day8
import simplifile.{read}

pub fn main() {
  case read("./inputs/8.txt") {
    Ok(contents) -> io.println(day8.solve2(contents))
    Error(_) -> io.println_error("failed to read file")
  }
}
