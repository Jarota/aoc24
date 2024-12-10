import gleam/int
import gleam/list
import gleam/string

type Block {
  File(id: Int)
  Empty
}

pub fn solve1(input: String) -> String {
  parse(input)
  |> compact
  |> list.index_fold(0, checksum)
  |> int.to_string
}

fn parse(input: String) -> List(Block) {
  string.to_graphemes(input)
  |> list.index_map(parse_block)
  |> list.flatten
}

fn parse_block(c: String, i: Int) -> List(Block) {
  case int.parse(c) {
    Error(Nil) | Ok(0) -> []
    Ok(len) -> {
      let res = list.range(0, len - 1)
      case int.is_even(i) {
        False -> list.map(res, fn(_) { Empty })
        True -> {
          let id = i / 2
          list.map(res, fn(_) { File(id) })
        }
      }
    }
  }
}

fn compact(bs: List(Block)) -> List(Block) {
  let clean = list.reverse(bs) |> list.filter(fn(b) { b != Empty })
  let len = list.length(clean)

  compact_loop(bs, clean, [])
  |> list.take(len)
}

fn compact_loop(
  blocks: List(Block),
  clean: List(Block),
  result: List(Block),
) -> List(Block) {
  case blocks {
    [] -> result
    [b, ..restb] -> {
      case b, clean {
        _, [] | File(_), _ ->
          compact_loop(restb, clean, list.append(result, [b]))
        Empty, [c, ..restc] ->
          compact_loop(restb, restc, list.append(result, [c]))
      }
    }
  }
}

fn checksum(acc: Int, b: Block, i: Int) -> Int {
  case b {
    File(id) -> acc + { id * i }
    Empty -> acc
  }
}
