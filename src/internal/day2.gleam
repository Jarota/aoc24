import gleam/int
import gleam/list
import gleam/string

type Report =
  List(Int)

type Direction {
  Ascending
  Descending
}

pub fn solve1(input: String) -> String {
  parse(input)
  |> list.count(is_valid)
  |> int.to_string
}

pub fn solve2(input: String) -> String {
  parse(input)
  |> list.count(mostly_valid)
  |> int.to_string
}

fn parse(input: String) -> List(Report) {
  string.split(input, on: "\n")
  |> list.map(parse_line)
  // Exclude the final newline, which isn't a real report
  |> list.reverse
  |> list.drop(1)
}

fn parse_line(line: String) -> Report {
  string.split(line, on: " ")
  |> list.map(fn(s) -> Int {
    case int.parse(s) {
      Ok(x) -> x
      _ -> 0
    }
  })
}

fn is_valid(r: Report) -> Bool {
  case r {
    // Automatically true for empty or singleton lists
    [] | [_] -> True
    [x, y, ..] -> is_valid_loop(r, get_direction(x, y))
  }
}

fn is_valid_loop(r: Report, dir: Direction) -> Bool {
  case r {
    // Automatically true for empty or singleton lists
    [] | [_] -> True
    [x, y, ..rest] -> {
      let vd = valid_diff(x, y)
      case dir, x < y {
        Ascending, True | Descending, False ->
          vd && is_valid_loop([y, ..rest], dir)
        _, _ -> False
      }
    }
  }
}

fn valid_diff(x: Int, y: Int) -> Bool {
  let d = int.absolute_value(x - y)
  d >= 1 && d <= 3
}

fn get_direction(x: Int, y: Int) -> Direction {
  case x < y {
    True -> Ascending
    False -> Descending
  }
}

fn mostly_valid(r: Report) -> Bool {
  case r {
    // Automatically true for empty or singleton lists
    [] | [_] -> True
    // Generate list of all Reports minus one level
    _ -> {
      let all = gen_reports(r)
      list.any(all, is_valid)
    }
  }
}

fn gen_reports(r: Report) -> List(Report) {
  // r is added to the accumulator straight away
  // because we also want to check if the report
  // is valid without having to remove any levels
  gen_reports_loop(r, r, [r])
}

fn gen_reports_loop(r: Report, orig: Report, res: List(Report)) -> List(Report) {
  case r {
    [] -> res
    [_, ..rest] -> {
      let i = list.length(orig) - list.length(r)
      let new_r = list.flatten([list.take(orig, i), rest])
      let new_res = [new_r, ..res]
      gen_reports_loop(rest, orig, new_res)
    }
  }
}
