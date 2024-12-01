import gleam/dict
import gleam/int
import gleam/list
import gleam/string

pub fn solve1(input: String) -> String {
  let #(left, right) = parse(input)
  total_dist(left, right)
  |> int.to_string
}

pub fn solve2(input: String) -> String {
  let #(left, right) = parse(input)
  similarity_score(left, right)
  |> int.to_string
}

fn parse(input: String) -> #(List(Int), List(Int)) {
  string.split(input, on: "\n")
  |> list.map(conv_str_to_ints)
  |> list.unzip
}

fn conv_str_to_ints(pair: String) -> #(Int, Int) {
  let res =
    string.split(pair, on: "   ")
    |> list.map(fn(x: String) -> Result(Int, Nil) { int.parse(x) })
  case res {
    [Ok(a), Ok(b)] -> #(a, b)
    _ -> #(0, 0)
  }
}

fn total_dist(left: List(Int), right: List(Int)) -> Int {
  let l = list.sort(left, int.compare)
  let r = list.sort(right, int.compare)
  list.zip(l, with: r)
  |> list.map(find_dist)
  |> list.fold(0, int.add)
}

fn find_dist(p: #(Int, Int)) -> Int {
  let #(a, b) = p
  int.absolute_value(a - b)
}

fn similarity_score(left: List(Int), right: List(Int)) -> Int {
  let d = freq_dict(right)
  list.map(left, fn(x) -> Int {
    case dict.get(d, x) {
      Ok(n) -> x * n
      _ -> 0
    }
  })
  |> list.fold(0, int.add)
}

fn freq_dict(l: List(Int)) -> dict.Dict(Int, Int) {
  dict.new() |> freq_dict_loop(l)
}

fn freq_dict_loop(d: dict.Dict(Int, Int), l: List(Int)) -> dict.Dict(Int, Int) {
  case l {
    [] -> d
    [first, ..rest] -> freq_dict_loop(update_entry(d, first), rest)
  }
}

fn update_entry(d: dict.Dict(Int, Int), x: Int) -> dict.Dict(Int, Int) {
  case dict.get(d, x) {
    Ok(n) -> dict.insert(d, x, n + 1)
    _ -> dict.insert(d, x, 1)
  }
}
