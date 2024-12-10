import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string

// A position on the map,
// made up of a row and a column
type Point =
  #(Int, Int)

// Maps the 'frequency' to a set of points
type Antennas =
  Dict(String, Set(Point))

type Map {
  M(size: Int, ants: Antennas)
}

pub fn solve1(input: String) -> String {
  let m = parse(input)
  let bounds_with_size = in_bounds(m.size, _)

  dict.values(m.ants)
  |> list.map(all_antinodes)
  |> list.fold(set.new(), set.union)
  |> set.filter(bounds_with_size)
  |> set.size
  |> int.to_string
}

pub fn solve2(input: String) -> String {
  let m = parse(input)
  let antinodes_with_size = all_resonant_antinodes(_, m.size)

  dict.values(m.ants)
  |> list.map(antinodes_with_size)
  |> list.fold(set.new(), set.union)
  |> set.size
  |> int.to_string
}

fn parse(input: String) -> Map {
  parse_loop(input, #(0, 0), M(0, dict.new()))
}

fn parse_loop(input: String, p: Point, m: Map) -> Map {
  let #(i, j) = p
  case string.pop_grapheme(input) {
    // We've reached the end of the input,
    // so set the size of the map and return
    Error(Nil) -> M(..m, size: i)

    Ok(#(c, rest)) -> {
      let q = case c {
        "\n" -> #(i + 1, 0)
        _ -> #(i, j + 1)
      }
      let new_ants = update_antennas(m.ants, c, p)
      parse_loop(rest, q, M(..m, ants: new_ants))
    }
  }
}

fn update_antennas(a: Antennas, c: String, p: Point) -> Antennas {
  case c {
    "." | "\n" -> a
    _ -> {
      let new_set = case dict.get(a, c) {
        Error(Nil) -> set.new() |> set.insert(p)
        Ok(ps) -> set.insert(ps, p)
      }
      dict.insert(a, c, new_set)
    }
  }
}

fn all_antinodes(ps: Set(Point)) -> Set(Point) {
  pairs(ps)
  |> list.fold([], fn(res, pair) {
    let #(p, q) = calc_antinodes(pair.0, pair.1)
    list.append([p, q], res)
  })
  |> set.from_list
}

fn pairs(ps: Set(Point)) -> List(#(Point, Point)) {
  pairs_loop(set.to_list(ps), [])
}

fn pairs_loop(
  ps: List(Point),
  res: List(#(Point, Point)),
) -> List(#(Point, Point)) {
  case ps {
    [] -> res
    [p, ..rest] -> {
      let p_pairs = list.map(rest, fn(q) { #(p, q) })
      let new_res = list.append(res, p_pairs)
      pairs_loop(rest, new_res)
    }
  }
}

fn in_bounds(size: Int, p: Point) -> Bool {
  p.0 >= 0 && p.0 < size && p.1 >= 0 && p.1 < size
}

fn calc_antinodes(p: Point, q: Point) -> #(Point, Point) {
  let #(i1, j1) = p
  let #(i2, j2) = q
  let di = i1 - i2
  let dj = j1 - j2
  #(#(i1 + di, j1 + dj), #(i2 - di, j2 - dj))
}

fn all_resonant_antinodes(ps: Set(Point), size: Int) -> Set(Point) {
  pairs(ps)
  |> list.flat_map(fn(pair) { calc_resonant_antinodes(pair.0, pair.1, size) })
  |> set.from_list
}

fn calc_resonant_antinodes(p: Point, q: Point, size: Int) -> List(Point) {
  let #(i1, j1) = p
  let #(i2, j2) = q
  let di = i1 - i2
  let dj = j1 - j2
  list.flatten([
    resonant_antinodes(p, di, dj, size, []),
    resonant_antinodes(q, -di, -dj, size, []),
  ])
}

fn resonant_antinodes(
  p: Point,
  di: Int,
  dj: Int,
  size: Int,
  res: List(Point),
) -> List(Point) {
  case in_bounds(size, p) {
    False -> res
    True -> {
      let #(i, j) = p
      resonant_antinodes(#(i + di, j + dj), di, dj, size, list.append([p], res))
    }
  }
}
