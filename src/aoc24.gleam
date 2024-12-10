import gleam/io
import internal/day9
import simplifile.{read}

pub fn main() {
  case read("./inputs/9-ex.txt") {
    Ok(contents) -> io.println(day9.solve2(contents))
    Error(_) -> io.println_error("failed to read file")
  }
}
