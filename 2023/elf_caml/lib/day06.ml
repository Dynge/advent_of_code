module Parser = struct
  open Input

  type t = String of string | Int of string | Colon | Newline | EOF

  let rec next_token stm =
    match read_char stm with
    | None ->
        let () = close_stream stm in
        EOF
    | Some '\n' -> Newline
    | Some ':' | Some ' ' -> next_token stm
    | Some c ->
        if is_alpha c then String (read_alpha stm [ c ])
        else Int (read_digit stm [ c ])
end

module BoatRace = struct
  type t = { time : int; distance : int }

  let parse stm =
    let open Parser in
    let rec collect_numbers acc stm =
      match next_token stm with
      | Int i -> collect_numbers (int_of_string i :: acc) stm
      | EOF | Newline -> acc
      | _ -> failwith "syntax error for numbers"
    in
    let rec parse_aux times distances stm =
      match next_token stm with
      | EOF -> (times, distances)
      | String "Time" -> parse_aux (collect_numbers [] stm) distances stm
      | String "Distance" -> parse_aux times (collect_numbers [] stm) stm
      | _ -> failwith "syntax error for parser"
    in
    let times, dists = parse_aux [] [] stm in
    List.fold_left2
      (fun acc time distance -> { time; distance } :: acc)
      [] times dists

  let parse_single stm =
    let open Parser in
    let rec collect_numbers acc stm =
      match next_token stm with
      | Int i -> collect_numbers (acc ^ i) stm
      | EOF | Newline -> int_of_string acc
      | _ -> failwith "syntax error for numbers"
    in
    let rec parse_aux times distances stm =
      match next_token stm with
      | EOF -> (times, distances)
      | String "Time" -> parse_aux (collect_numbers "" stm) distances stm
      | String "Distance" -> parse_aux times (collect_numbers "" stm) stm
      | _ -> failwith "syntax error for parser"
    in
    let time, distance = parse_aux 0 0 stm in
    { time; distance }

  let quadratic race =
    (*
        distance = wait * (total_time - wait)
        distance = wait*total_time - wait^2
               0 = wait*total_time - wait^2 - distance
               0 = -wait^2 + total_time*wait - distance
               0 = -ax^2 + bx - c

        a = -1
        b = time
        c = -distance
    *)
    let a, b, c = (-1, race.time, -race.distance) in
    let b_squared = b * b in
    let four_ac = 4 * a * c in
    let minus_b = float_of_int (-1 * b) in
    let sqrt_b2_4ac = sqrt (float_of_int (b_squared - four_ac)) in
    let low_root = (minus_b +. sqrt_b2_4ac) /. float_of_int (2 * a) in
    let high_root = (minus_b -. sqrt_b2_4ac) /. float_of_int (2 * a) in
    let () = Format.printf "high: %f - low %f\n" high_root low_root in
    1. +. floor high_root -. ceil low_root |> int_of_float
end

let solution () =
  let open Input in
  let stm = open_stream "day6.txt" in
  let races = BoatRace.parse stm in
  let win_counts = List.map BoatRace.quadratic races in
  let win_sum = List.fold_left ( * ) 1 win_counts in
  let () = Format.printf "Day06 Part 1: %d\n" win_sum in

  let stm = open_stream "day6.txt" in
  let race = BoatRace.parse_single stm in
  let win_count = BoatRace.quadratic race in
  let () = Format.printf "Day06 Part 2: %d\n" win_count in

  ()
