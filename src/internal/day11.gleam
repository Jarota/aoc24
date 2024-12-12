import gleam/bool
import gleam/dict.{type Dict, get, insert}
import gleam/int
import gleam/list
import gleam/pair
import gleam/regexp

// Memo contains a history of calculations, where
// the key is a pair of <stone value> and <number of blinks>
// and the value is the number of stones that they result in
type Memo =
  Dict(#(Int, Int), Int)

pub fn solve1(input: String) -> String {
  solve(input, 25)
}

pub fn solve2(input: String) -> String {
  solve(input, 75)
}

fn solve(input: String, blinks: Int) -> String {
  parse(input)
  |> list.fold(#(dict.new(), 0), fn(acc, stone) {
    let #(memo, sum) = acc
    let #(res_mem, res_sum) = blink(memo, stone, blinks)
    #(res_mem, sum + res_sum)
  })
  |> pair.second
  |> int.to_string
}

fn parse(input: String) {
  let assert Ok(re) = regexp.from_string("(\\d+)")
  regexp.scan(re, input)
  |> list.map(fn(m) { must_int(m.content) })
}

fn must_int(s: String) -> Int {
  let assert Ok(x) = int.parse(s)
  x
}

fn change_stone(x: Int) -> List(Int) {
  use <- bool.guard(when: x == 0, return: [1])

  let assert Ok(digits) = int.digits(x, 10)
  let len = list.length(digits)

  use <- bool.guard(when: !int.is_even(len), return: [x * 2024])

  let assert Ok(left) = int.undigits(list.take(digits, len / 2), 10)
  let assert Ok(right) = int.undigits(list.drop(digits, len / 2), 10)

  [left, right]
}

fn blink(memo: Memo, stone: Int, blinks_left: Int) -> #(Memo, Int) {
  use <- bool.guard(when: blinks_left == 0, return: #(
    insert(memo, #(stone, blinks_left), 1),
    1,
  ))

  case get(memo, #(stone, blinks_left)) {
    Ok(n) -> #(memo, n)
    Error(Nil) -> {
      let #(new_mem, new_sum) =
        change_stone(stone)
        |> list.fold(#(memo, 0), fn(acc, val) {
          let #(mem, sum) = acc
          let #(res_mem, res_sum) = blink(mem, val, blinks_left - 1)
          #(res_mem, sum + res_sum)
        })

      #(insert(new_mem, #(stone, blinks_left), new_sum), new_sum)
    }
  }
}
