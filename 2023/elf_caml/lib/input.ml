open Str
open String
open In_channel

let read_lines file =
  let file = Unix.getenv "HOME" ^ "/git/advent_of_code/2023/data/" ^ file in
  with_open_text file input_all |> split (regexp "\n")

let split_once ch str =
  let[@ocaml.warning "-8"] [ left; right ] = split_on_char ch str in
  (left, right)

(* stream *)
type cursor = { row_num : int; col_num : int }

type stream = {
  mutable chr : char option;
  mutable cursor : cursor;
  mutable prev_cursor : cursor option;
  chan : in_channel;
}

let open_stream file =
  let file = Unix.getenv "HOME" ^ "/git/advent_of_code/2023/data/" ^ file in
  {
    chr = None;
    cursor = { row_num = 0; col_num = -1 };
    prev_cursor = None;
    chan = open_in file;
  }

let close_stream stm = close_in stm.chan

let advance_cursor stm c =
  let _ = stm.prev_cursor <- Some stm.cursor in
  match c with
  | None -> ()
  | Some '\n' ->
      let next_cursor = { row_num = stm.cursor.row_num + 1; col_num = -1 } in
      let _ = stm.cursor <- next_cursor in
      ()
  | Some _ ->
      let next_cursor = { stm.cursor with col_num = stm.cursor.col_num + 1 } in
      let _ = stm.cursor <- next_cursor in
      ()

let read_char stm =
  match stm.chr with
  | None ->
      let c = input_char stm.chan in
      if c = None then c
      else
        let () = advance_cursor stm c in
        c
  | Some c ->
      let _ = stm.chr <- None in
      let () = advance_cursor stm (Some c) in
      Some c

let peek_char stm =
  match stm.chr with
  | None ->
      let c = input_char stm.chan in
      let _ = stm.chr <- c in
      c
  | Some _ -> failwith "cannot peek already peeked value"

let unread_char stm c =
  let _ = stm.chr <- Some c in
  match stm.prev_cursor with
  | None -> failwith "cannot unread without a prev_cursor position"
  | Some prev ->
      let _ = stm.cursor <- prev in
      stm.prev_cursor <- None

(* character *)
let is_digit c =
  let code = Char.code c in
  code >= Char.code '0' && code <= Char.code '9'

let is_alpha c =
  let code = Char.code c in
  (code >= Char.code 'A' && code <= Char.code 'Z')
  || (code >= Char.code 'a' && code <= Char.code 'z')

let is_whitespace c = c = '\t' || c = ' '
let string_of_chars chars = List.rev chars |> List.to_seq |> String.of_seq

let rec read_alpha stream acc =
  let next_char = peek_char stream in
  match next_char with
  | None -> string_of_chars acc
  | Some c when not (is_alpha c) -> string_of_chars acc
  | Some c ->
      let _ = read_char stream in
      read_alpha stream (c :: acc)

let rec read_digit stream acc =
  let next_char = peek_char stream in
  match next_char with
  | None -> string_of_chars acc
  | Some c when not (is_digit c) -> string_of_chars acc
  | Some c ->
      let _ = read_char stream in
      read_digit stream (c :: acc)
