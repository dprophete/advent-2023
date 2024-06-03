use std::{cmp::max, fs};

//--------------------------------------------------------------------------------
// p1
//--------------------------------------------------------------------------------

fn process_line(line: &str) -> bool {
    let (_, turns) = line.split_once(": ").unwrap();
    let turns: Vec<_> = turns.split("; ").collect();
    for turn in turns {
        let cubes = turn.split(", ").collect::<Vec<_>>();
        for cube in cubes {
            let (mut blue, mut red, mut green) = (0, 0, 0);
            let (amount, color) = cube.split_once(" ").unwrap();
            let amount: i32 = amount.parse().unwrap();
            match color {
                "blue" => blue = amount,
                "red" => red = amount,
                "green" => green = amount,
                _ => panic!("unexpected color"),
            }
            if red > 12 || green > 13 || blue > 14 {
                return false;
            }
        }
    }
    return true;
}

fn p1(input: &str) {
    let file_content = fs::read_to_string(input).expect("cannot read sample file");
    let mut sum = 0;
    for (idx, line) in file_content.lines().enumerate() {
        if process_line(line) {
            sum += idx + 1;
        }
    }
    println!("p1 sum: {}", sum);
}

//--------------------------------------------------------------------------------
// p2
//--------------------------------------------------------------------------------

fn process_line2(line: &str) -> i32 {
    let (_, turns) = line.split_once(": ").unwrap();
    let turns: Vec<_> = turns.split("; ").collect();
    let (mut blue, mut red, mut green) = (0, 0, 0);
    for turn in turns {
        let cubes = turn.split(", ").collect::<Vec<_>>();
        for cube in cubes {
            let (amount, color) = cube.split_once(" ").unwrap();
            let amount: i32 = amount.parse().unwrap();
            match color {
                "blue" => blue = max(blue, amount),
                "red" => red = max(red, amount),
                "green" => green = max(green, amount),
                _ => panic!("unexpected color"),
            }
        }
    }
    return blue * red * green;
}

fn p2(input: &str) {
    let file_content = fs::read_to_string(input).expect("cannot read sample file");
    // let mut sum = 0;
    // for (_idx, line) in file_content.lines().enumerate() {
    //     sum += process_line2(line)
    // }
    let sum: i32 = file_content.lines().map(process_line2).sum();
    println!("p2 sum: {}", sum);
}

//--------------------------------------------------------------------------------
// main
//--------------------------------------------------------------------------------

fn main() {
    p1("input.txt");
    p2("input.txt");
}
