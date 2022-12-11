mod y2022;

use y2022::{
    day1,
    day2,
    day6,
    day7,
    day9,
};

fn main() {
    let rs_day1 = day1();
    let rs_day2 = day2();
    let rs_day6 = day6();
    let rs_day7 = day7();
    // let rs_day9 = day9();
    println!("Day 1 Results - {:?}", rs_day1);
    println!("Day 2 Results - {:?}", rs_day2);
    println!("Day 6 Results - {:?}", rs_day6);
    println!("Day 7 Results - {:?}", rs_day7);
    println!("Day 9 Results - {:?}", day9());
}

