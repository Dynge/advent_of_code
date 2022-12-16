use std::fs;
use std::collections::HashMap;

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

    let name_flow_reg = Regex::new(r"^Valve (\w\w) has flow rate=(\d+);.+$").unwrap();
    let connected_to_reg = Regex::new(r"^Valve (\w\w) .+; tunnels? leads? to valves? (.+)$").unwrap();

    let mut valve_nodes_hash: HashMap<&str, u8> = HashMap::new();
    data.trim_end().split("\n")
        .map(|line| name_flow_reg.captures(line).expect("No captures in names"))
        .for_each(|cap| {
            println!("{:?}", cap.get(1).unwrap().as_str());
            println!("{:?}", cap.get(2).unwrap().as_str());
            valve_nodes_hash.insert(
                cap.get(1).unwrap().as_str(), cap.get(2).unwrap().as_str().parse().unwrap()
                );
        });
    let mut valve_connections_hash: HashMap<&str, Vec<&str>> = HashMap::new();
    data.trim_end().split("\n")
        .map(|line| connected_to_reg.captures(line).expect("No captures in connections"))
        .for_each(|cap| {
            println!("{:?}", cap.get(1).unwrap().as_str());
            println!("{:?}", cap.get(2).unwrap().as_str());
            valve_connections_hash.insert(
                cap.get(1).unwrap().as_str(), 
                cap.get(2).unwrap().as_str().split(", ").collect());
        });

    let mut dist: HashMap<&str, HashMap<&str, u32>> = HashMap::new();
    for (valve, connections) in &valve_connections_hash {
        dist.insert(valve, HashMap::new());
        for (valve2, _) in &valve_connections_hash {
            if valve == valve2 {
                continue;
            }
            if connections.contains(&valve2) {
                dist.get_mut(valve).unwrap().insert(valve2.clone(), 1);
            } else {
                dist.get_mut(valve).unwrap().insert(valve2.clone(), 100_000);
            }
        }
    }
    println!("{:?}", dist)
}
