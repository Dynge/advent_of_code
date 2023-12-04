use std::fs;

pub fn day1() -> Vec<i32> {
    let data = fs::read_to_string("./2022/day1.txt").expect("Couldn't read data :(");

    let mut result: Vec<i32> = vec![];

    // Part 1
    let elves = data.trim_end().split("\n\n");
    let combined_elf_food_list: Vec<Vec<i32>> = elves
        .map(|elf| elf.split("\n")
            .map(|item| item.parse().unwrap())
            .collect())
        .collect();

    let mut elf_sums: Vec<i32> = vec![];
    for elf_store in &combined_elf_food_list {
        elf_sums.push(elf_store.iter().sum())
    }

    result.push(*elf_sums.iter().max().unwrap());

    // Part 2
    elf_sums.sort();
    let top3_sums: i32 = elf_sums[elf_sums.len()-3..].iter().sum();

    result.push(top3_sums);

    return result;
}


