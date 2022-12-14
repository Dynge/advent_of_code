use std::fs;
use std::cmp::Ordering::*;

use serde_derive::Deserialize;

#[derive(PartialOrd, PartialEq, Debug, Deserialize, Clone, Eq, Ord)]
#[serde(untagged)]
enum SignalValue {
    List(Vec<SignalValue>),
    Number(u8),
}

pub fn day13() -> [i32; 2] {
    let data = fs::read_to_string("./2022/day13/data.txt").expect("Couldn't read data :(");

    let groups: Vec<_> = data.split("\n\n").collect();


    let mut uncorrupted_indices: Vec<i32> = vec![];
    for (i, group) in groups.iter().enumerate() {
        let (left, right) = group.split_once("\n").unwrap();
        let json1: SignalValue = serde_json::from_str(&left).unwrap();
        let json2: SignalValue = serde_json::from_str(&right).unwrap();
        
        if compare_signals(&json1, &json2) == Some(true) {
            uncorrupted_indices.push((i+1).try_into().unwrap());
        }
    };

    let part1: i32 = uncorrupted_indices.iter().sum();

    let dividiers = [
        serde_json::from_str("[[2]]").unwrap(),
        serde_json::from_str("[[6]]").unwrap()
    ];

    let mut lines: Vec<SignalValue> = data.split("\n")
        .filter(|line| line != &"")
        .map(|line| serde_json::from_str(&line).unwrap())
        .collect();
    lines.extend(dividiers.clone());

    lines.sort_by(|left, right| match compare_signals(left, right) {
        Some(true) => Less,
        None => Equal,
        Some(false) => Greater,
    });

    let div_two_index: i32 = lines.iter().position(|item| dividiers[0].eq(item)).unwrap().try_into().unwrap();
    let div_six_index: i32 = lines.iter().position(|item| dividiers[1].eq(item)).unwrap().try_into().unwrap();

    let part2 = (div_two_index + 1) * (div_six_index + 1);

    return [ part1, part2 ]
}



fn compare_signals(left: &SignalValue, right: &SignalValue) -> Option<bool> {
    match (left, right) {
        (SignalValue::Number(l), SignalValue::Number(r)) => {
            match l.cmp(r) {
                Less => return Some(true),
                Equal => return None,
                Greater => return Some(false),
            };
        },
        (SignalValue::List(l), SignalValue::List(r)) => {
            if l.len() == 0 && r.len() > 0 {
                return Some(true);
            }
            if r.len() == 0 && l.len() > 0 {
                return Some(false);
            }


            let min_length = l.len().min(r.len());
            let list_result = (0..min_length)
                .fold( None, |accumulated, next| accumulated.or(compare_signals(&l[next], &r[next])));

            return list_result.or_else(|| match &l.len().cmp(&r.len()) {
                    Less => return Some(true),
                    Equal => return None,
                    Greater => return Some(false),
                }
            );

        },
        (value @ SignalValue::Number(_), list @ SignalValue::List(_)) => return compare_signals(&SignalValue::List(vec![value.clone()]), &list),
        (list @ SignalValue::List(_), value @ SignalValue::Number(_)) => return compare_signals(&list, &SignalValue::List(vec![value.clone()])),
    };
}
