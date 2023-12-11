module Hand = struct
  type t = Five | Four | FullHouse | Three | TwoPair | Pair | High

  let to_string = function
    | Five -> "Five"
    | Four -> "Four"
    | FullHouse -> "FullHouse"
    | Three -> "Three"
    | TwoPair -> "TwoPair"
    | Pair -> "Pair"
    | High -> "High"

  let of_int = function
    | 5 -> Five
    | 4 -> Four
    | 3 -> Three
    | 2 -> Pair
    | _ -> failwith "invalid count"

  (** Compares two Hand.t values. Return -1 if second argument is highest *)
  let compare_t a b =
    if a = b then 0
    else
      match (a, b) with
      | Five, _ -> -1
      | _, Five -> 1
      | Four, _ -> -1
      | _, Four -> 1
      | FullHouse, _ -> -1
      | _, FullHouse -> 1
      | Three, _ -> -1
      | _, Three -> 1
      | TwoPair, _ -> -1
      | _, TwoPair -> 1
      | Pair, _ -> -1
      | _, Pair -> 1
      | _ -> failwith "invalid cards for comparison"

  let compare_hand (hand_a, hand_b) (cards_a, cards_b) =
    let rec find_largest_aux = function
      | hd_a :: tl_a, hd_b :: tl_b ->
          let comp = hd_b - hd_a in
          if comp = 0 then find_largest_aux (tl_a, tl_b) else comp
      | _ -> failwith "invalid lists for comparison"
    in
    match compare_t hand_a hand_b with
    | 0 -> find_largest_aux (cards_a, cards_b)
    | x -> x

  let compare_hand_joker (hand_a, hand_b) (cards_a, cards_b) =
    let rec find_largest_aux = function
      | hd_a :: tl_a, hd_b :: tl_b ->
          let hd_a = if hd_a = 11 then 1 else hd_a in
          let hd_b = if hd_b = 11 then 1 else hd_b in
          let comp = hd_b - hd_a in
          if comp = 0 then find_largest_aux (tl_a, tl_b) else comp
      | _ -> failwith "invalid lists for comparison"
    in
    match compare_t hand_a hand_b with
    | 0 -> find_largest_aux (cards_a, cards_b)
    | x -> x
end

module type CamelPoker = sig
  type t = { rank : int; bet : int; cards : int list; hand : Hand.t }

  val best_hand : t -> t
  val best_hand_joker : t -> t
  val add_rank : t list -> t list
  val add_rank_joker : t list -> t list
end

