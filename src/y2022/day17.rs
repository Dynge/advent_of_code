use std::fs;

pub fn day17() -> [i32; 2]{


    let data = fs::read_to_string("./2022/day17.txt")
        .and_then(|str| Ok(String::from(str.trim_end())))
        .expect("Cannot read file");

    let structures: Vec<Vec<i32>> = vec![
        vec![16+8+4+2],// 0011110
        vec![
            8,         // 0001000
            16+8+4,    // 0011100
            8,         // 0001000
        ], vec![
            4,          // 0000100
            4,          // 0000100
            16+8+4,    // 0011100
        ],
        vec![
            16,         // 0010000
            16,         // 0010000
            16,         // 0010000
            16,         // 0010000
        ], 
        vec![
            16+8,      // 0011000
            16+8,      // 0011000
        ],
    ];

    let mut tower: Vec<i32> = vec![64+32+16+8+4+2+1]; // 1111111

    let mut movement_iter = data.chars().enumerate().cycle().peekable();
    let mut current_structure_index = 0;
    const LOOP_COUNT: u64 = 2022;
    let mut structure_count = 0;
    while structure_count < LOOP_COUNT {
        let mut structure = structures[current_structure_index].clone();

        let mut falling_down: bool = true;

        let mut structure_lowest_index: usize = tower.len().clone() + 3;
        while falling_down {
            let (_, next_direction) = &movement_iter.next().unwrap();
            let mut should_move_structure = true;

            // Wind
            for (index, line) in structure.iter().rev().enumerate() {
                let tower_structure_index = index + structure_lowest_index;
                if tower_structure_index >= tower.len() {
                    continue;
                }
                if cannot_move_structure(line, &tower[tower_structure_index], &next_direction) {
                    should_move_structure = false;
                }
            }
            if should_move_structure {
                move_structure(&mut structure, next_direction)
            }
            // for line in structure.iter() {
                // println!("Structure: {:b}", line);
            // }


            // Fall down
            should_move_structure = true;
            for (index, line) in structure.iter().rev().enumerate() {
                let tower_structure_index = index + (structure_lowest_index-1);
                if tower_structure_index >= tower.len() {
                    continue;
                }

                if cannot_move_structure(line, &tower[tower_structure_index], &'v') {
                    should_move_structure = false;
                }
            }
            if should_move_structure {
                structure_lowest_index -= 1;
            } else {
                // Insert structure onto tower
                for (index, line) in structure.iter().rev().enumerate() {
                    let tower_structure_index = index + (structure_lowest_index);
                    if tower_structure_index >= tower.len() {
                        // println!("{}", line.clone());
                        tower.push(line.clone());
                        continue;
                    }

                    tower[tower_structure_index] = tower[tower_structure_index] | line
                }
                falling_down = false;
            }
        }
        structure_count += 1;

        current_structure_index = (current_structure_index + 1) % structures.len();
    }

    // for line in tower.iter().rev() {
    //     println!("Tower: {:b}", line);
    // }


    return [tower.len() as i32 - 1, 0]
}

fn move_structure(structure: &mut Vec<i32>, direction: &char) {
    match direction {
        &'>' => {
            if structure.clone().iter().all(|line| line.clone() % 2 == 0) {
                // Does not touch right side
                for line in structure.iter_mut() {
                    *line = *line >> 1;
                }
            }
        },
        &'<' => {
            if structure.clone().iter().all(|line| line.clone() < 64) {
                // Does not touch left side
                for line in structure.iter_mut() {
                    *line = *line << 1;
                }
            }
        },
        _ => panic!("Cannot move by this direction {}", direction),
    }
}

fn cannot_move_structure(structure_line: &i32, tower_line: &i32, direction: &char) -> bool {
    match direction {
        &'>' => {
            if structure_line >> 1 & tower_line == 0i32 {
                return false;
            } 
        },
        &'<' => {
            if structure_line << 1 & tower_line == 0i32 {
                return false;
            } 
        },
        &'v' => {
            if structure_line & tower_line == 0i32 {
                return false;
            } 
        }
        _ => panic!("Dont know how to check a move by this direction {}", direction),
    }
    return true;
}
