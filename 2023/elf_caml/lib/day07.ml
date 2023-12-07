module Compare = struct
  type t = LtEq | Gt
end

module Hand = struct
  type t = Five | Four | FullHouse | Three | TwoPair | Pair | High of int

  let of_int = function
    | 5 -> Five
    | 4 -> Four
    | 3 -> Three
    | 2 -> Pair
    | _ -> failwith "invalid count"

  let compare a b =
    let open Compare in
    match (a, b) with
    | Five, _ | _, Five -> Five
    | Four, _ | _, Four -> Four
    | FullHouse, _ | _, FullHouse -> FullHouse
    | Three, _ | _, Three -> Three
    | TwoPair, _ | _, TwoPair -> TwoPair
    | Pair, _ | _, Pair -> Pair
    | High a, High b -> if a >= b then High a else High b
end

module CamelPoker = struct
  type t = { rank : int; bet : int; cards : int list; hand : Hand.t }
  type res = { current : int; count : int; diff : int list }
  type result = { high : int; hands : Hand.t list }

  let best_hand result =
    let rec best_hand_aux acc r =
      let open Hand in
      match r.hands with
      | [] -> (
          match acc with
          | None -> failwith "cannot have no result"
          | Some x -> x)
      | Five :: _ -> Five
      | Four :: _ -> Four
      | [ Three; Pair ] | [ Pair; Three ] -> FullHouse
      | [ Pair; Pair ] -> TwoPair
      | hd :: tl -> (
          let r = { r with hands = tl } in
          match acc with
          | None -> best_hand_aux (Some hd) r
          | Some x -> best_hand_aux (Some (Hand.compare hd x)) r)
    in
    best_hand_aux None result

  let equals cards =
    let rec eq_aux res acc = function
      | [] ->
          let res =
            if acc.count > 1 then
              { res with hands = Hand.of_int acc.count :: res.hands }
            else res
          in
          let acc = { acc with current = min_int; count = 0 } in
          if List.length acc.diff > 0 then
            eq_aux res { acc with diff = [] } acc.diff
          else res
      | hd :: tl ->
          if acc.current = min_int then
            eq_aux res { acc with current = hd; count = acc.count + 1 } tl
          else if hd = acc.current then
            eq_aux res { acc with count = acc.count + 1 } tl
          else eq_aux res { acc with diff = hd :: acc.diff } tl
    in
    let res = { current = min_int; count = 0; diff = [] } in
    let result = { hands = []; high = min_int } in
    match cards with
    | [] -> result
    | hd :: tl ->
        eq_aux { result with high = hd } { res with current = hd; count = 1 } tl
end

let solution () = ()