module CamelPoker : CamelPoker = struct
  type t = { rank : int; bet : int; cards : int list; hand : Hand.t }

  let equals cards =
    let rec eq_aux current acc rest = function
      | [] -> (
          let count, _ = current in
          let acc = count :: acc in
          match rest with
          | [] -> List.rev acc
          | hd :: tl -> eq_aux (1, hd) acc [] tl)
      | hd :: tl ->
          let cur_count, cur_card = current in
          if cur_card = hd then eq_aux (cur_count + 1, cur_card) acc rest tl
          else eq_aux current acc (hd :: rest) tl
    in
    let equal_cards =
      match cards with [] -> [] | hd :: tl -> eq_aux (1, hd) [] [] tl
    in
    let equal_cards = List.sort (fun p_c n_c -> n_c - p_c) equal_cards in
    equal_cards

  let rec joker_count count rest = function
    | [] -> (count, rest)
    | hd :: tl ->
        if hd = 11 then joker_count (count + 1) rest tl
        else joker_count count (hd :: rest) tl

  let equals_joker cards =
    let rec eq_aux current acc rest = function
      | [] -> (
          let count, _ = current in
          let acc = count :: acc in
          match rest with
          | [] -> List.rev acc
          | hd :: tl -> eq_aux (1, hd) acc [] tl)
      | hd :: tl ->
          let cur_count, cur_card = current in
          if cur_card = hd then eq_aux (cur_count + 1, cur_card) acc rest tl
          else eq_aux current acc (hd :: rest) tl
    in
    let jokers, rest = joker_count 0 [] cards in
    let equal_cards =
      match rest with [] -> [ 0 ] | hd :: tl -> eq_aux (1, hd) [] [] tl
    in
    let equal_cards = List.sort (fun p_c n_c -> n_c - p_c) equal_cards in

    let equal_cards =
      match equal_cards with
      | [] -> failwith "equals cannot be empty..."
      | hd :: tl -> (hd + jokers) :: tl
    in
    equal_cards

  let best_hand_joker hand =
    let open Hand in
    let best_hand =
      match equals_joker hand.cards with
      | 5 :: _ -> Five
      | 4 :: _ -> Four
      | 3 :: 3 :: _ | 3 :: 2 :: _ -> FullHouse
      | 3 :: _ -> Three
      | 2 :: 2 :: _ -> TwoPair
      | 2 :: 1 :: _ -> Pair
      | 1 :: _ -> High
      | x :: _ ->
          failwith ("not a valid result of equal joker: " ^ string_of_int x)
      | [] -> failwith "equal in joker cannot be empty"
    in
    { hand with hand = best_hand }

  let best_hand hand =
    let open Hand in
    let best_hand =
      match equals hand.cards with
      | [ 5 ] -> Five
      | 4 :: _ -> Four
      | [ 3; 2 ] -> FullHouse
      | 3 :: _ -> Three
      | 2 :: 2 :: _ -> TwoPair
      | 2 :: 1 :: _ -> Pair
      | 1 :: _ -> High
      | _ -> failwith "not a valid result of equal"
    in
    { hand with hand = best_hand }

  let rec add_rank_aux count acc = function
    | [] -> List.rev acc
    | hd :: tl -> add_rank_aux (count + 1) ({ hd with rank = count } :: acc) tl

  let add_rank hands =
    let sorted_hands =
      List.sort
        (fun p_hand n_hand ->
          -1
          * Hand.compare_hand (p_hand.hand, n_hand.hand)
              (p_hand.cards, n_hand.cards))
        hands
    in
    add_rank_aux 1 [] sorted_hands

  let add_rank_joker hands =
    let sorted_hands =
      List.sort
        (fun p_hand n_hand ->
          -1
          * Hand.compare_hand_joker (p_hand.hand, n_hand.hand)
              (p_hand.cards, n_hand.cards))
        hands
    in
    add_rank_aux 1 [] sorted_hands
end

module Parser = struct
  type t = Card of int | Bet of int | EOF

  let rec next_token stm =
    let open Input in
    match read_char stm with
    | None ->
        let _ = close_stream stm in
        EOF
    | Some '\n' -> next_token stm
    | Some ' ' -> Bet (read_digit stm [] |> int_of_string)
    | Some 'A' -> Card 14
    | Some 'K' -> Card 13
    | Some 'Q' -> Card 12
    | Some 'J' -> Card 11
    | Some 'T' -> Card 10
    | Some c ->
        let ascii_of_char = int_of_char c in
        Card (ascii_of_char - Char.code '0')

  let parse_hands stm =
    let open CamelPoker in
    let init_hand = { rank = 0; bet = 0; cards = []; hand = Hand.High } in
    let rec parse_hands_aux current acc stm =
      match next_token stm with
      | EOF -> List.rev acc
      | Bet i ->
          parse_hands_aux init_hand
            ({ current with bet = i; cards = List.rev current.cards } :: acc)
            stm
      | Card c ->
          parse_hands_aux { current with cards = c :: current.cards } acc stm
    in
    parse_hands_aux init_hand [] stm
end

let solution () =
  let open CamelPoker in
  let stm = Input.open_stream "day7.txt" in
  let init_hands = Parser.parse_hands stm in

  let hands = List.map (fun hand -> best_hand hand) init_hands |> add_rank in
  let part1_result =
    List.fold_left (fun acc hand -> acc + (hand.rank * hand.bet)) 0 hands
  in
  let _ = Format.printf "Day07 Part 1: %d\n" part1_result in

  let joker_hands =
    List.map (fun hand -> best_hand_joker hand) init_hands |> add_rank_joker
  in
  let part2_result =
    List.fold_left (fun acc hand -> acc + (hand.rank * hand.bet)) 0 joker_hands
  in
  let _ = Format.printf "Day07 Part 2: %d\n" part2_result in

  ()
