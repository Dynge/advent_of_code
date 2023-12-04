open Input

module Parser = struct
  type t = C | I of string | Colon | Pipe | EOF | Newline

  let rec next_token stm =
    match read_char stm with
    | None ->
        let () = close_stream stm in
        EOF
    | Some ':' -> Colon
    | Some '|' -> Pipe
    | Some '\n' -> Newline
    | Some ' ' -> next_token stm
    | Some c -> (
        if is_digit c then
          let digit = read_digit stm [ c ] in
          I digit
        else
          match read_alpha stm [ c ] with
          | "Card" -> C
          | x -> failwith ("invalid word in data: " ^ x))

  let parse stm =
    let rec parse_aux acc stm =
      match next_token stm with
      | EOF -> EOF :: acc
      | token -> parse_aux (token :: acc) stm
    in
    parse_aux [] stm |> List.rev
end

module CardGame = struct
  type t = { id : int; winners : int list; draw : int list }

  let collect_numbers tokens =
    let open Parser in
    let rec collect_aux acc = function
      | (Pipe :: _ | Newline :: _ | EOF :: _) as remain -> (acc, remain)
      | I s_number :: tl -> collect_aux (int_of_string s_number :: acc) tl
      | _ -> failwith "invalid token structure for numbers"
    in
    collect_aux [] tokens

  let parse tokens =
    let init_card = { id = 0; winners = []; draw = [] } in
    let open Parser in
    let rec parse_aux acc current_card = function
      | [] -> acc
      | C :: I s :: tl ->
          parse_aux acc { current_card with id = int_of_string s } tl
      | Colon :: tl ->
          let winners, remain = collect_numbers tl in
          parse_aux acc { current_card with winners } remain
      | Pipe :: tl ->
          let draw, remain = collect_numbers tl in
          parse_aux acc { current_card with draw } remain
      | Newline :: tl | EOF :: tl ->
          parse_aux (current_card :: acc) init_card tl
      | _ -> failwith "invalid token structure"
    in

    parse_aux [] init_card tokens |> List.rev

  let winner_count card =
    let rec win_count_aux acc winners = function
      | [] -> acc
      | hd :: tl ->
          if List.mem hd winners then win_count_aux (acc + 1) winners tl
          else win_count_aux acc winners tl
    in
    win_count_aux 0 card.winners card.draw

  let score t =
    let win_count = winner_count t in
    let rec score_aux acc = function
      | 0 -> acc
      | x ->
          let next_x = x - 1 in
          if acc = 0 then score_aux 1 next_x else score_aux (acc * 2) next_x
    in
    score_aux 0 win_count

  let get_winner_cards map card =
    let rec get_winners_aux map id acc = function
      | 0 -> acc
      | x -> (
          let next_x = x - 1 in
          let next_card = Hashtbl.find_opt map (id + x) in
          match next_card with
          | None -> failwith "cannot find id in map"
          | Some next_card -> get_winners_aux map id (next_card :: acc) next_x)
    in

    let win_count = winner_count card in
    get_winners_aux map card.id [] win_count

  let to_map cards =
    let rec to_map_aux map = function
      | [] -> map
      | hd :: tl ->
          let _ = Hashtbl.add map hd.id hd in
          to_map_aux map tl
    in

    let map = Hashtbl.create (List.length cards) in
    to_map_aux map cards

  let play_card_game cards =
    let rec push_to_map multiplier winner_map = function
      | [] -> ()
      | hd :: tl ->
          let card_count =
            match Hashtbl.find_opt winner_map hd.id with
            | None -> 1
            | Some card_count -> card_count
          in
          let _ =
            Hashtbl.add winner_map hd.id (card_count + (1 * multiplier))
          in
          push_to_map multiplier winner_map tl
    in
    let rec play_aux count map winner_map = function
      | [] -> count - 1
      | hd :: tl ->
          let multiplier =
            match Hashtbl.find_opt winner_map hd.id with
            | None -> 1
            | Some x -> x
          in
          let winner_cards = get_winner_cards map hd in
          let () = push_to_map multiplier winner_map winner_cards in
          play_aux (count + (1 * multiplier)) map winner_map tl
    in

    let card_map = to_map cards in
    let winner_map = Hashtbl.create (List.length cards) in
    play_aux 0 card_map winner_map cards
end

let solution () =
  let stm = open_stream "day4.txt" in
  let tokens = Parser.parse stm in
  let cards = CardGame.parse tokens in
  let scores = List.map (fun card -> CardGame.score card) cards in
  let total_score = List.fold_left ( + ) 0 scores in

  let () = Format.printf "Day04 Part 1: %d\n" total_score in

  let card_count = CardGame.play_card_game cards in
  let () = Format.printf "Day04 Part 2: %d\n" card_count in
  ()
