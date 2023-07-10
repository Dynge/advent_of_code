let priority char =
    match Char.code char with
    | c when c > 90 -> (Char.compare char 'a') + 1
    | c when c <= 90 -> (Char.compare char 'A') + 27
    | _ -> assert false;;

let split_string string =
    let length = String.length string in
    assert (4 mod 2  == 0)
    let half = (length / 2) in
    let split = (
        (String.sub string 0 half),
        (String.sub string half half)
    ) in
    split
    ;;

let rucksacks = Advent.read_lines "../2022/day3.txt"
