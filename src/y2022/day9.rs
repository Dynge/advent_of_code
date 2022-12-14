use std::{fs, collections::{HashMap, HashSet}};

use ndarray::{array, Array1};


pub fn day9() -> Vec<i32> {
    let data = fs::read_to_string("./2022/day9.txt").expect("Couldn't read data :(");

    let mut result: Vec<i32> = vec![];

    // Part 1
    let move_lines = data.trim_end().split("\n");

    let commands = move_lines.map(|line| line.split(" ").collect::<Vec<&str>>()).collect::<Vec<Vec<&str>>>();


    let mut two_knot_rope: Vec<Array1<i32>> = vec![
        array![0,0], array![0,0]
    ];
    let terry_positions = move_rope(&commands, &mut two_knot_rope);

    result.push(terry_positions);


    // Part 2
    let mut ten_knot_rope: Vec<Array1<i32>> = vec![
        array![0,0], array![0,0],
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

        for _ in 0..count {
            for index in 0..rope.len()-1 {
                if index == 0 {
                    rope[index] += direction;
                }
                rope[index+1] = &rope[index+1] + follow_head_by_moving(
                    &rope[index], &rope[index+1]
                );

                if index == rope.len()-2 {
                    tail_positions.insert(rope[index+1].clone());
                }
            }
        }
    }

    return tail_positions.len().try_into().unwrap();
}

fn follow_head_by_moving(h: &Array1<i32>, t: &Array1<i32>) -> Array1<i32> {
    let diff = h - t;

    if diff.iter().any(|value| value.abs() > 1) {
        return diff.iter().map(|value| value.signum()).collect();
    }
    
    return Array1::from(vec![0,0]);
    
}
