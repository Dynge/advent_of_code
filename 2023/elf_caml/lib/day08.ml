module Tokenizer = struct
  type token = Left | Right | Equal | Map of string | EOF | Newline

  let rec peek_token stm =
    let open Input in
    match peek_char stm with
    | None -> EOF
    | Some '\n' -> Newline
    | Some '=' -> Equal
    | Some c when stm.cursor.row_num = 0 -> if c = 'L' then Left else Right
    | Some c when is_alphanumeric c -> Map ""
    | Some _ ->
        let _ = read_char stm in
        peek_token stm

  let rec next_token stm =
    let open Input in
    match read_char stm with
    | None ->
        let _ = close_stream stm in
        EOF
    | Some '\n' -> Newline
    | Some '=' -> Equal
    | Some c when stm.cursor.row_num = 0 -> if c = 'L' then Left else Right
    | Some c when is_alphanumeric c ->
        let map = read_alphanumeric stm [ c ] in
        (* let _ = print_string (map ^ "\n") in *)
        Map map
    | Some _ -> next_token stm
end

module MapLocater = struct
  type t = { value : string; left : string; right : string }
  type 'a stream = Dir of 'a * (unit -> 'a stream)
  type dir = L | R

  let t_to_tuple t = (t.value, (t.left, t.right))

  let parse stm =
    let open Tokenizer in
    let rec parse_aux dirs cur_map maps stm =
      match next_token stm with
      | EOF ->
          let directions = List.rev dirs |> List.to_seq |> Seq.cycle in
          let map = Hashtbl.create (List.length maps) in
          let _ = List.rev maps |> List.to_seq |> Hashtbl.add_seq map in
          (map, directions)
      | Left ->
          (* let _ = print_string "LEFT!" in *)
          parse_aux (L :: dirs) cur_map maps stm
      | Right ->
          (* let _ = print_string "RIGHT!" in *)
          parse_aux (R :: dirs) cur_map maps stm
      | Newline ->
          if peek_token stm = Newline then
            let _ = next_token stm in
            parse_aux dirs cur_map maps stm
          else
            parse_aux dirs
              { value = ""; left = ""; right = "" }
              (t_to_tuple cur_map :: maps)
              stm
      | Map s -> (
          (* let _ = print_string ("Map: " ^ s ^ "\n") in *)
          match peek_token stm with
          | Equal ->
              (* let _ = print_string ("Equal: " ^ s ^ "\n") in *)
              parse_aux dirs { cur_map with value = s } maps stm
          | Map _ ->
              (* let _ = print_string ("MapMap: " ^ s ^ "\n") in *)
              parse_aux dirs { cur_map with left = s } maps stm
          | Newline ->
              (* let _ = print_string ("Newline: " ^ s ^ "\n") in *)
              parse_aux dirs { cur_map with right = s } maps stm
          | _ -> failwith "invalid syntax for maps")
      | Equal -> parse_aux dirs cur_map maps stm
    in

    parse_aux [] { value = ""; left = ""; right = "" } [] stm

  let walk start_nodes is_goal map dirs =
    let move_nodes map dir nodes =
      let rec move_nodes_aux map dir acc = function
        | [] -> acc
        | (_, (hd_left, hd_right)) :: tl -> (
            match dir with
            | L ->
                (* let _ = Format.printf "next val L: %s\n" hd_left in *)
                let next_value = Hashtbl.find map hd_left in
                move_nodes_aux map dir ((hd_left, next_value) :: acc) tl
            | R ->
                (* let _ = Format.printf "next val R: %s\n" hd_right in *)
                let next_value = Hashtbl.find map hd_right in
                move_nodes_aux map dir ((hd_right, next_value) :: acc) tl)
      in
      move_nodes_aux map dir [] nodes
    in

    let rec walk_aux steps cur_nodes map dirs =
      (* (cur_value, (cur_left, cur_right)) *)
      if List.for_all (fun (node, _) -> is_goal node) cur_nodes then steps
      else
        let steps = steps + 1 in
        match Seq.uncons dirs with
        | None -> failwith "dirs should be infinite seq..."
        | Some (L, tl) ->
            let new_nodes = move_nodes map L cur_nodes in
            walk_aux steps new_nodes map tl
        | Some (R, tl) ->
            (* let _ = print_string (cur_value ^ "\n") in *)
            let new_nodes = move_nodes map R cur_nodes in
            walk_aux steps new_nodes map tl
    in

    walk_aux 0 start_nodes map dirs
end

let solution () =
  let open MapLocater in
  let stm = Input.open_stream "day8.txt" in
  let map, dirs = parse stm in

  let start_key = "AAA" in
  let start_node = (start_key, Hashtbl.find map start_key) in
  let is_goal node = node = "ZZZ" in
  let steps_to_zzz = walk [ start_node ] is_goal map dirs in
  let _ = Format.printf "Day08 Part 1: %d\n" steps_to_zzz in
  let start_keys =
    Hashtbl.to_seq_keys map
    |> Seq.filter (fun node ->
           let last_idx = String.length node - 1 in
           (* let _ = print_int last_idx in *)
           (* let _ = print_string (node ^ "\n") in *)
           String.get node last_idx = 'A')
  in
  let start_nodes =
    Seq.map (fun key -> (key, Hashtbl.find map key)) start_keys |> List.of_seq
  in
  let is_goal node =
    let last_idx = String.length node - 1 in
    String.get node last_idx = 'Z'
  in
  let steps_to_zzz = walk start_nodes is_goal map dirs in
  let _ = Format.printf "Day08 Part 2: %d\n" steps_to_zzz in

  ()
