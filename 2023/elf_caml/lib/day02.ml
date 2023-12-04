open Input

type tokens =
  | Game
  | Int of int
  | R
  | G
  | B
  | Semicolon
  | Comma
  | Colon
  | EOF
  | Newline

type color = Red of int | Green of int | Blue of int
type draw = { red : color; green : color; blue : color }
type game = { id : int; cubes : draw list }

let max_color color1 color2 =
  match (color1, color2) with
  | (Red i, Red j | Green i, Green j | Blue i, Blue j) when i >= j -> color1
  | (Red i, Red j | Green i, Green j | Blue i, Blue j) when i < j -> color2
  | _ -> failwith "illegal comparison of different colors"

let color_of int = function
  | R -> Red int
  | G -> Green int
  | B -> Blue int
  | _ -> failwith "illegal color token"

let rec next_token stream =
  let next_char = read_char stream in
  match next_char with
  | None ->
      let () = close_stream stream in
      EOF
  | Some ',' -> Comma
  | Some ';' -> Semicolon
  | Some ':' -> Colon
  | Some '\n' -> Newline
  | Some c ->
      if is_whitespace c then skip_whitespace stream
      else if is_alpha c then
        match read_alpha stream [ c ] with
        | "Game" -> Game
        | "red" -> R
        | "green" -> G
        | "blue" -> B
        | x -> failwith ("dont know what this is: " ^ x)
      else
        let digit_string = read_digit stream [ c ] in
        Int (int_of_string digit_string)

and skip_whitespace stream =
  let next_char = peek_char stream in
  match next_char with
  | None -> EOF
  | Some c ->
      if is_whitespace c then
        let _ = read_char stream in
        skip_whitespace stream
      else next_token stream

let parse_color stream prev_token =
  let rec aux stream prev_token color =
    let t = next_token stream in
    match t with
    | Comma -> color
    | Semicolon ->
        let () = unread_char stream ';' in
        color
    | Newline ->
        let () = unread_char stream '\n' in
        color
    | Int _ -> aux stream t (Red 0)
    | (R | G | B) as cl -> (
        match prev_token with
        | Int d -> aux stream cl (color_of d cl)
        | _ -> failwith "illegal syntax of color")
    | _ -> failwith "illegal syntax of color"
  in
  aux stream prev_token (Red 0)

let parse_draw stream =
  let rec aux stream draw draw_list =
    let t = next_token stream in
    match t with
    | Newline | EOF -> List.rev (draw :: draw_list)
    | Semicolon ->
        aux stream
          { red = Red 0; green = Green 0; blue = Blue 0 }
          (draw :: draw_list)
    | Int _ -> (
        let cl = parse_color stream t in
        match cl with
        | Red _ -> aux stream { draw with red = cl } draw_list
        | Green _ -> aux stream { draw with green = cl } draw_list
        | Blue _ -> aux stream { draw with blue = cl } draw_list)
    | _ -> failwith "illegal syntax for draw parse"
  in
  aux stream { red = Red 0; green = Green 0; blue = Blue 0 } []

let parse_game stream =
  let t = next_token stream in
  match t with
  | Int d -> { id = d; cubes = [] }
  | _ -> failwith "illegal syntax for game"

let rec parse stream games =
  let t = next_token stream in
  match t with
  | Game ->
      let game = parse_game stream in
      parse stream (game :: games)
  | Colon -> (
      let draws = parse_draw stream in
      match games with
      | [] -> failwith "games cannot be empty"
      | hd :: tl -> parse stream ({ hd with cubes = draws } :: tl))
  | EOF -> List.rev games
  | _ -> failwith "illegal syntax for file"

let possible_game game =
  let illegal_draws =
    List.filter
      (fun draw ->
        match (draw.red, draw.green, draw.blue) with
        | Red r, Green g, Blue b when r <= 12 && g <= 13 && b <= 14 -> false
        | _ -> true)
      game.cubes
  in

  if List.length illegal_draws > 0 then false else true

let max_draw game =
  let rec aux draws min_draw =
    match draws with
    | [] -> min_draw
    | hd :: tl ->
        aux tl
          {
            red = max_color min_draw.red hd.red;
            green = max_color min_draw.green hd.green;
            blue = max_color min_draw.blue hd.blue;
          }
  in
  aux game.cubes { red = Red 0; green = Green 0; blue = Blue 0 }

let calculate_mins games =
  let rec aux acc = function
    | [] -> acc
    | hd :: tl ->
        let high_draw = max_draw hd in
        aux (high_draw :: acc) tl
  in
  aux [] games

let power_sum high_draws =
  let powers =
    List.map
      (fun draw ->
        match (draw.red, draw.green, draw.blue) with
        | Red r, Green g, Blue b -> r * g * b
        | _ -> failwith "illegal draw colors")
      high_draws
  in

  List.fold_left ( + ) 0 powers

let solution () =
  let stream = open_stream "day2.txt" in
  let games = parse stream [] in
  let possible_games = List.filter possible_game games in

  let id_sum =
    List.fold_left (fun acc game -> acc + game.id) 0 possible_games
  in
  let () = Format.printf "Day02 Part 1: %d\n" id_sum in

  let high_draws = calculate_mins games in
  let p_sum = power_sum high_draws in
  Format.printf "Day02 Part 2: %d\n" p_sum
