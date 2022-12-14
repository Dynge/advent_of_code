use std::collections::HashMap;
use std::fs;


pub fn day2() -> [i32; 2] {
    let result = [p1(), p2()];
    return result;
}


fn p1() -> i32 {
    let strategy = HashMap::from([
        ("X", 1), //rock
        ("Y", 2), //paper
        ("Z", 3), //scissor
        ("A", 1), //rock
        ("B", 2), //paper
        ("C", 3), //scissor
    ]);

    let data = load_data();

    let mut points = 0;

    for line in data {
        let (opponent, me) = line.split_once(" ").expect("No whitespace");
        let result = strategy.get(opponent).expect("not found") - strategy.get(me).expect("not found");
        match result {
            -1 | 2 => points += strategy.get(me).expect("not found") + 6,
            0 => points += strategy.get(me).expect("not found") + 3,
            1 | -2 => points += strategy.get(me).expect("not found") + 0,
            _ => panic!("shouldnt happen")
        }
    }
    return points;
}

fn p2() -> i32 {
    let strategy = HashMap::from([
        ("X", 0), //loss
        ("Y", 3), //draw
        ("Z", 6), //win
        ("A", 1), //rock
        ("B", 2), //paper
        ("C", 3), //scissor
    ]);

    let data = load_data();

    let mut points = 0;

    for line in data {
        let (opponent, result) = line.split_once(" ").expect("No whitespace");
        match result {
            "X" => points += strategy.get(result).expect("not found") + ((((strategy.get(opponent).unwrap() - 1) + 2) % 3) + 1),
            "Y" => points += strategy.get(result).expect("not found") + strategy.get(opponent).unwrap(),
            "Z" => points += strategy.get(result).expect("not found") + ((((strategy.get(opponent).unwrap() - 1) + 1) % 3) + 1),
            _ => panic!("Should not happen.")
        }

    }
    return points;
}

fn load_data() -> Vec<String> {
    let data = fs::read_to_string("./2022/day2.txt")
        .expect("Couldn't read data :(");
    let lines: Vec<&str> = data.lines().collect();
    let owned_strings: Vec<String> = lines.iter().map(|&line| String::from(line)).collect();
    return owned_strings;
}
