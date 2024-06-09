use std::{cmp, fs};

//--------------------------------------------------------------------------------
// p1
//--------------------------------------------------------------------------------

fn str_to_list_of_ints(s: &str) -> Vec<i64> {
    s.split(" ")
        .filter(|x| x.len() > 0)
        .map(|x| x.parse::<i64>().unwrap())
        .collect::<Vec<_>>()
}

fn nb_wins(time: i64, dist: i64) -> i64 {
    (0..time).filter(|t| (time - t) * t > dist).count() as i64
}

fn p1(input: &str) {
    // let mut sum = 0;
    let mut file_content = fs::read_to_string(input).expect("cannot read sample file");
    file_content.pop();

    let lines = file_content
        .split("\n")
        .map(|line| {
            let (_, nbs_str) = line.split_once(":").unwrap();
            str_to_list_of_ints(nbs_str)
        })
        .collect::<Vec<_>>();

    let times = &lines[0];
    let dists = &lines[1];
    let mut res = 1;
    for (race_time, race_dist) in times.iter().zip(dists.iter()) {
        res *= nb_wins(*race_time, *race_dist)
    }
    println!("p1 res for {}: {}", input, res);
}

//--------------------------------------------------------------------------------
// p2
//--------------------------------------------------------------------------------

fn p2(input: &str) {
    // let mut sum = 0;
    let mut file_content = fs::read_to_string(input).expect("cannot read sample file");
    file_content.pop();

    let lines = file_content
        .split("\n")
        .map(|line| {
            let (_, nbs_str) = line.split_once(":").unwrap();
            nbs_str.replace(" ", "").parse::<i64>().unwrap()
        })
        .collect::<Vec<_>>();

    let time = &lines[0];
    let dist = &lines[1];
    let nb_wins = nb_wins(*time, *dist);
    println!("p2 res for {}: {}", input, nb_wins);
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
