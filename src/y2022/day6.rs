use std::{fs, collections::HashSet};

pub fn day6() -> Vec<i32> {
    let data = fs::read_to_string("./2022/day6/data.txt").expect("Couldn't read data :(");

    let mut result: Vec<i32> = vec![];

    // Part 1
    for index in 4..data.len() {
        let chars: HashSet<_> = data[index-4..index].chars().collect();
        if chars.len() == 4 {
            result.push(index.try_into().unwrap());
            break
        }
    }

    // Part 2
    for index in 14..data.len() {
        let chars: HashSet<_> = data[index-14..index].chars().collect();
        if chars.len() == 14 {
            result.push(index.try_into().unwrap());
            break
        }
    }

    return result
}
