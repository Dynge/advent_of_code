fn main() {
    let a = String::from("hello");
    let b = a;
    println!("Hello, world!");
    println!("{b}");
    other()
}

fn other() {
    let something: [i32; 4] = [1,2,3,4];
    let d = something.map(|x| x.to_string()).join("");
    println!("{d}");
}
