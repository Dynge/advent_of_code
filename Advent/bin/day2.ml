module RPS = struct
  type t = Rock | Paper | Scissor

  let of_string = function
    | "A" | "X" -> Rock
    | "B" | "Y" -> Paper
    | "C" | "Z" -> Scissor
    | _ -> assert false

  let from_strategy s theirs =
    match (s, theirs) with
    | "X", Rock | "Z", Paper -> Scissor (* Lose and win with Scissor *)
    | "X", Paper | "Z", Scissor -> Rock (* Lose and win with Rock *)
    | "X", Scissor | "Z", Rock -> Paper (* Lose and win with Paper *)
    | "Y", _ -> theirs (* Draw *)
    | _ -> assert false

  let score t = match t with Rock -> 1 | Paper -> 2 | Scissor -> 3
end

type stategy = Rps | Outcome

module Game = struct
  type t = Played of RPS.t * RPS.t

  let of_string strategy s =
    let theirs, ours = Advent.split_once ' ' s in
    if strategy = Rps then Played (RPS.of_string theirs, RPS.of_string ours)
    else
      Played
        (RPS.of_string theirs, RPS.from_strategy ours (RPS.of_string theirs))

  (* Part 1 *)

  let score played =
    let (Played (theirs, ours)) = played in
    match (theirs, ours) with
    | Rock, Paper | Paper, Scissor | Scissor, Rock ->
        6 + RPS.score ours (* Win *)
    | Rock, Scissor | Paper, Rock | Scissor, Paper ->
        0 + RPS.score ours (* Loss *)
    | _, _ -> 3 + RPS.score ours (* Draw *)

  let rec total_score part strategy_guide init_score =
    match strategy_guide with
    | [] -> init_score
    | head :: tail ->
        total_score part tail (init_score + score (of_string part head))
end

let strategy_guide = Advent.read_lines "../2022/day2.txt"

let () =
  Format.printf "Part 1: %d\nPart 2: %d\n"
    (Game.total_score Rps strategy_guide 0)
    (Game.total_score Outcome strategy_guide 0)
