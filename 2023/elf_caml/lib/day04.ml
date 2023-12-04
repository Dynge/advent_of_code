open Input

module Parser = struct
  type t = C | I of string | Colon | Pipe | EOF | Newline

  let next_token stm =
    match read_char stm with
    | None -> EOF
    | Some ':' -> Colon
    | Some '|' -> Pipe
    | Some '\n' -> Newline
    | Some c -> (
        if is_digit c then
          let digit = read_digit stm [ c ] in
          I digit
        else
          match read_alpha stm [ c ] with
          | "Card" -> C
          | x -> failwith ("invalid word in data: " ^ x))
end

let solution () = ()
