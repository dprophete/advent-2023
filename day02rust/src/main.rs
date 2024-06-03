use std::{cmp::max, fs};

//--------------------------------------------------------------------------------
// p1
//--------------------------------------------------------------------------------

fn process_line(line: &str) -> bool {
    let (_, parts) = line.split_once(": ").unwrap();
    let reaches: Vec<_> = parts.split("; ").collect();
    for reach in reaches {
        let cubes: Vec<_> = reach.split(", ").collect();
        for cube in cubes {
            let (mut blue, mut red, mut green) = (0, 0, 0);
            let cube_parts: Vec<_> = cube.split(" ").collect();
            let num = cube_parts[0].parse().unwrap();
            match cube_parts[1] {
                "blue" => blue = num,
                "red" => red = num,
                "green" => green = num,
                _ => (),
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
    let (_, parts) = line.split_once(": ").unwrap();
    let reaches: Vec<_> = parts.split("; ").collect();
    let (mut blue, mut red, mut green) = (0, 0, 0);
    for reach in reaches {
        let cubes: Vec<_> = reach.split(", ").collect();
        for cube in cubes {
            let cube_parts: Vec<_> = cube.split(" ").collect();
            let num = cube_parts[0].parse().unwrap();
            match cube_parts[1] {
                "blue" => blue = max(blue, num),
                "red" => red = max(red, num),
                "green" => green = max(green, num),
                _ => (),
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
