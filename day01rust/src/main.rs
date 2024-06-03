use std::fs;

//--------------------------------------------------------------------------------
// p1
//--------------------------------------------------------------------------------

fn process_line(line: &str) -> u32 {
    let numbers: Vec<_> = line.chars().filter_map(|x| x.to_digit(10)).collect();
    numbers.first().unwrap() * 10 + numbers.last().unwrap()
    // let mut first = -1;
    // let mut second = -1;
    // for c in line.chars() {
    //     if let Some(digit) = c.to_digit(10) {
    //         if first == -1 {
    //             first = digit as i32;
    //         }
    //         second = digit as i32;
    //     }
    // }
    // return first * 10 + second;
}

fn p1() {
    let file_content = fs::read_to_string("input.txt").expect("cannot read sample file");
    let mut sum = 0;
    for line in file_content.lines() {
        sum += process_line(line);
    }
    println!("p1 sum: {}", sum);
}

//--------------------------------------------------------------------------------
// p1
//--------------------------------------------------------------------------------

fn p2() {
    let file_content = fs::read_to_string("input.txt").expect("cannot read sample file");
    let mut sum = 0;
    for line in file_content.lines() {
        let line = &line
            .replace("one", "o1e")
            .replace("two", "t2o")
            .replace("three", "t3e")
            .replace("four", "f4r")
            .replace("five", "f5e")
            .replace("six", "s6x")
            .replace("seven", "s7n")
            .replace("eight", "e8t")
            .replace("nine", "n9e");
        sum += process_line(line);
    }
    println!("p2 sum: {}", sum);
}

fn main() {
    p1();
    p2();
}
