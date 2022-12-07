use std::{fs, vec};
use std::collections::{HashSet, HashMap};
use std::iter::Iterator;

fn main() {
    let rs_day1 = day1();
    let rs_day6 = day6();
    println!("Day 1 Results - {:?}", rs_day1);
    println!("Day 6 Results - {:?}", rs_day6);
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

fn day7() -> Vec<i32> {
    let data = fs::read_to_string("./2022/day7/data.txt").expect("Couldn't read data :(");

    #[derive(Debug)]
    struct FileItem {
        name: String,
        size: i32,
        subdirs: Option<Box<Vec<FileItem>>>,
        parent: Option<Box<FileItem>>
    }

    let mut file_system = FileItem{
        name: String::from("/"),
        size: 0,
        subdirs: None,
        parent: None
    };


    let current_file_item: FileItem = &mut file_system;
    for line in data.split("\n") {
        if line.starts_with("$ cd") {
            if line.matches(r"\w+"). == String::from("/") {

            }
        }

    }
    unimplemented!();
}
