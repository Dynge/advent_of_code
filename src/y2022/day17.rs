use std::{fs, collections::{HashSet, HashMap}};


#[derive(Debug, Hash, PartialEq, Eq, Copy, Clone)]
struct FingerPrint {
    rock_index: usize,
    jet_index: usize,
    // tower_vec: Vec<i32>
}

#[derive(Debug, Hash, PartialEq, Eq, Copy, Clone)]
struct FingerPrintValue {
    tower_height: u64,
    // height_delta: usize,
    rock_count: u64
}


pub fn day17() -> [i64; 2]{
    let data = fs::read_to_string("./2022/day17.txt")
        .and_then(|str| Ok(String::from(str.trim_end())))
        .expect("Cannot read file");

    let rocks: Vec<Vec<i32>> = vec![
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
    let mut tower_delta_vec = vec![];

    let mut jet_cycle = data.chars().enumerate().cycle().peekable();
    let mut current_rock_index = 0;
    const LOOP_COUNT: u64 = 1e12 as u64;
    let mut cache_map = HashMap::<FingerPrint, FingerPrintValue>::new();
    let mut rocks_fallen = 0;
    let mut tower_height = 0;
    let mut not_looped = true;
    // let mut fall_counts = vec![];
    while rocks_fallen < LOOP_COUNT {
        let mut structure = rocks[current_rock_index].clone();

        let mut falling_down: bool = true;

        // let cache_size = 25;
        // let (_, tower_cache) = tower.split_at( tower.len() - cache_size.min(tower.len()) );
        let (direction_index, _) = jet_cycle.peek().unwrap().clone();
        let cache_key = FingerPrint{ 
            rock_index: current_rock_index,
            // tower_vec: tower_cache.to_vec(),
            jet_index: direction_index 
        };
        let cache = cache_map.insert(
            cache_key,
            FingerPrintValue{ 
                tower_height: (tower.len()-1) as u64,
                rock_count: rocks_fallen 
            }
        );

        if not_looped {
            if let Some(fingerprint_value) = cache {
                not_looped = false;
                // println!("tower cache {:?}", tower_cache);
                println!("{:?}", cache_key);
                println!("{:?}", fingerprint_value);
                println!("tower height {}", tower.len() - 1);
                // println!("{:?}", tower_cache);
                // println!("{:?}", tower.get(51-24..52).unwrap());
                // Loop
                let cycle_rocks = rocks_fallen - fingerprint_value.rock_count;
                println!("cycle rocks {}", cycle_rocks);
                let remaining_loops = (LOOP_COUNT - rocks_fallen) / cycle_rocks as u64;
                println!("{}, {} = {}", LOOP_COUNT, rocks_fallen, remaining_loops);
                let cycle_height = (tower.len() - 1)  as u64 - fingerprint_value.tower_height;
                println!("cycle height {}", cycle_height);
                tower_height = cycle_height * remaining_loops;
                // tower_height +=  tower_delta_vec
                //     .get(fingerprint_value.rock_count as usize..(fingerprint_value.rock_count+cycle_rocks) as usize)
                //     .unwrap().iter().sum::<u64>() * remaining_loops;
                rocks_fallen += cycle_rocks as u64 * remaining_loops;
            }
        }

        let mut structure_lowest_index: usize = tower.len().clone() + 3;
        // let mut fall_count = 0;
        let mut tower_delta = 0;
        while falling_down {
            let (_, next_direction) = &jet_cycle.next().unwrap();
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
                        tower_delta += 1;
                        tower.push(line.clone());
                        continue;
                    }

                    tower[tower_structure_index] = tower[tower_structure_index] | line
                }
                falling_down = false;
            }
            // fall_count += 1;
        }

        rocks_fallen += 1;
        tower_delta_vec.push(tower_delta as u64);
        current_rock_index = (current_rock_index + 1) % rocks.len();
        // fall_counts.push(fall_count);
    }

    // println!("{}", fall_counts.iter().max().unwrap());

    // for line in tower.get(50..200).unwrap().iter().rev() {
    //     println!("Tower: {:b}", line);
    // }
    //
    //
    println!("tower height final before {}", tower_height);
    tower_height += (tower.len() - 1) as u64;
    println!("tower height final after {}", tower_height);


    return [tower_height as i64, 1507692307690]
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
