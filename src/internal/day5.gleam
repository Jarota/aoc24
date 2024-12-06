import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/string

pub fn solve1(input: String) -> String {
  let #(rules, all_updates) = parse(input)
  let valid_with_rules = is_valid(_, rules)
  list.filter(all_updates, valid_with_rules)
  |> list.map(middle_val)
  |> list.fold(0, int.add)
  |> int.to_string
}

pub fn solve2(input: String) -> String {
  let #(rules, all_updates) = parse(input)
  let reorder_with_rules = reorder(_, rules)
  // Get only the *invalid* updates
  list.filter(all_updates, fn(u) { !is_valid(u, rules) })
  |> list.map(reorder_with_rules)
  |> list.map(middle_val)
  |> list.fold(0, int.add)
  |> int.to_string
}

type Rules =
  Dict(Int, List(Int))

type Updates =
  List(Int)

fn parse(input: String) -> #(Rules, List(Updates)) {
  let assert Ok(#(raw_rules, raw_ups)) = string.split_once(input, on: "\n\n")
  let rules = conv_rules(raw_rules)
  let updates = conv_updates(raw_ups)
  #(rules, updates)
}

fn conv_rules(input: String) -> Rules {
  string.split(input, on: "\n")
  |> list.map(conv_rule)
  |> build_rules
}

fn conv_rule(s: String) -> #(Int, Int) {
  let assert Ok(ns) = string.split_once(s, "|")
  let assert Ok(x) = int.parse(ns.0)
  let assert Ok(y) = int.parse(ns.1)
  #(x, y)
}

fn build_rules(tuples: List(#(Int, Int))) -> Rules {
  build_rules_loop(tuples, dict.new())
}

fn build_rules_loop(tuples: List(#(Int, Int)), d: Rules) -> Rules {
  case tuples {
    [] -> d
    [#(x, y), ..rest] -> {
      case dict.get(d, x) {
        Error(_) -> build_rules_loop(rest, dict.insert(d, x, [y]))
        Ok(ys) -> {
          let new_ys = list.append(ys, [y])
          build_rules_loop(rest, dict.insert(d, x, new_ys))
        }
      }
    }
  }
}

fn conv_updates(input: String) -> List(Updates) {
  let lines = string.split(input, on: "\n")
  list.take(lines, list.length(lines) - 1)
  |> list.map(conv_update)
}

fn conv_update(xs: String) -> List(Int) {
  string.split(xs, on: ",")
  |> list.map(must_int)
}

fn must_int(x: String) -> Int {
  let assert Ok(res) = int.parse(x)
  res
}

fn is_valid(u: Updates, r: Rules) -> Bool {
  is_valid_loop(u, r, dict.new())
}

fn is_valid_loop(u: Updates, r: Rules, seen: Dict(Int, Bool)) -> Bool {
  case u {
    [] -> True
    [x, ..rest] -> {
      let rule = dict.get(r, x)
      case rule {
        // assume we can continue if there's no
        // rules for the given page number
        Error(_) -> is_valid_loop(rest, r, dict.insert(seen, x, True))
        Ok(cant_see) -> {
          let have_seen = in_dict(_, seen)
          case list.any(cant_see, have_seen) {
            // If any 'cant see' vals have been seen
            // then the sequence of updates is invalid
            True -> False
            False -> is_valid_loop(rest, r, dict.insert(seen, x, True))
          }
        }
      }
    }
  }
}

fn in_dict(v: Int, d: Dict(Int, Bool)) -> Bool {
  case dict.get(d, v) {
    Ok(_) -> True
    Error(_) -> False
  }
}

fn middle_val(u: Updates) -> Int {
  let l = list.length(u)
  let i: Int = l / 2
  case list.drop(u, i) |> list.first {
    Ok(x) -> x
    _ -> 0
  }
}

fn reorder(u: Updates, r: Rules) -> Updates {
  list.sort(u, fn(x, y) -> order.Order {
    let x_rules = dict.get(r, x)
    let y_rules = dict.get(r, y)
    case x_rules, y_rules {
      Error(Nil), Error(Nil) -> order.Eq
      Ok(after_x), Error(Nil) -> {
        case list.contains(after_x, y) {
          True -> order.Lt
          False -> order.Eq
        }
      }
      Error(Nil), Ok(after_y) -> {
        case list.contains(after_y, x) {
          True -> order.Gt
          False -> order.Eq
        }
      }
      Ok(after_x), Ok(after_y) -> {
        case list.contains(after_x, y), list.contains(after_y, x) {
          True, _ -> order.Lt
          _, True -> order.Gt
          _, _ -> order.Eq
        }
      }
    }
  })
  |> io.debug
}
