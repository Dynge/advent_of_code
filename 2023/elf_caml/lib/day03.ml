open Input

module Graph = struct
  type schematic = Number of string | Symbol of char
  type coordinate = { col : int; row : int }

  type node = {
    id : int;
    value : schematic;
    location : coordinate;
    edges : coordinate list;
  }

  let value_length node =
    match node.value with Number s -> String.length s | Symbol _ -> 1

  let add_edges node =
    let start_col = node.location.col - 1 in
    let rec aux node idx acc =
      if idx = node.location.col + value_length node + 1 then acc
      else
        let rows =
          if
            idx < node.location.col
            || idx >= node.location.col + value_length node
          then
            [ node.location.row - 1; node.location.row; node.location.row + 1 ]
          else [ node.location.row - 1; node.location.row + 1 ]
        in
        let coordinates = List.map (fun row -> { row; col = idx }) rows @ acc in
        aux node (idx + 1) coordinates
    in

    { node with edges = aux node start_col [] }

  let to_map nodes =
    let map = Hashtbl.create (List.length nodes) in
    let rec aux map = function
      | [] -> map
      | hd :: tl ->
          let range = List.init (value_length hd) (fun x -> x) in
          let _ =
            List.map
              (fun offset ->
                Hashtbl.add map
                  { hd.location with col = hd.location.col + offset }
                  hd)
              range
          in
          aux map tl
    in
    aux map nodes

  let is_linked_to_symbol map node =
    let rec aux map = function
      | [] -> false
      | hd :: tl -> (
          let edge_node = Hashtbl.find_opt map hd in
          match edge_node with
          | None -> aux map tl
          | Some edge_node -> (
              match edge_node.value with
              | Symbol _ -> true
              | Number _ -> aux map tl))
    in
    aux map node.edges

  let rec exist id nodes =
    match nodes with [] -> false | hd :: tl -> id = hd.id || exist id tl

  let gear_ratio map node =
    let rec gear_ratio_aux map adjacent_numbers = function
      | [] -> 0
      | hd :: tl -> find_edge_numbers map hd tl adjacent_numbers
    and find_edge_numbers map edge_node rest adjacent_numbers =
      let edge_node = Hashtbl.find_opt map edge_node in
      match edge_node with
      | None -> gear_ratio_aux map adjacent_numbers rest
      | Some edge_node -> (
          if exist edge_node.id adjacent_numbers then
            gear_ratio_aux map adjacent_numbers rest
          else
            match edge_node.value with
            | Symbol _ -> gear_ratio_aux map adjacent_numbers rest
            | Number _ -> add_edge_number map edge_node adjacent_numbers rest)
    and add_edge_number map edge_node adjacent_numbers rest =
      let adjacents = edge_node :: adjacent_numbers in
      if List.length adjacents >= 2 then
        List.fold_left
          (fun acc node ->
            let value_int =
              match node.value with
              | Number x -> x
              | _ -> failwith "node is not a number..."
            in
            int_of_string value_int * acc)
          1 adjacents
      else gear_ratio_aux map adjacents rest
    in
    let gear_ratio = gear_ratio_aux map [] node.edges in
    gear_ratio
end

module Parser = struct
  open Graph

  let rec next_node stream =
    match read_char stream with
    | None ->
        let () = close_stream stream in
        None
    | Some '\n' | Some '.' -> next_node stream
    | Some c ->
        let start_coordinate =
          { col = stream.cursor.col_num; row = stream.cursor.row_num }
        in
        if is_digit c then
          let number = read_digit stream [ c ] in
          let node =
            {
              id = 0;
              value = Number number;
              location = start_coordinate;
              edges = [];
            }
          in
          Some node
        else
          let node =
            {
              id = 0;
              value = Symbol c;
              location = start_coordinate;
              edges = [];
            }
          in
          Some node

  let parse stream =
    let rec aux stream nodes =
      match next_node stream with
      | None -> nodes
      | Some node ->
          let node = Graph.add_edges node in
          let node = { node with id = List.length nodes } in
          aux stream (node :: nodes)
    in
    aux stream [] |> List.rev
end

let solution () =
  let open Graph in
  let stream = open_stream "day3.txt" in
  let nodes = Parser.parse stream in
  let graph = to_map nodes in
  let number_nodes =
    List.filter
      (fun node -> match node.value with Number _ -> true | _ -> false)
      nodes
  in

  let sum_of_isolated_values =
    List.filter (fun node -> Graph.is_linked_to_symbol graph node) number_nodes
    |> List.fold_left
         (fun acc node ->
           match node.value with
           | Number x -> acc + int_of_string x
           | _ -> failwith "non Number node in list!")
         0
  in
  let () = Format.printf "Day03 Part 1: %d\n" sum_of_isolated_values in

  let gear_nodes =
    List.filter
      (fun node -> match node.value with Symbol '*' -> true | _ -> false)
      nodes
  in

  let gear_ratio_sum =
    List.fold_left
      (fun acc node ->
        match node.value with
        | Symbol '*' ->
            let gear_ratio = Graph.gear_ratio graph node in
            acc + gear_ratio
        | _ -> failwith "non gear node in list!")
      0 gear_nodes
  in

  Format.printf "Day03 Part 2: %d\n" gear_ratio_sum
