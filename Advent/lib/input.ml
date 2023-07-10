let read_lines file =
  In_channel.with_open_text file In_channel.input_all |> Str.(split (regexp "\n"))
;;

let split_once ch str =
  let[@ocaml.warning "-8"] [left; right] = String.split_on_char ch str in
  left, right
;;
