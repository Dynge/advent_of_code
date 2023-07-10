let all_food = Advent.read_lines "../2022/day1.txt"

let sums food_inventory =
  let rec inner remaining_food elf_sums =
    match remaining_food with
    | [] -> elf_sums
    | "" :: tail -> inner tail (0 :: elf_sums)
    | cals :: tail ->
        inner tail
          (match elf_sums with
          | [] -> [ int_of_string cals ]
          | head :: tail -> (head + int_of_string cals) :: tail)
  in
  inner food_inventory []

let rec max list current_max =
  match list with
  | [] -> current_max
  | head :: tail when head >= current_max -> max tail head
  | _ :: tail -> max tail current_max

let rec max_3 list (m1, m2, m3) =
  match list with
  | [] -> (m1, m2, m3)
  | head :: tail when head >= m1 -> max_3 tail (head, m1, m2)
  | head :: tail when head >= m2 -> max_3 tail (m1, head, m2)
  | head :: tail when head >= m3 -> max_3 tail (m1, m2, head)
  | _ :: tail -> max_3 tail (m1, m2, m3)

let sum_tuple (m1, m2, m3) = m1 + m2 + m3
let food_sums = sums all_food

let () =
  Format.printf "Part 1: %d\nPart 2: %d\n" (max food_sums 0)
    (sum_tuple (max_3 food_sums (0, 0, 0)))
