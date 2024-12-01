open Input

module Parser = struct
  type t = Int of string | Colon | String of string | EOF | Newline

  let is_alpha_hyphen c =
    let code = Char.code c in
    (code >= Char.code 'A' && code <= Char.code 'Z')
    || (code >= Char.code 'a' && code <= Char.code 'z')
    || code = Char.code '-'

  let rec read_alpha_hyphen stream acc =
    let next_char = peek_char stream in
    match next_char with
    | None -> string_of_chars acc
    | Some c when not (is_alpha_hyphen c) -> string_of_chars acc
    | Some c ->
        let _ = read_char stream in
        read_alpha_hyphen stream (c :: acc)

  let rec next_token stm =
    match read_char stm with
    | None ->
        let () = close_stream stm in
        EOF
    | Some ':' -> Colon
    | Some '\n' -> Newline
    | Some ' ' -> next_token stm
    | Some c -> (
        if is_digit c then
          let digit = read_digit stm [ c ] in
          Int digit
        else
          match read_alpha_hyphen stm [ c ] with
          | "map" -> next_token stm
          | x -> String x)

  let parse stm =
    let rec parse_aux acc stm =
      match next_token stm with
      | EOF -> EOF :: acc
      | token -> parse_aux (token :: acc) stm
    in
    parse_aux [] stm |> List.rev
end

module FarmingP1 = struct
  type type_map = { dest : int; source : int; range : int }

  type t = {
    seeds : int list;
    seed_to_soil : type_map list;
    soil_to_fertilizer : type_map list;
    fertilizer_to_water : type_map list;
    water_to_light : type_map list;
    light_to_temperature : type_map list;
    temperature_to_humidity : type_map list;
    humidity_to_location : type_map list;
  }

  let parse tokens =
    let open Parser in
    let rec numbers_to_map acc = function
      | ([ EOF ] as tl) | Newline :: Newline :: tl -> (acc, tl)
      | Newline :: tl -> numbers_to_map acc tl
      | Int source :: Int dest :: Int range :: tl ->
          let dest, source, range =
            (int_of_string source, int_of_string dest, int_of_string range)
          in
          let type_map = { source; dest; range } in
          numbers_to_map (type_map :: acc) tl
      | _ -> failwith "invalid token structure for numbers to map"
    in

    let rec numbers_to_list acc = function
      | ([] as tl) | Newline :: Newline :: tl -> (acc |> List.rev, tl)
      | Int seed :: tl -> numbers_to_list (int_of_string seed :: acc) tl
      | _ -> failwith "invalid token structure for numbers to list"
    in

    let rec parse_aux t = function
      | [ EOF ] -> t
      | Newline :: Newline :: tl -> parse_aux t tl
      | String "seeds" :: Colon :: tl ->
          let seeds, remain = numbers_to_list [] tl in
          parse_aux { t with seeds } remain
      | String "seed-to-soil" :: Colon :: Newline :: tl ->
          let seed_to_soil, remain = numbers_to_map [] tl in
          parse_aux { t with seed_to_soil } remain
      | String "soil-to-fertilizer" :: Colon :: Newline :: tl ->
          let soil_to_fertilizer, remain = numbers_to_map [] tl in
          parse_aux { t with soil_to_fertilizer } remain
      | String "fertilizer-to-water" :: Colon :: Newline :: tl ->
          let fertilizer_to_water, remain = numbers_to_map [] tl in
          parse_aux { t with fertilizer_to_water } remain
      | String "water-to-light" :: Colon :: Newline :: tl ->
          let water_to_light, remain = numbers_to_map [] tl in
          parse_aux { t with water_to_light } remain
      | String "light-to-temperature" :: Colon :: Newline :: tl ->
          let light_to_temperature, remain = numbers_to_map [] tl in
          parse_aux { t with light_to_temperature } remain
      | String "temperature-to-humidity" :: Colon :: Newline :: tl ->
          let temperature_to_humidity, remain = numbers_to_map [] tl in
          parse_aux { t with temperature_to_humidity } remain
      | String "humidity-to-location" :: Colon :: Newline :: tl ->
          let humidity_to_location, remain = numbers_to_map [] tl in
          parse_aux { t with humidity_to_location } remain
      | _ -> failwith "invalid token list for parser"
    in
    parse_aux
      {
        seeds = [];
        seed_to_soil = [];
        soil_to_fertilizer = [];
        fertilizer_to_water = [];
        water_to_light = [];
        light_to_temperature = [];
        temperature_to_humidity = [];
        humidity_to_location = [];
      }
      tokens

  let rec maps_to i = function
    | [] -> i
    | { dest; source; range } :: tl ->
        if i >= source && i < source + range then
          let dest_index = i - source in
          dest + dest_index
        else maps_to i tl

  let get_locations farm =
    let rec location_aux acc farm = function
      | [] -> acc
      | seed :: tl ->
          let soil = maps_to seed farm.seed_to_soil in
          let fertilizer = maps_to soil farm.soil_to_fertilizer in
          let water = maps_to fertilizer farm.fertilizer_to_water in
          let light = maps_to water farm.water_to_light in
          let temperature = maps_to light farm.light_to_temperature in
          let humidity = maps_to temperature farm.temperature_to_humidity in
          let location = maps_to humidity farm.humidity_to_location in
          location_aux (location :: acc) farm tl
    in
    location_aux [] farm farm.seeds
