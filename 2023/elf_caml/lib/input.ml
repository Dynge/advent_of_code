open Str
open String
open In_channel

let read_lines file = with_open_text file input_all |> split (regexp "\n")

let split_once ch str =
  let[@ocaml.warning "-8"] [ left; right ] = split_on_char ch str in
  (left, right)

(* stream *)
type stream = {
  mutable chr : char option;
  mutable line_num : int;
  chan : in_channel;
}

let open_stream file = { chr = None; line_num = 1; chan = open_in file }
let close_stream stm = close_in stm.chan

let read_char stm =
  match stm.chr with
  | None ->
      let c = input_char stm.chan in
      if c = Some '\n' then
        let _ = stm.line_num <- stm.line_num + 1 in
        c
      else c
  | Some c ->
      stm.chr <- None;
      Some c

let unread_char stm c = stm.chr <- Some c

(* character *)
let is_digit c =
  let code = Char.code c in
  code >= Char.code '0' && code <= Char.code '9'

let is_alpha c =
  let code = Char.code c in
  (code >= Char.code 'A' && code <= Char.code 'Z')
  || (code >= Char.code 'a' && code <= Char.code 'z')

let is_whitespace c = c = '\t' || c = ' '
