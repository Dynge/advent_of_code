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
          let () =
            Format.printf
              "i: %d, source: %d, dest: %d, range: %d, dest_index: %d\n" i
              source dest range dest_index
          in
          dest + dest_index
        else maps_to i tl

  let get_locations farm =
    let rec location_aux acc farm = function
      | [] -> acc
      | seed :: tl ->
          let soil = maps_to seed farm.seed_to_soil in
          let () = print_int soil in
          let () = print_string "\n" in
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
  open FarmingP1

  type seed_range = { source : int; range : int }

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
          let source, range = (int_of_string seed, int_of_string range) in
          read_seeds ({ source; range } :: acc) tl
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

  let maps_to i map =
    match map with
    | { dest; source; range } ->
        if i >= source && i < source + range then
          let dest_index = i - source in
          let () =
            Format.printf
              "i: %d, source: %d, dest: %d, range: %d, dest_index: %d\n" i
              source dest range dest_index
          in
          dest + dest_index
        else i

  let rec maps_to_low_high (low, high) = function
    | [] -> (low, high)
    | ({ dest; source; range } as map) :: tl ->
        let max_source = source + range - 1 in
        if
          (low > source && high > source)
          || (low < max_source && high < max_source)
        then (* completely outside range *)
          (low, high)
        else
          let low =
            let low_map = maps_to low map in
            if low > source || low < source then low_map
            else if source < low_map then dest
            else low_map
          in

          let high =
            let high_map = maps_to high map in
            if high_map < dest + range then high_map
            else if source + range > high_map then dest
            else high_map
          in

          let low = min low high in
          let high = max low high in
          maps_to_low_high (low, high) tl

  let get_locations farm =
    let rec location_aux acc farm = function
      | [] -> acc
      | seed :: tl ->
          let soil =
            maps_to_low_high
              (seed.source, seed.source + seed.range)
              farm.seed_to_soil
          in
          let fertilizer = maps_to_low_high soil farm.soil_to_fertilizer in
          let water = maps_to_low_high fertilizer farm.fertilizer_to_water in
          let light = maps_to_low_high water farm.water_to_light in
          let temperature = maps_to_low_high light farm.light_to_temperature in
          let humidity =
            maps_to_low_high temperature farm.temperature_to_humidity
          in
          let location = maps_to_low_high humidity farm.humidity_to_location in
          location_aux (location :: acc) farm tl
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
  let min_location =
    List.fold_left
      (fun acc (low, _) ->
        let minimum = min acc low in
        minimum)
      max_int locations
  in
  let () = Format.printf "Day05 Part 2: %d\n" min_location in

  ()
