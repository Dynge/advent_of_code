module Tetris = struct
  type t = Line | Cross | LeftHook | Bar | Box

  let piece_to_string rock =
    match rock with
    | Line -> "Line"
    | Cross -> "Cross"
    | LeftHook -> "LeftHook"
    | Bar -> "Bar"
    | Box -> "Box"
end

module Piece = struct
  type t = P of Tetris.t * int list

  let to_string = function
    | P (r, []) -> Tetris.piece_to_string r ^ ""
    | P (r, hd :: _) ->
        "<" ^ Tetris.piece_to_string r ^ ": " ^ string_of_int hd ^ ">"
end

module Jet = struct
  type t = Right | Left

  let of_string = function '<' -> Left | '>' -> Right | _ -> assert false
  let to_string = function Left -> "Left" | Right -> "Right"

  let shift_left rock =
    let open Piece in
    let rec inner rock acc =
      match rock with
      | P (r, []) -> P (r, List.rev acc)
      | P (r, hd :: tail) ->
          let shifted_head = Int.shift_left hd 1 |> Int.min 128 in
          inner (P (r, tail)) (shifted_head :: acc)
    in
    inner rock []

  let shift_right rock =
    let open Piece in
    let rec inner rock acc =
      match rock with
      | P (r, []) -> P (r, List.rev acc)
      | P (r, hd :: tail) ->
          let shifted_head = Int.shift_right hd 1 |> Int.max 1 in
          inner (P (r, tail)) (shifted_head :: acc)
    in
    inner rock []

  let push_n jets ~rock ~n =
    let rec inner jets rock n =
      let _ = Format.printf "%s\n" (Piece.to_string rock) in
      match n with
      | 0 -> rock
      | n ->
          let new_rock =
            match jets with
            | [] -> assert false
            | Right :: tail -> shift_right rock
            | Left :: tail -> shift_left rock
          in
          let jet_tail =
            match jets with [] | [ _ ] -> assert false | _ :: t -> t
          in
          inner jet_tail new_rock (n - 1)
    in
    inner jets rock n
end

module Tower = struct
  let init height = List.init height (fun _ -> 128)
  let fall tower piece = ()
end

let pieces =
  let open Piece in
  [
    P (Line, [ 16 + 8 + 4 + 2 ]);
    P (Cross, [ 8; 16 + 8 + 4; 8 ]);
    P (LeftHook, [ 4; 4; 16 + 8 + 4 ]);
    P (Bar, [ 16; 16; 16; 16 ]);
    P (Box, [ 16 + 8; 16 + 8 ]);
  ]

let tower = Tower.init 1
let explode s = List.init (String.length s) (String.get s)

let jets =
  Advent.read_lines "../2022/day17.txt"
  |> List.hd |> explode |> List.map Jet.of_string

(* let first_piece = List.nth pieces 0 *)
let _ = Jet.push_n jets ~rock:(List.nth pieces 0) ~n:3
(* for n = 0 to 100 do *)
(*   let _ = Format.printf "%s" (Piece.to_string (List.nth pieces 0)) in *)
(*   let remainder = n mod List.length jets in *)
(*   List.nth jets remainder *)
(*   |> (fun acc jet -> acc ^ Jet.to_string jet) "" *)
(*   |> Format.printf "%s\n" *)
(*     (* let jet = List.nth jets remainder in *) *)
(*     (* pieces.(0) <- Jet.push_n jet pieces.(0) 1 *) *)
(* done *)
