import gleam/io
import internal/day7
import simplifile.{read}

pub fn main() {
  case read("./inputs/7.txt") {
    Ok(contents) -> io.println(day7.solve2(contents))
    Error(_) -> io.println_error("failed to read file")
  }
}
