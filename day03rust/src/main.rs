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
    char: char,
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

    fn is_adjacent_to_any_symbol(&self, symbols: &Vec<Symbol>) -> bool {
        let points = self.points_to_check();
        for (x, y) in points {
            if symbols.iter().any(|s| s.x == x && s.y == y) {
                return true;
            }
        }
        return false;
    }

    fn is_adjacent_to_symbol(&self, symbol: &Symbol) -> bool {
        let points = self.points_to_check();
        for (x, y) in points {
            if symbol.x == x && symbol.y == y {
                return true;
            }
        }
        return false;
    }
}

impl Symbol {
    fn numbers_adjacent_to<'a>(&'a self, numbers: &'a [Number]) -> Vec<&'a Number> {
        numbers
            .iter()
            .filter(|nb| nb.is_adjacent_to_symbol(&self))
            .collect::<Vec<&'a Number>>()
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
                char: mat.as_str().chars().next().unwrap(),
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
        .filter(|nb| nb.is_adjacent_to_any_symbol(&symbols))
        .collect::<Vec<_>>();

    let sum = valid_nbs.iter().map(|nb| nb.nb).sum::<u32>();
    println!("p1 sum: {}", sum);
}

//--------------------------------------------------------------------------------
// p2
//--------------------------------------------------------------------------------

fn p2(input: &str) {
    let file_content = fs::read_to_string(input).expect("cannot read sample file");
    let idx_and_lines = file_content.lines().enumerate();

    let nbs = idx_and_lines
        .clone()
        .flat_map(|(idx, line)| find_numbers(idx as i32, line))
        .collect::<Vec<_>>();

    let gears = idx_and_lines
        .flat_map(|(idx, line)| find_symbols(idx as i32, line))
        .filter(|s| s.char == '*')
        .collect::<Vec<_>>();

    let sum = gears
        .iter()
        .filter_map(|gear| match gear.numbers_adjacent_to(&nbs).as_slice() {
            [a, b] => Some(a.nb * b.nb),
            _ => None,
        })
        .sum::<u32>();
    println!("p2 sum: {}", sum);
}

//--------------------------------------------------------------------------------
// main
//--------------------------------------------------------------------------------

fn main() {
    p1("sample.txt");
    p1("input.txt");
    p2("sample.txt");
    p2("input.txt");
}
