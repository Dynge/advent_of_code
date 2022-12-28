use std::{fs, collections::{HashSet, HashMap}};

use ndarray::arr2;

pub fn day17() -> [i64; 2]{


    let data = fs::read_to_string("./2022/day17.txt")
        .and_then(|str| Ok(String::from(str.trim_end())))
        .expect("Cannot read file");

    let structures: Vec<Vec<i32>> = vec![
        vec![
            16+8+4+2      // 0011110
        ],
        vec![
               8,         // 0001000
            16+8+4,       // 0011100
               8,         // 0001000
        ], vec![
                 4,       // 0000100
                 4,       // 0000100
            16+8+4,       // 0011100
        ],
        vec![
            16,           // 0010000
            16,           // 0010000
            16,           // 0010000
            16,           // 0010000
        ], 
        vec![
            16+8,         // 0011000
            16+8,         // 0011000
        ],
    ];

    let mut tower: Vec<i32> = vec![64+32+16+8+4+2+1]; // 1111111

    let mut movement_iter = data.chars().enumerate().cycle().peekable();
    let mut current_structure_index = 0;
    const LOOP_COUNT: u64 = 2022;
    let mut cache = HashSet::<(usize, Vec<i32>, usize)>::new();
    let mut cache_map = HashMap::<(usize, Vec<i32>, usize), (u64, u64)>::new();
    let mut structure_count = 0;
    let mut tower_height = 0;
    let mut not_looped = true;
    // let mut fall_counts = vec![];
    while structure_count < LOOP_COUNT {
        let mut structure = structures[current_structure_index].clone();

        let mut falling_down: bool = true;

        let cache_size = 50;
        let (_, tower_cache) = tower.split_at(tower.len()-cache_size.min(tower.len()));
        let (direction_index, _) = movement_iter.peek().unwrap().clone();
        let cache_key = (current_structure_index, tower_cache.to_vec(), direction_index);
        let cache = cache_map.get(&cache_key);
        if let Some((cached_height, cached_rocks)) = cache {
            if not_looped == false {
                break;
            }
            not_looped = false;
            // println!("tower cache {:?}", tower_cache);
            // Loop
            let cycle_rocks = structure_count - cached_rocks;
            println!("{}", cycle_rocks);
            let remaining_loops = (LOOP_COUNT - cached_rocks) / cycle_rocks as u64;
            println!("{}, {} = {}", LOOP_COUNT, structure_count, remaining_loops);
            // TODO: Calculate height instead of making a stupidly large vector
            let cycle_height = (tower.len() - 1)  as u64 - cached_height;
            println!("{}", cycle_height);
            tower_height = cached_height + cycle_height * remaining_loops;
            // tower = tower.repeat(remaining_loops as usize);
            structure_count = cached_rocks + cycle_rocks as u64 * remaining_loops;
        }

        let mut structure_lowest_index: usize = tower.len().clone() + 3;
        // let mut fall_count = 0;
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
            // fall_count += 1;
        }

        structure_count += 1;
        cache_map.insert(cache_key, ((tower.len()-1) as u64, structure_count));
        current_structure_index = (current_structure_index + 1) % structures.len();
        // fall_counts.push(fall_count);
    }

    // println!("{}", fall_counts.iter().max().unwrap());

    // for line in tower.iter().rev() {
    //     println!("Tower: {:b}", line);
    // }
    //
    //
    println!("tower height final before {}", tower_height);
    tower_height += (tower.len() - 1) as u64;
    println!("tower height final after {}", tower_height);


    return [tower_height as i64, 0]
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
