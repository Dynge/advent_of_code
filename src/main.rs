use std::{fs, vec};
use std::collections::{HashSet, HashMap};
use std::iter::Iterator;

fn main() {
    let rs_day1 = day1();
    let rs_day6 = day6();
    let rs_day7 = day7();
    println!("Day 1 Results - {:?}", rs_day1);
    println!("Day 6 Results - {:?}", rs_day6);
    println!("Day 7 Results - {:?}", rs_day7);
}

fn day1() -> Vec<i32> {
    let data = fs::read_to_string("./2022/day1/data.txt").expect("Couldn't read data :(");

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

fn day6() -> Vec<i32> {
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

fn day7() -> Vec<u32> {
    let data = fs::read_to_string("./2022/day7/data.txt").expect("Couldn't read data :(");

    let mut result: Vec<u32> = vec![];

    // Part 1
    let mut directory_sizes: HashMap<String, u32> = HashMap::new();
    let mut current_dirs: Vec<&str> = vec![];
    for line in data.split("\n") {
        let sub_parts: Vec<&str> = line.split(" ").collect();
        if sub_parts[0] == "$" {
            if sub_parts[1] == "cd" {
                if sub_parts[2] == ".." {
                    current_dirs.pop();
                } else {
                    current_dirs.push(sub_parts[2]);
                }
            } 
        } else if sub_parts[0].parse::<u32>().unwrap_or(0) == 0 {
            continue
        } else {
            let file_size: u32 = sub_parts[0].parse::<u32>().expect("Should be handled by above elif.");
            for i in 1..current_dirs.len()+1 {
                let path = current_dirs[0..i].join("/");
                let size_of_dir = directory_sizes.get_mut(&path);

                match size_of_dir {
                    Some(value) => *value += file_size,
                    None => {
                        directory_sizes.insert(path, file_size);
                    },
                }
            }

        }
    }

    let sum_file_sizes: u32 = directory_sizes.values()
        .filter(|&value| value <= &100000)
        .map(|value| value.to_owned())
        .sum();

    result.push(sum_file_sizes);

    // Part 2
    let total_space: u32 = 70000000;
    let unused_space = total_space - directory_sizes.get("/").expect("What an error!");
    let space_to_delete = 30000000 - unused_space;

    let smallest_directory: u32 = directory_sizes.values()
        .filter(|&value| value >= &space_to_delete)
        .map(|value| value.to_owned())
        .min().expect("No min value.");

    result.push(smallest_directory);

    return result
}

