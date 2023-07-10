module SetChar = Set.Make (Char)

let priority_score char =
  match char with
  | 'A' .. 'Z' -> Char.code char - 38
  | 'a' .. 'z' -> Char.code char - 96
  | _ -> assert false

let string_to_set s = String.to_seq s |> SetChar.of_seq

let split_string string =
  let length = String.length string in
  match length mod 2 with
  | 0 ->
      let half = length / 2 in
      let first_half = String.sub string 0 half |> string_to_set in
      let second_half = String.sub string half half |> string_to_set in
      [ first_half; second_half ]
  | _ -> assert false

let find_duplicate sacks =
  let rec inner sets acc =
    match sets with
    | [] -> (
        match SetChar.cardinal acc with
        | 1 -> SetChar.choose acc
        | _ -> assert false)
    | h1 :: rest -> SetChar.inter h1 acc |> inner rest
  in
  List.hd sacks |> inner sacks

let rucksacks = Advent.read_lines "../2022/day3.txt"
let sacks = List.map split_string rucksacks
let priorities = List.map find_duplicate sacks |> List.map priority_score
let result = List.fold_left ( + ) 0 priorities;;

Format.printf "Part 1: %d\n" result

let rec create_groups rucksacks acc =
  match rucksacks with
  | [] -> acc
  | [ _ ] | [ _; _ ] -> assert false
  | h1 :: h2 :: h3 :: rest ->
      [ string_to_set h1; string_to_set h2; string_to_set h3 ] :: acc
      |> create_groups rest

let groups = create_groups rucksacks []
let priorities = List.map find_duplicate groups |> List.map priority_score
let result = List.fold_left ( + ) 0 priorities;;

Format.printf "Part 2: %d\n" result
