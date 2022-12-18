use std::fs;
use std::collections::HashMap;

use regex::Regex;


pub fn day16() -> [u32; 2]{

    let data = fs::read_to_string("./2022/day16.txt").expect("Cannot read file");

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

    let start_node = "AA";
    let part1 = max_pressure(start_node, 0, 30, &node_ids, &node_flows, &distance_array);

    // let part2 = max_pressure_with_elephant(start_node, start_node, 0, 26, &node_ids, &node_flows, &distance_array);

    return [part1, 0]
}

fn max_pressure(
    valve: &str,
    total_flow: u32,
    mins_left: i32,
    node_ids: &HashMap<&str, usize>,
    node_flows_left: &HashMap<&str, u32>,
    dist: &Vec<Vec<u32>>,
) -> u32 {
    let i = node_ids.get(valve).unwrap();

    let result: Vec<_> = node_flows_left.iter()
        .map(|(next_valve, next_flow)| {
            let j = node_ids.get(next_valve).unwrap();
            let cost = dist[*i][*j] + 1;
            let mins_remaining = mins_left - (cost as i32);
            if mins_remaining >= 0 {
                let flow_potential = next_flow * mins_remaining as u32;
                let remaining_node_flows: HashMap<&str, u32> = node_flows_left.iter()
                    .filter(|(node, _)| node != &next_valve)
                    .map(|(node, flow)| (node.clone(), flow.clone())).collect();
                let rest_solution = max_pressure(next_valve, flow_potential, mins_remaining, &node_ids, &remaining_node_flows, dist);
                return rest_solution + total_flow;
            } else {
                return total_flow;
            }
        }).collect();

    return result.iter().max().unwrap_or_else(|| &total_flow).clone();
}


// fn max_pressure_with_elephant(
//     my_valve: &str,
//     el_valve: &str,
//     total_flow: u32,
//     mins_left: i32,
//     node_ids: &HashMap<&str, usize>,
//     node_flows_left: &HashMap<&str, u32>,
//     dist: &Vec<Vec<u32>>,
// ) -> u32 {
//     let my_i = node_ids.get(my_valve).unwrap();
//     let el_i = node_ids.get(el_valve).unwrap();
//
//     for (node1, flow1) in node_flows_left {
//         for (node2, flow2) in node_flows_left {
//             if node1 == node2 {
//                 continue;
//             }
//
//             let my_j = node_ids.get(node1).unwrap();
//             let el_j = node_ids.get(node2).unwrap();
//
//             let my_cost = dist[*my_i][*my_j] + 1;
//             let el_cost = dist[*el_i][*el_j] + 1;
//             let my_mins_remaining = mins_left - (my_cost as i32);
//             let el_mins_remaining = mins_left - (el_cost as i32);
//
//             if my_mins_remaining >= 0 {
//                 let flow_potential = next_flow * mins_remaining as u32;
//                 let remaining_node_flows: HashMap<&str, u32> = node_flows_left.iter()
//                     .filter(|(node, _)| node != &next_valve)
//                     .map(|(node, flow)| (node.clone(), flow.clone())).collect();
//                 node_flows_remains.remove(next_valve.clone());
//                 let rest_solution = max_pressure_with_elephant(next_valve, flow_potential, mins_remaining, &node_ids, &remaining_node_flows, dist);
//                 return rest_solution + total_flow;
//             } else {
//                 node_flows_remains.insert(next_valve.clone(), next_flow.clone());
//                 return 0;
//             }
//             if el_mins_remaining >= 0 {
//
//             }
//
//         }
//     }


//     let mut node_flows_remains = node_flows_left.clone();
//
//     let result_me: Vec<_> = node_flows_left.iter()
//         .map(|(next_valve, next_flow)| {
//             let j = node_ids.get(next_valve).unwrap();
//             let cost = dist[*my_i][*j] + 1;
//             let mins_remaining = mins_left - (cost as i32);
//             if mins_remaining >= 0 {
//                 let flow_potential = next_flow * mins_remaining as u32;
//                 let remaining_node_flows: HashMap<&str, u32> = node_flows_left.iter()
//                     .filter(|(node, _)| node != &next_valve)
//                     .map(|(node, flow)| (node.clone(), flow.clone())).collect();
//                 node_flows_remains.remove(next_valve.clone());
//                 let rest_solution = max_pressure(next_valve, flow_potential, mins_remaining, &node_ids, &remaining_node_flows, dist);
//                 return rest_solution + total_flow;
//             } else {
//                 node_flows_remains.insert(next_valve.clone(), next_flow.clone());
//                 return 0;
//             }
//         }).collect();
//     println!("{:?}", result_me);
//
//     let el_i = node_ids.get(el_valve).unwrap();
//
//     let result_el: Vec<_> = node_flows_remains.iter()
//         .map(|(next_valve, next_flow)| {
//             let j = node_ids.get(next_valve).unwrap();
//             let cost = dist[*el_i][*j] + 1;
//             let mins_remaining = mins_left - (cost as i32);
//             if mins_remaining >= 0 {
//                 let flow_potential = next_flow * mins_remaining as u32;
//                 let remaining_node_flows: HashMap<&str, u32> = node_flows_left.iter()
//                     .filter(|(node, _)| node != &next_valve)
//                     .map(|(node, flow)| (node.clone(), flow.clone())).collect();
//                 let rest_solution = max_pressure(next_valve, flow_potential, mins_remaining, &node_ids, &remaining_node_flows, dist);
//                 return rest_solution + total_flow;
//             } else {
//                 return total_flow;
//             }
//         }).collect();
//     println!("{:?}", result_el);
//
//     return result_me.iter().max().unwrap_or_else(|| &total_flow).clone() + result_el.iter().max().unwrap_or_else(|| &total_flow).clone();
// }


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
