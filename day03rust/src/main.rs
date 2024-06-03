use std::fs;

use regex::Regex;

//--------------------------------------------------------------------------------
// p1
//--------------------------------------------------------------------------------

#[derive(Debug)]
struct Number {
    nb: u32,
    x_start: i32,
    x_end: i32,
    y: i32,
}

#[derive(Debug)]
struct Symbol {
    _char: char,
    x: i32,
    y: i32,
}

impl Number {
    fn points_to_check(&self) -> Vec<(i32, i32)> {
        let above = (self.x_start - 1..=self.x_end + 1)
            .map(|x| (x, self.y - 1))
            .collect::<Vec<_>>();
        let below = (self.x_start - 1..=self.x_end + 1)
            .map(|x| (x, self.y + 1))
            .collect::<Vec<_>>();
        [
            vec![(self.x_start - 1, self.y), (self.x_end + 1, self.y)],
            above,
            below,
        ]
        .concat()
    }

    fn is_valid(&self, symbols: &Vec<Symbol>) -> bool {
        let points = self.points_to_check();
        for (x, y) in points {
            if symbols.iter().any(|s| s.x == x && s.y == y) {
                return true;
            }
        }
        return false;
    }
}

fn find_numbers(idx: i32, line: &str) -> Vec<Number> {
    let re = Regex::new(r"\b\d+\b").unwrap();
    re.find_iter(line)
        .map(|mat| {
            return Number {
                nb: mat.as_str().parse().unwrap(),
                x_start: mat.start() as i32,
                x_end: mat.end() as i32 - 1,
                y: idx,
            };
        })
        .collect()
}

fn find_symbols(idx: i32, line: &str) -> Vec<Symbol> {
    let re = Regex::new(r"[^0-9.]").unwrap();
    re.find_iter(line)
        .map(|mat| {
            return Symbol {
                _char: mat.as_str().chars().next().unwrap(),
                x: mat.start() as i32,
                y: idx as i32,
            };
        })
        .collect()
}

fn p1(input: &str) {
    let file_content = fs::read_to_string(input).expect("cannot read sample file");
    let idx_and_lines = file_content.lines().enumerate();

    let nbs = idx_and_lines
        .clone()
        .flat_map(|(idx, line)| find_numbers(idx as i32, line))
        .collect::<Vec<_>>();

    let symbols = idx_and_lines
        .flat_map(|(idx, line)| find_symbols(idx as i32, line))
        .collect::<Vec<_>>();

    let valid_nbs = nbs
        .iter()
        .filter(|nb| nb.is_valid(&symbols))
        .collect::<Vec<_>>();

    let sum = valid_nbs.iter().map(|nb| nb.nb).sum::<u32>();
    println!("p1 sum: {}", sum);
}

//--------------------------------------------------------------------------------
// p2
//--------------------------------------------------------------------------------

// fn process_line2(line: &str) -> i32 {
//     let (_, turns) = line.split_once(": ").unwrap();
//     let turns: Vec<_> = turns.split("; ").collect();
//     let (mut blue, mut red, mut green) = (0, 0, 0);
//     for turn in turns {
//         let cubes = turn.split(", ").collect::<Vec<_>>();
//         for cube in cubes {
//             let (amount, color) = cube.split_once(" ").unwrap();
//             let amount: i32 = amount.parse().unwrap();
//             match color {
//                 "blue" => blue = max(blue, amount),
//                 "red" => red = max(red, amount),
//                 "green" => green = max(green, amount),
//                 _ => panic!("unexpected color"),
//             }
//         }
//     }
//     return blue * red * green;
// }
//
// fn p2(input: &str) {
//     let file_content = fs::read_to_string(input).expect("cannot read sample file");
//     // let mut sum = 0;
//     // for (_idx, line) in file_content.lines().enumerate() {
//     //     sum += process_line2(line)
//     // }
//     let sum: i32 = file_content.lines().map(process_line2).sum();
//     println!("p2 sum: {}", sum);
// }

//--------------------------------------------------------------------------------
// main
//--------------------------------------------------------------------------------

fn main() {
    p1("sample.txt");
    p1("input.txt");
    // p2("sample.txt");
    // p2("input.txt");
}
