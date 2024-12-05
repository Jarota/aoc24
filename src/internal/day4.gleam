import gleam/dict.{type Dict, insert}
import gleam/int
import gleam/list
import gleam/string

type Matrix {
  // An 'n x n' matrix, with a dictionary (rows) of dictionaries (cols)
  // to Strings (e.g. "X", "M", "A", "S")
  M(n: Int, vals: Dict(Int, Dict(Int, String)))
}

fn in_bounds(m: Matrix, i: Int, j: Int) -> Bool {
  i >= 0 && i < m.n && j >= 0 && j < m.n
}

fn get(m: Matrix, i: Int, j: Int) -> Result(String, Nil) {
  case in_bounds(m, i, j) {
    False -> Error(Nil)
    True -> {
      let row = dict.get(m.vals, i)
      case row {
        Ok(row) -> dict.get(row, j)
        Error(_) -> Error(Nil)
      }
    }
  }
}

pub fn solve1(input: String) -> String {
  parse(input)
  |> count_xmas
  |> int.to_string
}

pub fn solve2(input: String) -> String {
  parse(input)
  |> count_x_mas
  |> int.to_string
}

fn parse(input: String) -> Matrix {
  let lines = string.split(input, "\n")
  // Discard the last line (which is blank)
  let rows = list.take(lines, list.length(lines) - 1)
  // Assume a square ('n X n') matrix
  let matrix = M(list.length(rows), dict.new())
  parse_rows(rows, 0, matrix)
}

fn parse_rows(rows: List(String), index: Int, m: Matrix) -> Matrix {
  case rows {
    [] -> m
    [row, ..rest] -> {
      let new_vals = insert(m.vals, index, parse_row(row))
      parse_rows(rest, index + 1, M(m.n, new_vals))
    }
  }
}

fn parse_row(row: String) -> Dict(Int, String) {
  parse_row_loop(row, 0, dict.new())
}

fn parse_row_loop(
  row: String,
  j: Int,
  res: Dict(Int, String),
) -> Dict(Int, String) {
  case string.pop_grapheme(row) {
    Error(_) -> res
    Ok(#(c, rest)) -> {
      let new_res = insert(res, j, c)
      parse_row_loop(rest, j + 1, new_res)
    }
  }
}

fn count_xmas(m: Matrix) -> Int {
  count_xmas_loop(m, 0, 0, 0)
}

fn count_xmas_loop(m: Matrix, i: Int, j: Int, count: Int) -> Int {
  case i >= m.n {
    // We've finished searching
    True -> count
    _ -> {
      case j >= m.n {
        // We've reached the end of the row
        True -> count_xmas_loop(m, i + 1, 0, count)
        _ -> {
          let c = get(m, i, j)
          case c {
            // We only need to start searching when
            // we find an "X" grapheme
            Ok("X") -> {
              let found = search(m, i, j)
              count_xmas_loop(m, i, j + 1, count + found)
            }
            _ -> count_xmas_loop(m, i, j + 1, count)
          }
        }
      }
    }
  }
}

fn search(m: Matrix, i: Int, j: Int) -> Int {
  // Check each direction
  [
    build_word(m, i, j, -1, -1),
    build_word(m, i, j, -1, 0),
    build_word(m, i, j, -1, 1),
    build_word(m, i, j, 0, -1),
    build_word(m, i, j, 0, 1),
    build_word(m, i, j, 1, -1),
    build_word(m, i, j, 1, 0),
    build_word(m, i, j, 1, 1),
  ]
  |> list.count(fn(s) -> Bool { s == "XMAS" })
}

fn build_word(m: Matrix, i: Int, j: Int, di: Int, dj: Int) -> String {
  build_word_loop(m, i, j, di, dj, "")
}

fn build_word_loop(
  m: Matrix,
  i: Int,
  j: Int,
  di: Int,
  dj: Int,
  res: String,
) -> String {
  case string.length(res) >= 4 {
    True -> res
    _ -> {
      let next = get(m, i, j)
      case next {
        // We're out of bounds
        Error(_) -> res
        Ok(c) -> {
          let new = string.append(res, c)
          build_word_loop(m, i + di, j + dj, di, dj, new)
        }
      }
    }
  }
}

fn count_x_mas(m: Matrix) -> Int {
  count_x_mas_loop(m, 0, 0, 0)
}

fn count_x_mas_loop(m: Matrix, i: Int, j: Int, count: Int) -> Int {
  case i >= m.n {
    // We've finished searching
    True -> count
    _ -> {
      case j >= m.n {
        // We've reached the end of the row
        True -> count_x_mas_loop(m, i + 1, 0, count)
        _ -> {
          let c = get(m, i, j)
          case c {
            // We only need to start searching when
            // we find an "A" grapheme
            Ok("A") -> {
              let new = case search_x(m, i, j) {
                True -> count + 1
                False -> count
              }
              count_x_mas_loop(m, i, j + 1, new)
            }
            _ -> count_x_mas_loop(m, i, j + 1, count)
          }
        }
      }
    }
  }
}

fn search_x(m: Matrix, i: Int, j: Int) -> Bool {
  let tl = get(m, i - 1, j - 1)
  let tr = get(m, i - 1, j + 1)
  let bl = get(m, i + 1, j - 1)
  let br = get(m, i + 1, j + 1)

  // Check first diagonal
  case tl, br {
    Ok("M"), Ok("S") | Ok("S"), Ok("M") -> {
      // Check opposite diagonal
      case tr, bl {
        Ok("M"), Ok("S") | Ok("S"), Ok("M") -> True
        _, _ -> False
      }
    }
    _, _ -> False
  }
}
