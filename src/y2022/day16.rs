use std::cmp::Ordering::Greater;
use std::cmp::max;
use std::fs;
use std::collections::{HashMap, HashSet};

use regex::Regex;


// #[derive(Debug)]
// struct ValveNode {
//     valve: Valve,
//     leads_to: Vec<String>
// }
//
// #[derive(Debug, Clone)]
// struct Valve {
//     name: String,
//     flow_rate: u8,
// }


pub fn day16() {

    let data = fs::read_to_string("./2022/day16.txt").expect("Cannot read file");

    let reg = Regex::new(r"^Valve (\w\w) has flow rate=(\d+); tunnels? leads? to valves? (.+)$").unwrap();
    let name_flow_reg = Regex::new(r"^Valve (\w\w) has flow rate=(\d+);.+$").unwrap();
    let connected_to_reg = Regex::new(r"^Valve (\w\w) .+; tunnels? leads? to valves? (.+)$").unwrap();

    let mut node_flows: HashMap<&str, u32> = HashMap::new();
    data.trim_end().split("\n")
        .map(|line| name_flow_reg.captures(line).expect("No captures in names"))
        .map(|cap| 
            (
                cap.get(1).unwrap().as_str(),
                cap.get(2).unwrap().as_str().parse().unwrap()
            )
        )
        .filter(|(_, flow)| flow > &0)
        .for_each(|(node, flow)| {
            node_flows.insert(node, flow);
        });

    let mut node_edges: HashMap<&str, Vec<&str>> = HashMap::new();
    data.trim_end().split("\n")
        .map(|line| connected_to_reg.captures(line).expect("No captures in connections"))
        .for_each(|cap| {
            node_edges.insert(
                cap.get(1).unwrap().as_str(), 
                cap.get(2).unwrap().as_str().split(", ").collect());
        });


    let mut node_ids: HashMap<&str, usize> = HashMap::new();
    for (i, (node, _)) in node_edges.iter().enumerate() {
        node_ids.insert(&node, i);
    }


    let mut distance_array = init_distance_vectors(&node_ids, &node_edges);
    distance_array = floyd_warshall_algo(&mut distance_array);
    println!("{:?}", distance_array);

    let visited: HashSet<&str> = HashSet::new();
    let mut current_node = "AA";
    let a = node_ids.get("AA").unwrap();
    let b = node_ids.get("BB").unwrap();
    let c = node_ids.get("CC").unwrap();
    let d = node_ids.get("DD").unwrap();
    let e = node_ids.get("EE").unwrap();
    let f = node_ids.get("FF").unwrap();
    let g = node_ids.get("GG").unwrap();
    let h = node_ids.get("HH").unwrap();
    let i = node_ids.get("II").unwrap();
    let j = node_ids.get("JJ").unwrap();
    println!("{:?}", distance_array[*a][*b]);
    println!("{:?}", distance_array[*a][*c]);
    println!("{:?}", distance_array[*a][*d]);
    println!("{:?}", distance_array[*a][*e]);
    println!("{:?}", distance_array[*a][*f]);
    println!("{:?}", distance_array[*a][*g]);
    println!("{:?}", distance_array[*a][*h]);
    println!("{:?}", distance_array[*a][*i]);
    println!("{:?}", distance_array[*a][*j]);
    println!("HELLO");
    println!("{:?}", distance_array[*j][*a]);
    println!("{:?}", distance_array[*j][*b]);
    println!("{:?}", distance_array[*j][*c]);
    println!("{:?}", distance_array[*j][*d]);
    println!("{:?}", distance_array[*j][*e]);
    println!("{:?}", distance_array[*j][*f]);
    println!("{:?}", distance_array[*j][*g]);
    println!("{:?}", distance_array[*j][*h]);
    println!("{:?}", distance_array[*j][*i]);

    // while remaining_mins > 0 {
    let start_node = "AA";
    let mut max_flow_paths: HashMap<u32, Vec<&str>> = HashMap::new();
    for _ in 0..node_flows.len() {

        let remaining_node_flows = node_flows.clone();
        let mut remaining_mins: i32 = 30;
        current_node = start_node.clone();
        let mut max_flow = 0;
        let mut node_path: Vec<&str> = vec![];
        while remaining_mins > 0 {
            let i = node_ids.get(&current_node).unwrap();

            let mut flow_potentials: Vec<_> = remaining_node_flows.clone().iter()
                .filter(|(&target_node, _)|{
                    let j = node_ids.get(target_node).unwrap();
                    let cost = distance_array[*i][*j] + 1;
                    if (remaining_mins as i32 - cost as i32) < 0 {
                        return false
                    }
                    true
                })
                .map(|(target_node, target_flow)| {
                    let j = node_ids.get(target_node).unwrap();
                    let cost = distance_array[*i][*j] + 1;
                    let flow_potential =  target_flow * (remaining_mins as u32 - cost);
                    (target_node.clone(), flow_potential, cost)
            }).collect();
            flow_potentials.sort_by(|left,right|  right.1.cmp(&left.1));

            let (node, flow_potential, cost) = flow_potentials[0];
            remaining_node_flows.remove(&node);
            current_node = node;
            max_flow += flow_potential;
            remaining_mins -= cost as i32;
            node_path.push(current_node);
            println!("{:?}", current_node);
            println!("{:?}", max_flow);
            println!("{:?}", remaining_mins);
        }
        max_flow_paths.insert(node_flows.get, v)

    }


    println!("{:?}", max_flow);
    let big_fish_id = node_ids.get("FC").unwrap();
    println!("{:?}", distance_array[0][*big_fish_id]);
    // }

}

fn floyd_warshall_algo(dist: &mut Vec<Vec<u32>>) -> Vec<Vec<u32>>{
    for k in 0..dist.len() {
        for i in 0..dist.len() {
            for j in 0..dist.len() {
                if dist[i][j] > dist[i][k] + dist[k][j] {
                    dist[i][j] = dist[i][k] + dist[k][j];
                }
            }
        }
    }
    return dist.to_vec();
}



fn init_distance_vectors(node_ids: &HashMap<&str, usize>, node_edges: &HashMap<&str, Vec<&str>>) -> Vec<Vec<u32>> {
    let mut distance_array = vec![vec![1000u32; node_ids.len()]; node_ids.len()];
    for i in 0..distance_array.len() {
        distance_array[i][i] = 0;
    }
    for (node, edges) in node_edges {
        let node_id: usize = node_ids.get(node).unwrap().clone() as usize;
        for edge in edges {
            let neighbor_id: usize = node_ids.get(edge).unwrap().clone() as usize;
            distance_array[node_id][neighbor_id] = 1;
        }
    }
    return distance_array
}
