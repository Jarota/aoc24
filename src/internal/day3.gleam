import gleam/int
import gleam/list
import gleam/regexp
import gleam/string

pub fn solve1(input: String) -> String {
  parse(input)
  |> list.map(exec)
  |> list.fold(0, int.add)
  |> int.to_string
}

pub fn solve2(input: String) -> String {
  parse(input)
  |> exec_cond
  |> int.to_string
}

// Wrapper type for the two numbers to be multiplied together
type Instruction {
  Mul(Int, Int)
  Enable
  Disable
}

fn parse(input: String) -> List(Instruction) {
  let assert Ok(re) =
    regexp.from_string(
      "(?:mul\\((?:[0-9]){1,3},(?:[0-9]){1,3}\\))|(?:(?:do(?:n't)?)\\(\\))",
    )

  let matches = regexp.scan(re, input)
  list.map(matches, fn(match) -> String { match.content })
  |> list.map(str_to_instruction)
}

fn str_to_instruction(s: String) -> Instruction {
  case s {
    "do()" -> Enable
    "don't()" -> Disable
    _ -> {
      let pair =
        // drop 'mul(' from the beginning
        string.drop_start(s, 4)
        // drop ')' from the end
        |> string.drop_end(1)
        |> string.split_once(",")

      case pair {
        Error(_) -> Mul(0, 0)
        Ok(#(a, b)) -> {
          let x = int.parse(a)
          let y = int.parse(b)
          case x, y {
            Ok(left), Ok(right) -> Mul(left, right)
            _, _ -> Mul(0, 0)
          }
        }
      }
    }
  }
}

fn exec(i: Instruction) -> Int {
  case i {
    Mul(x, y) -> x * y
    _ -> 0
  }
}

fn exec_cond(is: List(Instruction)) -> Int {
  // executing 'mul' instructions is enabled by default
  exec_cond_loop(is, True, 0)
}

fn exec_cond_loop(is: List(Instruction), enabled: Bool, result: Int) -> Int {
  case is {
    [] -> result
    [i, ..rest] -> {
      case i {
        Enable -> exec_cond_loop(rest, True, result)
        Disable -> exec_cond_loop(rest, False, result)
        Mul(x, y) -> {
          case enabled {
            False -> exec_cond_loop(rest, enabled, result)
            True -> {
              let new = result + { x * y }
              exec_cond_loop(rest, enabled, new)
            }
          }
        }
      }
    }
  }
}
