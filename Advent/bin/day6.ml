let signals = Advent.read_lines "../2022/day6.txt"

module CharSet = Set.Make (Char)

let first_n ls n =
  let rec inner ls n acc =
    match ls with
    | [] -> []
    | h :: rest -> (
        match n with 0 -> acc | n -> h :: acc |> inner rest (n - 1))
  in
  inner ls n []

let index_of_signal signal ~min_unique =
  let rec inner ls min_unique current_index =
    if List.length ls = 0 then assert false
    else
      let unique_count =
        first_n ls min_unique |> List.to_seq |> CharSet.of_seq
        |> CharSet.cardinal
      in
      match unique_count with
      | count when count == min_unique -> current_index
      | _ -> (
          match ls with
          | [] -> assert false
          | _ :: rest -> inner rest min_unique (current_index + 1))
  in
  let chars = String.to_seq signal |> List.of_seq in
  inner chars min_unique min_unique

let sum ints = List.fold_left ( + ) 0 ints

let _ =
  List.map (index_of_signal ~min_unique:4) signals
  |> sum
  |> Format.printf "Part 1: %d\n"

let _ =
  List.map (index_of_signal ~min_unique:14) signals
  |> sum
  |> Format.printf "Part 2: %d\n"
