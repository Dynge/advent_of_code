open Input

let lines = read_lines "../data/day1.txt"

let read_calibration line =
  let str_list = Core.String.to_list line in
  let rec filter acc = function
    | [] -> acc
    | hd :: tl ->
        if is_digit hd = true then filter (hd :: acc) tl else filter acc tl
  in

  let rec aux = function
    | [] -> failwith "no items in list"
    | [ c ] -> String.make 1 c ^ String.make 1 c
    | [ c1; c2 ] -> String.make 1 c2 ^ String.make 1 c1
    | hd :: _ :: tl -> aux (hd :: tl)
  in
  let s = filter [] str_list |> aux in
  int_of_string s

let solution () =
  let calibrations = List.map read_calibration lines in
  let calibration_sum = List.fold_left ( + ) 0 calibrations in
  Format.printf "Day1 Part 1: %d" calibration_sum
