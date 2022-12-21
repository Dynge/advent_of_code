use std::fs;
use std::collections::{HashMap, VecDeque, HashSet};

use regex::Regex;


pub fn day16() -> [u32; 2]{

    let data = fs::read_to_string("./2022/day16.txt").expect("Cannot read file");

    let name_flow_reg = Regex::new(r"^Valve (\w\w) has flow rate=(\d+);.+$").unwrap();
    let connected_to_reg = Regex::new(r"^Valve (\w\w) .+; tunnels? leads? to valves? (.+)$").unwrap();

    let mut node_flows: HashMap<String, u32> = HashMap::new();
    data.trim_end().split("\n")
        .map(|line| name_flow_reg.captures(line).expect("No captures in names"))
        .map(|cap| 
            (
                String::from(cap.get(1).unwrap().as_str()),
                cap.get(2).unwrap().as_str().parse().unwrap()
            )
        )
        .filter(|(_, flow)| flow > &0)
        .for_each(|(node, flow)| {
            node_flows.insert(node, flow);
        });

    let mut node_edges: HashMap<String, Vec<String>> = HashMap::new();
    data.trim_end().split("\n")
        .map(|line| connected_to_reg.captures(line).expect("No captures in connections"))
        .for_each(|cap| {
            node_edges.insert(
                String::from(cap.get(1).unwrap().as_str()),
                cap.get(2).unwrap().as_str().split(", ").map(|s| String::from(s)).collect());
        });


    let mut node_ids: HashMap<String, usize> = HashMap::new();
    for (i, (node, _)) in node_edges.iter().enumerate() {
        node_ids.insert(node.to_string(), i);
    }


    let mut distance_array = init_distance_vectors(&node_ids, &node_edges);
    distance_array = floyd_warshall_algo(&mut distance_array);

    let start_node = String::from("AA");
    let part1_paths = max_pressure(start_node.clone(), 0, 30, &node_ids, &node_flows, &distance_array);
    // println!("{}", part1_paths.len());

    let part2_paths = max_pressure(start_node.clone(), 0, 26, &node_ids, &node_flows, &distance_array);
    let my_path = part2_paths.iter().max_by(|(flow_a, _), (flow_b, _)| flow_a.cmp(flow_b)).unwrap();

    let mut reduced_node_flows = HashMap::new();
    node_flows.clone().iter()
        .filter(|(node, _)| !my_path.1.contains(*node))
        .for_each(|(node, flow)| {
            reduced_node_flows.insert(node.clone(), flow.clone());
        });
    let part2_el_paths = max_pressure(start_node.clone(), 0, 26, &node_ids, &reduced_node_flows, &distance_array);
    let el_path = part2_el_paths.iter().max_by(|(flow_a, _), (flow_b, _)| flow_a.cmp(flow_b)).unwrap();

    return [
        part1_paths.iter().max_by(|(flow_a, _), (flow_b, _)| flow_a.cmp(flow_b)).unwrap().0,
        my_path.0 + el_path.0
    ]
}


fn max_pressure(
    valve: String,
    total_flow: u32,
    mins_left: i32,
    node_ids: &HashMap<String, usize>,
    node_flows_left: &HashMap<String, u32>,
    dist: &Vec<Vec<u32>>,
) -> HashSet<(u32, Vec<String>)> {
    let mut queue = VecDeque::from([(valve, total_flow, mins_left, node_flows_left.clone(), vec![])]);
    let mut routes: HashSet<(u32, Vec<String>)> = HashSet::new();

    while queue.len() > 0 {
        // DFS
        let (current_valve, current_total_flow, current_time_left, unopened_nodes, path) = queue.pop_back().unwrap();
        let current_valve_id = node_ids.get(&current_valve).unwrap();

        for (node, node_flow) in &unopened_nodes {
            let node_id = node_ids.get(node).unwrap();
            let cost: u32 = dist[*current_valve_id][*node_id] + 1;
            let new_time_left = current_time_left - cost as i32;
            if new_time_left <= 0 {
                routes.insert((current_total_flow.clone(), path.clone()));
                continue;
            }
            let new_total_flow = current_total_flow + new_time_left as u32 * node_flow;
            let mut new_unopened_nodes = unopened_nodes.clone();
            new_unopened_nodes.remove(node);
            let mut new_path = path.clone();
            new_path.push(node.to_string());
            queue.push_back((node.clone(), new_total_flow, new_time_left as i32, new_unopened_nodes.clone(), new_path.clone()));
        }
    }
    return routes;
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



fn init_distance_vectors(node_ids: &HashMap<String, usize>, node_edges: &HashMap<String, Vec<String>>) -> Vec<Vec<u32>> {
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
