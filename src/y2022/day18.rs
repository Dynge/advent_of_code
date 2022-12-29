use std::{fs, collections::{HashSet, VecDeque}};


pub fn day18() -> [u32; 2] {
    let data = fs::read_to_string("./2022/day18.txt").expect("Cannot read file");

    let bricks = data.trim_end().split("\n")
        .map(|line| {
            let mut line_iter = line.split(",")
                .map(|coor| 
                    coor.parse::<i16>().unwrap()
                ).into_iter();

            [
                line_iter.next().unwrap(),
                line_iter.next().unwrap(),
                line_iter.next().unwrap()
            ]
        }).collect::<HashSet<_>>();


    let start_position: [i16; 3] = [0; 3];
    let mut visited = HashSet::<[i16; 3]>::from([start_position.clone()]);
    let mut queue = VecDeque::<[i16; 3]>::from([start_position.clone()]);

    let mut all_exposed_walls = 0u32;
    let mut exposed_walls_exterior = 0u32;


    while queue.len() > 0 {
        // BFS
        let cur_coordinate = queue.pop_front().unwrap();
        // println!("queuelen {:?}", queue.len());
        let (hit_bricks, neighbors) = find_all_neighbors(&cur_coordinate, &visited, &bricks);

        // println!("neighbor len {:?}", neighbors);
        all_exposed_walls += hit_bricks;

        neighbors
            .iter()
            .for_each(|neighbor|  {
                queue.push_back(neighbor.clone());
                visited.insert(neighbor.clone());
            });
    }

    let mut visited = HashSet::<[i16; 3]>::from([start_position.clone()]);
    let mut queue = VecDeque::<[i16; 3]>::from([start_position.clone()]);


    while queue.len() > 0 {
        // BFS
        let cur_coordinate = queue.pop_front().unwrap();
        // println!("queuelen {:?}", queue.len());
        let (hit_bricks, neighbors) = find_neighbors_exterior(&cur_coordinate, &visited, &bricks);

        // println!("neighbor len {:?}", neighbors);
        exposed_walls_exterior += hit_bricks;

        neighbors
            .iter()
            .for_each(|neighbor|  {
                queue.push_back(neighbor.clone());
                visited.insert(neighbor.clone());
            });
    }


    return [all_exposed_walls, exposed_walls_exterior];
}

fn find_all_neighbors(
    coordinate: &[i16; 3],
    visited: &HashSet<[i16; 3]>,
    bricks: &HashSet<[i16; 3]>,
) -> (u32, Vec<[i16; 3]>) {
    let mut valid_neighbors = vec![];
    let mut hit_bricks = 0u32;
    let neighbor_positions: Vec<[i16; 3]> = vec![
        [-1, 0, 0],
        [ 1, 0, 0],
        [0, -1, 0],
        [0,  1, 0],
        [0, 0, -1],
        [0, 0,  1],
    ].iter()
        .map(|neighbor_rel| {
            [
                neighbor_rel[0] + coordinate[0],
                neighbor_rel[1] + coordinate[1],
                neighbor_rel[2] + coordinate[2]
            ]
        })
        .filter(|neighbor_abs| neighbor_abs.iter().any(|coor| coor < &-5 || coor > &25) == false)
        .collect();

    for neighbor in neighbor_positions.iter() {
        if bricks.contains(neighbor) && !bricks.contains(coordinate) {
            hit_bricks += 1;
        }
        if visited.contains(neighbor) {
            continue;
        }
        valid_neighbors.push(neighbor.clone());
    }

    
    return (hit_bricks, valid_neighbors);

}


fn find_neighbors_exterior(
    coordinate: &[i16; 3],
    visited: &HashSet<[i16; 3]>,
    bricks: &HashSet<[i16; 3]>,
) -> (u32, Vec<[i16; 3]>) {
    let mut valid_neighbors = vec![];
    let mut hit_bricks = 0u32;
    let neighbor_positions: Vec<[i16; 3]> = vec![
        [-1, 0, 0],
        [ 1, 0, 0],
        [0, -1, 0],
        [0,  1, 0],
        [0, 0, -1],
        [0, 0,  1],
    ].iter()
        .map(|neighbor_rel| {
            [
                neighbor_rel[0] + coordinate[0],
                neighbor_rel[1] + coordinate[1],
                neighbor_rel[2] + coordinate[2]
            ]
        })
        .filter(|neighbor_abs| neighbor_abs.iter().any(|coor| coor < &-5 || coor > &25) == false)
        .collect();

    for neighbor in neighbor_positions.iter() {
        if bricks.contains(neighbor) {
            hit_bricks += 1;
            continue;
        }
        if visited.contains(neighbor) {
            continue;
        }
        valid_neighbors.push(neighbor.clone());
    }

    
    return (hit_bricks, valid_neighbors);

}
