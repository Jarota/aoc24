import gleam/int
import gleam/list
import gleam/string

type Equation {
  E(goal: Int, terms: List(Int))
}

pub fn solve1(input: String) -> String {
  solve(input, is_valid)
}

pub fn solve2(input: String) -> String {
  solve(input, is_valid_with_concat)
}

fn solve(input: String, f: fn(Equation) -> Bool) -> String {
  parse(input)
  |> list.filter(f)
  |> list.fold(0, fn(acc, e) { acc + e.goal })
  |> int.to_string
}

fn parse(input: String) -> List(Equation) {
  let lines = string.split(input, on: "\n")
  // remove final blank line from input
  list.take(lines, list.length(lines) - 1)
  |> list.map(parse_line)
}

fn parse_line(l: String) -> Equation {
  let assert Ok(#(goal, terms)) = string.split_once(l, on: ": ")
  let g = must_int(goal)
  let ts =
    string.split(terms, on: " ")
    |> list.map(must_int)

  E(g, ts)
}

fn must_int(c: String) -> Int {
  let assert Ok(x) = int.parse(c)
  x
}

fn is_valid(e: Equation) -> Bool {
  is_valid_loop(e.terms, e.goal, 0)
}

fn is_valid_loop(ts: List(Int), g: Int, acc: Int) -> Bool {
  case ts {
    [] -> g == acc
    [t, ..rest] ->
      is_valid_loop(rest, g, acc + t) || is_valid_loop(rest, g, acc * t)
  }
}

fn is_valid_with_concat(e: Equation) -> Bool {
  is_valid_with_concat_loop(e.terms, e.goal, 0)
}

fn is_valid_with_concat_loop(ts: List(Int), g: Int, acc: Int) -> Bool {
  case ts {
    [] -> g == acc
    [t, ..rest] -> {
      let valid = is_valid_with_concat_loop(rest, g, _)
      [{ acc + t }, { acc * t }, concat(acc, t)]
      |> list.any(valid)
    }
  }
}

fn concat(x: Int, y: Int) -> Int {
  let assert Ok(y_ds) = int.digits(y, 10)
  list.fold(y_ds, x, with: fn(acc, x) { { acc * 10 } + x })
}
