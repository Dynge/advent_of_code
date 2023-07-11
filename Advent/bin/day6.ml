let signals = Advent.read_lines "../2022/day6.txt"

module CharSet = Set.Make (Char)

let first_n list n =
  let rec inner list n acc =
    match list with
    | [] -> []
    | h :: rest -> (
        match n with 0 -> acc | n -> h :: acc |> inner rest (n - 1))
  in
  inner list n []

let index_of_signal signal ~min_unique =
  let rec inner list min_unique current_index =
    let unique_count =
      first_n list min_unique |> List.to_seq |> CharSet.of_seq
      |> CharSet.cardinal
    in
    match unique_count with
    | count when count == min_unique -> current_index
    | _ -> (
        match list with
        | [] -> assert false
        | _ :: rest -> inner rest min_unique (current_index + 1))
  in
  let chars = String.to_seq signal |> List.of_seq in
  inner chars min_unique min_unique

let sum ints = List.fold_left ( + ) 0 ints
 

let _ =
  List.map (index_of_signal ~min_unique:4) signals
  |> sum 0 |> Format.printf "Part 1: %d"
