import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string

type Pos =
  #(Int, Int)

type Map {
  M(size: Int, ps: Dict(Pos, Int))
}

pub fn solve1(input: String) -> String {
  let m = parse(input)

  trailheads(m)
  |> list.fold(0, fn(acc, p) { acc + score(p, m) })
  |> int.to_string
}

pub fn solve2(input: String) -> String {
  let m = parse(input)

  trailheads(m)
  |> list.fold(0, fn(acc, p) { acc + rating(p, m) })
  |> int.to_string
}

fn parse(input: String) -> Map {
  let init_pos = #(0, 0)
  parse_loop(input, init_pos, M(0, dict.new()))
}

fn parse_loop(input: String, pos: Pos, m: Map) -> Map {
  let #(i, j) = pos
  case string.pop_grapheme(input) {
    Error(Nil) -> M(..m, size: i)
    Ok(#(c, rest)) -> {
      case c {
        "\n" -> parse_loop(rest, #(i + 1, 0), m)
        _ -> {
          let new_ps = dict.insert(m.ps, pos, must_int(c))
          parse_loop(rest, #(i, j + 1), M(..m, ps: new_ps))
        }
      }
    }
  }
}

fn must_int(c: String) -> Int {
  let assert Ok(x) = int.parse(c)
  x
}

fn trailheads(m: Map) -> List(Pos) {
  dict.to_list(m.ps)
  |> list.filter(fn(p) {
    let #(_, v) = p
    v == 0
  })
  |> list.map(fn(p) {
    let #(pos, _) = p
    pos
  })
}

fn score(p: Pos, m: Map) -> Int {
  score_loop([], p, m, 0)
  |> list.unique
  |> list.length
}

fn rating(p: Pos, m: Map) -> Int {
  score_loop([], p, m, 0)
  |> list.length
}

fn score_loop(found: List(Pos), p: Pos, m: Map, expected: Int) -> List(Pos) {
  case dict.get(m.ps, p) {
    Ok(current) if current == expected -> {
      use <- bool.guard(current == 9, list.append([p], found))

      let #(i, j) = p
      let neighbours = [#(i - 1, j), #(i + 1, j), #(i, j - 1), #(i, j + 1)]
      list.fold(neighbours, found, fn(acc, q) {
        score_loop(acc, q, m, current + 1)
      })
    }
    _ -> found
  }
}
