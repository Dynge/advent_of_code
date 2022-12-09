use std::{collections::HashMap, fs};



pub fn day7() -> Vec<u32> {
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

