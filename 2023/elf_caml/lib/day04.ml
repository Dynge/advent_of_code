open Input

module Parser = struct
  type t = C | I of string | Colon | Pipe | EOF | Newline

  let rec next_token stm =
    match read_char stm with
    | None -> EOF
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
    let rec parse_aux acc = function
      | EOF -> EOF :: acc
      | token -> parse_aux (token :: acc) (next_token stm)
    in
    parse_aux [] (next_token stm) |> List.rev
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
    let win_count = winner_count card in
    let rec get_winners_aux map id acc = function
      | 0 -> acc
      | x -> (
          let next_x = x - 1 in
          let next_card = Hashtbl.find_opt map (id + x) in
          match next_card with
          | None -> failwith "cannot find id in map"
          | Some next_card -> get_winners_aux map id (next_card :: acc) next_x)
    in
    get_winners_aux map card.id [] win_count

  let to_map cards =
    let map = Hashtbl.create (List.length cards) in
    let rec to_map_aux map = function
      | [] -> map
      | hd :: tl ->
          let _ = Hashtbl.add map hd.id hd in
          to_map_aux map tl
    in
    to_map_aux map cards

  let play_card_game map cards =
    let winner_map = Hashtbl.create (List.length cards) in
    let rec play_aux count map winner_map = function
      | [] -> count - 1
      | hd :: tl ->
          let won_cards =
            match Hashtbl.find_opt winner_map hd.id with
            | None ->
                let winner_cards = get_winner_cards map hd in
                let _ = Hashtbl.add winner_map hd.id winner_cards in
                winner_cards
            | Some winner_cards -> winner_cards
          in
          play_aux (count + 1) map winner_map (won_cards @ tl)
    in
    play_aux 0 map winner_map cards
end

let solution () =
  let stm = open_stream "day4.txt" in
  let tokens = Parser.parse stm in
  let cards = CardGame.parse tokens in
  let scores = List.map (fun card -> CardGame.score card) cards in
  let total_score = List.fold_left ( + ) 0 scores in

  let () = Format.printf "Day04 Part 1: %d\n" total_score in

  let card_map = CardGame.to_map cards in
  let card_count = CardGame.play_card_game card_map cards in
  let () = Format.printf "Day04 Part 2: %d\n" card_count in
  ()
