import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string

type Pos =
  #(Int, Int)

type Direction {
  Up
  Down
  Left
  Right
}

type Map {
  M(size: Int, guard: #(Pos, Direction), obstacles: Dict(Pos, Bool))
}

pub fn solve1(input: String) -> String {
  parse(input)
  |> will_visit
  |> dict.keys
  |> list.length
  |> int.to_string
}

pub fn solve2(input: String) -> String {
  let map = parse(input)
  let empty = empty_spaces(input)
  list.map(empty, fn(p) -> Map {
    let new_obs = dict.insert(map.obstacles, p, True)
    set_obstacles(map, new_obs)
  })
  |> list.count(contains_loop)
  |> int.to_string
}

fn parse(input: String) -> Map {
  let init_pos = #(0, 0)
  let guard = #(init_pos, Up)
  parse_loop(input, init_pos, M(0, guard, dict.new()))
}

fn parse_loop(input: String, pos: Pos, m: Map) -> Map {
  let #(i, j) = pos
  case string.pop_grapheme(input) {
    Error(Nil) -> set_size(m, i)
    Ok(#(c, rest)) -> {
      case c {
        "." -> parse_loop(rest, #(i, j + 1), m)
        "\n" -> parse_loop(rest, #(i + 1, 0), m)
        "#" -> {
          let obs = dict.insert(m.obstacles, pos, True)
          parse_loop(rest, #(i, j + 1), set_obstacles(m, obs))
        }
        // The only other character is the 'guard'
        _ -> {
          parse_loop(rest, #(i, j + 1), set_guard(m, pos, get_dir(c)))
        }
      }
    }
  }
}

fn set_size(m: Map, size: Int) -> Map {
  M(size, m.guard, m.obstacles)
}

fn set_guard(m: Map, pos: Pos, dir: Direction) -> Map {
  let guard = #(pos, dir)
  M(m.size, guard, m.obstacles)
}

fn set_obstacles(m: Map, obs: Dict(Pos, Bool)) -> Map {
  M(m.size, m.guard, obs)
}

fn get_dir(c: String) -> Direction {
  case c {
    "^" -> Up
    ">" -> Right
    "<" -> Left
    _ -> Down
  }
}

fn will_visit(m: Map) -> Dict(Pos, Bool) {
  will_visit_loop(m, dict.new())
}

fn will_visit_loop(m: Map, visited: Dict(Pos, Bool)) -> Dict(Pos, Bool) {
  case in_bounds(m.size, m.guard.0) {
    // Once we're out of bounds, we can stop
    False -> visited
    True -> {
      let new_visited = dict.insert(visited, m.guard.0, True)
      will_visit_loop(next_state(m), new_visited)
    }
  }
}

fn in_bounds(size: Int, pos: Pos) -> Bool {
  pos.0 >= 0 && pos.0 < size && pos.1 >= 0 && pos.1 < size
}

fn next_state(m: Map) -> Map {
  let #(pos, dir) = move(m.guard, m.obstacles)
  set_guard(m, pos, dir)
}

fn move(guard: #(Pos, Direction), obs: Dict(Pos, Bool)) -> #(Pos, Direction) {
  let next = next_pos(guard)
  case dict.get(obs, next) {
    // No obstacle, so continue
    Error(Nil) -> #(next, guard.1)
    Ok(_) -> {
      // Try again after turning
      #(guard.0, turn(guard.1))
    }
  }
}

fn next_pos(guard: #(Pos, Direction)) -> Pos {
  let #(#(i, j), dir) = guard
  case dir {
    Up -> #(i - 1, j)
    Down -> #(i + 1, j)
    Left -> #(i, j - 1)
    Right -> #(i, j + 1)
  }
}

fn turn(d: Direction) -> Direction {
  case d {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }
}

fn empty_spaces(input: String) -> List(Pos) {
  let init_pos = #(0, 0)
  empty_spaces_loop(input, init_pos, [])
}

fn empty_spaces_loop(input: String, pos: Pos, res: List(Pos)) -> List(Pos) {
  let #(i, j) = pos
  case string.pop_grapheme(input) {
    Error(Nil) -> res
    Ok(#(c, rest)) -> {
      case c {
        // A '.' is an empty space (where we can try to place an obstacle)
        "." -> {
          let new_res = list.append([pos], res)
          empty_spaces_loop(rest, #(i, j + 1), new_res)
        }
        "\n" -> empty_spaces_loop(rest, #(i + 1, 0), res)
        _ -> empty_spaces_loop(rest, #(i, j + 1), res)
      }
    }
  }
}

fn contains_loop(m: Map) -> Bool {
  contains_loop_loop(m, dict.new())
}

fn contains_loop_loop(m: Map, visited: Dict(#(Pos, Direction), Bool)) -> Bool {
  case in_bounds(m.size, m.guard.0) {
    // Once we're out of bounds, we can stop
    False -> False
    True -> {
      case dict.get(visited, m.guard) {
        // If we reach a previously seen position + direction pair
        // then this configuration must contain a loop
        Ok(True) -> True
        // Otherwise, continue to advance through the map
        _ -> {
          let new_visited = dict.insert(visited, m.guard, True)
          contains_loop_loop(next_state(m), new_visited)
        }
      }
    }
  }
}
