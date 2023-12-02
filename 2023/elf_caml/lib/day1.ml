open Input

let convert_to_num_str = function
  | "one" -> "1"
  | "two" -> "2"
  | "three" -> "3"
  | "four" -> "4"
  | "five" -> "5"
  | "six" -> "6"
  | "seven" -> "7"
  | "eight" -> "8"
  | "nine" -> "9"
  | x -> x

let find_first patterns line =
  let rec aux line (idx, m) = function
    | [] -> m
    | hd :: tl -> (
        try
          let pattern = Str.regexp hd in
          let matched_idx = Str.search_forward pattern line 0 in
          let matched_str = Str.matched_string line in
          if matched_idx = 0 then matched_str
          else if matched_idx < idx then aux line (matched_idx, matched_str) tl
          else aux line (idx, m) tl
        with Not_found -> aux line (idx, m) tl)
  in
  let first = aux line (max_int, "") patterns in
  first |> convert_to_num_str

let find_last patterns line =
  let rec aux line (idx, m) = function
    | [] -> m
    | hd :: tl -> (
        try
          let len_match = String.length hd in
          let len_line = String.length line in
          let pattern = Str.regexp hd in
          let matched_idx = Str.search_backward pattern line len_line in
          let matched_str = Str.matched_string line in
          if matched_idx = len_line - len_match then matched_str
          else if matched_idx > idx then aux line (matched_idx, matched_str) tl
          else aux line (idx, m) tl
        with Not_found -> aux line (idx, m) tl)
  in
  let last = aux line (-1, "") patterns in
  last |> convert_to_num_str

let combine_nums num_left num_right =
  let rec aux num_left num_right acc =
    match (num_left, num_right) with
    | [], [] -> acc
    | hd_l :: tl_l, hd_r :: tl_r ->
        aux tl_l tl_r (int_of_string (hd_l ^ hd_r) :: acc)
    | _ -> failwith "not equal size lists"
  in
  aux num_left num_right []

let solution () =
  let word_patterns =
    [ "one"; "two"; "three"; "four"; "five"; "six"; "seven"; "eight"; "nine" ]
  in
  let num_patterns = [ "1"; "2"; "3"; "4"; "5"; "6"; "7"; "8"; "9" ] in

  let lines = read_lines "../data/day1.txt" in

  let first_matches = List.map (find_first num_patterns) lines in
  let last_matches = List.map (find_last num_patterns) lines in
  let part1_sum =
    List.fold_left ( + ) 0 (combine_nums first_matches last_matches)
  in
  let () = Format.printf "Day1 Part 1: %d\n" part1_sum in

  let first_matches =
    List.map (find_first (num_patterns @ word_patterns)) lines
  in
  let last_matches =
    List.map (find_last (num_patterns @ word_patterns)) lines
  in
  let part2_sum =
    List.fold_left ( + ) 0 (combine_nums first_matches last_matches)
  in
  Format.printf "Day1 Part 2: %d\n" part2_sum
