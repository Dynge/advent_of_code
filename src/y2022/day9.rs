use std::{fs, collections::{HashMap, HashSet}};

use ndarray::{array, Array1};

pub fn day9() -> Vec<i32> {
    let data = fs::read_to_string("./2022/day9/data.txt").expect("Couldn't read data :(");

    let mut result: Vec<i32> = vec![];

    // Part 1

    let move_lines = data.trim_end().split("\n");

    let commands = move_lines.map(|line| line.split(" ").collect::<Vec<&str>>()).collect::<Vec<Vec<&str>>>();
    //
    //
    // let mut two_knot_rope: Vec<Array1<i32>> = vec![array![0,0], array![0,0]];
    // let terry_positions = move_rope(&commands, &mut two_knot_rope);
    //
    // result.push(terry_positions);


    // Part 2
    
    println!("PART 2");
    let mut ten_knot_rope: Vec<Array1<i32>> = vec![
        array![0,0], array![0,0],
        array![0,0], array![0,0],
        array![0,0], array![0,0],
        array![0,0], array![0,0],
    ];
    let terry_positions = move_rope(&commands, &mut ten_knot_rope);

    result.push(terry_positions);

    return result;

}

fn move_rope(commands: &Vec<Vec<&str>>, rope: &mut Vec<Array1<i32>>) -> i32 {
    let mut tail_positions = HashSet::from([
        (array![0, 0])
    ]);

    let move_directions = HashMap::from([
        ("D", array![1, 0]),
        ("U", array![-1, 0]),
        ("R", array![0, 1]),
        ("L", array![0, -1]),
    ]);

    for command in commands {
        let direction = move_directions.get(command[0]).expect("Invalid direction.");
        let count: i32 = command[1].parse().expect("Not a digit.");
        let mut i = 0;
        i += 1;
        for _ in 0..count {
            println!("LOOP {}", i);
            for index in 0..rope.len()-1 {

                println!("Run...");
                let henrys_last_position = rope[index].to_owned();
                if index == 0 {
                    rope[index] += direction;
                }
                rope[index+1] = update_tail_position(
                    henrys_last_position, &rope[index], &rope[index+1]
                );

                if index == rope.len()-2 {
                    tail_positions.insert(rope[index+1].clone());
                }

                println!("H final: {}", rope[index]);
                println!("T final: {}", rope[index+1]);

            }
        }
        if i == 5 {
            panic!("hello")
        }
    }

    return tail_positions.len().try_into().unwrap();
}

fn update_tail_position(h_last: Array1<i32>, h_now: &Array1<i32>, t:&Array1<i32>) -> Array1<i32> {
    let unaccepable = unacceptable_distance(h_now, &t);
    if unaccepable {
        println!("Unaccepable: {}", &unaccepable);
        return h_last;
    }
    return t.clone();
}

fn unacceptable_distance(h: &Array1<i32>, t: &Array1<i32>) -> bool {
    println!("H: {}", h);
    println!("T: {}", t);
    let diff = h - t;
    println!("D: {}", diff);
    
    let diff_distance: Vec<bool> = diff.map(|value| value.abs() < 2).to_vec();
    println!("DBools: {}", diff);
    let acceptable_distance_arr: Vec<&bool> = diff_distance.iter().filter(|&value| value.eq(&true)).collect();

    return acceptable_distance_arr.len() != 2

}
