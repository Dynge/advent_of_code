use std::fs;

use ndarray::arr2;


pub fn day17() -> [i32; 2]{


    let data = fs::read_to_string("./2022/day17.txt")
        .and_then(|str| Ok(String::from(str.trim_end())))
        .expect("Cannot read file");

    let structures: Vec<Vec<i32>> = vec![
        vec![16+8+4+2],// 0011110
        vec![
            16,         // 0010000
            16,         // 0010000
            16,         // 0010000
            16,         // 0010000
        ], 
        vec![
            8,         // 0001000
            16+8+4,    // 0011100
            8,         // 0001000
        ],
        vec![
            16+8,      // 0011000
            16+8,      // 0011000
        ],
        vec![
            4,          // 0000100
            4,          // 0000100
            16+8+4,    // 0011100
        ],
    ];

    let mut tower: Vec<i32> = vec![64+32+16+8+4+2+1]; // 1111111

    let mut movement_iter = data.chars();
    let mut current_structure_index = 0;
    for _ in 0..2022 {

        let mut structure = structures[current_structure_index].clone();
        for _ in 0..3 {
            structure = move_structure(&structure, &movement_iter.next().unwrap());
        }

        let mut not_at_rest: bool = true;

        tower.append(&mut structure);

        let mut tower_structure_indices: Vec<Option<usize>> = vec![None; structure.len()];
        while not_at_rest {
            for index in tower_structure_indices.iter() {
                match index {
                    Some(x) => {
                        if (tower[*x] | structure.last().unwrap()) == 0i32 {

                        }
                    },
                    None => continue,
                };

            }



        }

        current_structure_index = (current_structure_index + 1) % structures.len();


    }


    println!("Move Left {}", (2 << 1)); // = 4
    println!("Move Right {}", (4 >> 1)); // = 2


    return [0, 0]
}

fn move_structure(structure: &Vec<i32>, direction: &char) -> Vec<i32> {
    let mut moved_structure = vec![];
    if direction == &'>' {
        for line in structure {
            moved_structure.push(line >> 1);
        }
    } else if direction == &'<' {
        for line in structure {
            moved_structure.push(line << 1)
        }
    }

    return moved_structure;

}
