use std::fs;

use ndarray::arr2;


pub fn day17() -> [i32; 2]{


    let data = fs::read_to_string("./2022/day17.txt").expect("Cannot read file");

    let structures: Vec<Vec<i32>> = vec![
        vec![32+16+8+4],// 0011110
        vec![
            32,         // 0010000
            32,         // 0010000
            32,         // 0010000
            32,         // 0010000
        ], 
        vec![
            16,         // 0001000
            32+16+8,    // 0011100
            16,         // 0001000
        ],
        vec![
            32+16,      // 0011000
            32+16,      // 0011000
        ],
        vec![
            8,          // 0000100
            8,          // 0000100
            32+16+8,    // 0011100
        ],
    ];


    println!("Move Left {}", (2 << 1)); // = 4
    println!("Move Right {}", (4 >> 1)); // = 2


    return [0, 0]
}