end

module Farming = struct
  type seed_range = { start : int; length : int }
  type type_map = { dest : int; source : int; range : int }

  type t = {
    seeds : seed_range list;
    seed_to_soil : type_map list;
    soil_to_fertilizer : type_map list;
    fertilizer_to_water : type_map list;
    water_to_light : type_map list;
    light_to_temperature : type_map list;
    temperature_to_humidity : type_map list;
    humidity_to_location : type_map list;
  }

  let parse tokens =
    let open Parser in
    let rec numbers_to_map acc = function
      | ([ EOF ] as tl) | Newline :: Newline :: tl -> (acc, tl)
      | Newline :: tl -> numbers_to_map acc tl
      | Int source :: Int dest :: Int range :: tl ->
          let dest, source, range =
            (int_of_string source, int_of_string dest, int_of_string range)
          in
          let type_map = { source; dest; range } in
          numbers_to_map (type_map :: acc) tl
      | _ -> failwith "invalid token structure for numbers to map"
    in

    let rec read_seeds acc = function
      | ([] as tl) | Newline :: Newline :: tl -> (acc |> List.rev, tl)
      | Int seed :: Int range :: tl ->
          let start, length = (int_of_string seed, int_of_string range) in
          read_seeds ({ start; length } :: acc) tl
      | _ -> failwith "invalid token structure for numbers to list"
    in

    let rec parse_aux t = function
      | [ EOF ] -> t
      | Newline :: Newline :: tl -> parse_aux t tl
      | String "seeds" :: Colon :: tl ->
          let seeds, remain = read_seeds [] tl in
          parse_aux { t with seeds } remain
      | String "seed-to-soil" :: Colon :: Newline :: tl ->
          let seed_to_soil, remain = numbers_to_map [] tl in
          parse_aux { t with seed_to_soil } remain
      | String "soil-to-fertilizer" :: Colon :: Newline :: tl ->
          let soil_to_fertilizer, remain = numbers_to_map [] tl in
          parse_aux { t with soil_to_fertilizer } remain
      | String "fertilizer-to-water" :: Colon :: Newline :: tl ->
          let fertilizer_to_water, remain = numbers_to_map [] tl in
          parse_aux { t with fertilizer_to_water } remain
      | String "water-to-light" :: Colon :: Newline :: tl ->
          let water_to_light, remain = numbers_to_map [] tl in
          parse_aux { t with water_to_light } remain
      | String "light-to-temperature" :: Colon :: Newline :: tl ->
          let light_to_temperature, remain = numbers_to_map [] tl in
          parse_aux { t with light_to_temperature } remain
      | String "temperature-to-humidity" :: Colon :: Newline :: tl ->
          let temperature_to_humidity, remain = numbers_to_map [] tl in
          parse_aux { t with temperature_to_humidity } remain
      | String "humidity-to-location" :: Colon :: Newline :: tl ->
          let humidity_to_location, remain = numbers_to_map [] tl in
          parse_aux { t with humidity_to_location } remain
      | _ -> failwith "invalid token list for parser"
    in
    parse_aux
      {
        seeds = [];
        seed_to_soil = [];
        soil_to_fertilizer = [];
        fertilizer_to_water = [];
        water_to_light = [];
        light_to_temperature = [];
        temperature_to_humidity = [];
        humidity_to_location = [];
      }
      tokens

  let update_ranges map ranges =
    let rec update_ranges_aux acc map = function
      | [] -> acc
      | hd :: tl ->
          let r_start, r_range_ex = (hd.start, hd.length) in
          let r_end_ex = r_start + r_range_ex in
          let map_end_ex = map.source + map.range in
          let offset = map.dest - map.source in
          let split_ranges =
            if r_end_ex <= map.source || r_start >= map_end_ex then [ hd ]
            else if r_start >= map.source && r_end_ex <= map_end_ex then
              [ { hd with start = hd.start + offset } ]
            else if r_start < map.source && r_end_ex > map_end_ex then
              let low_range = map.source - (r_start + 1) in
              let high_range = r_range_ex - low_range - map.range in
              [
                { start = r_start; length = low_range };
                { start = map.dest; length = map.range };
                { start = map.source + map.range; length = high_range };
              ]
            else if r_start >= map.source then
              let low_range = map_end_ex - r_start in
              let high_range = r_end_ex - map_end_ex in
              [
                { start = r_start + offset; length = low_range };
                { start = map_end_ex; length = high_range };
              ]
            else if r_start < map.source then
              let low_range = map.source - (r_start + 1) in
              let high_range = r_end_ex - map.source in
              [
                { start = r_start; length = low_range };
                { start = map.dest; length = high_range };
              ]
            else
              (* let _ = *)
              (*   Format.printf *)
              (* "map.source: %d - map_end_ex: %d - map.range: %d\n\ *)
                 (*      r_start: %d - r_end: %d - r_range: %d\n" *)
              (*     map.source map_end_ex map.range r_start r_end_ex r_range_ex *)
              (* in *)
              failwith "did not expect another option"
          in
          (* let _ = *)
          (*   Format.printf "map.dest: %d - map.source: %d - map.range: %d\n" *)
          (*     map.dest map.source map.range *)
          (* in *)
          update_ranges_aux (acc @ split_ranges) map tl
    in
    update_ranges_aux [] map ranges

  let rec maps_to_ranges ranges = function
    | [] -> ranges
    | hd :: tl ->
        let new_ranges = update_ranges hd ranges in
        (* let _ = Format.printf "Range size: %d\n" (List.length new_ranges) in *)
        (* let _ = *)
        (*   List.map *)
        (*     (fun range -> *)
        (*       Format.printf "r_start: %d - r_range: %d\n" range.start *)
        (*         range.length) *)
        (*     new_ranges *)
        (* in *)
        maps_to_ranges new_ranges tl

  let get_locations farm =
    let rec location_aux acc farm = function
      | [] -> acc
      | seed :: tl ->
          let soil = maps_to_ranges [ seed ] farm.seed_to_soil in
          let fertilizer = maps_to_ranges soil farm.soil_to_fertilizer in
          let water = maps_to_ranges fertilizer farm.fertilizer_to_water in
          let light = maps_to_ranges water farm.water_to_light in
          let temperature = maps_to_ranges light farm.light_to_temperature in
          let humidity =
            maps_to_ranges temperature farm.temperature_to_humidity
          in
          let location = maps_to_ranges humidity farm.humidity_to_location in
          location_aux (location @ acc) farm tl
    in
    location_aux [] farm farm.seeds
end

let solution () =
  let stm = Input.open_stream "day5.txt" in
  let tokens = Parser.parse stm in
  let farm = FarmingP1.parse tokens in
  let locations = FarmingP1.get_locations farm in
  let min_location =
    List.fold_left
      (fun acc loc ->
        let minimum = min acc loc in
        minimum)
      max_int locations
  in
  let () = Format.printf "Day05 Part 1: %d\n" min_location in

  let farm = Farming.parse tokens in
  let locations = Farming.get_locations farm in

  (* let _ = Format.printf "Location size: %d\n" (List.length locations) in *)
  (* let _ = *)
  (*   List.map *)
  (*     (fun range -> *)
  (*       let open Farming in *)
  (*       Format.printf "r_start: %d - r_range: %d\n" range.start range.length) *)
  (*     locations *)
  (* in *)
  let min_location =
    List.fold_left
      (fun acc range ->
        let open Farming in
        let minimum = min acc range.start in
        minimum)
      max_int locations
  in
  let () = Format.printf "Day05 Part 2: %d\n" min_location in

  ()
