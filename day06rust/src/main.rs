use std::fs;

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

fn first_win(mut time_push: i64, t: i64, d: i64) -> i64 {
    while time_push < t - 1 {
        let time_remaining = t - time_push;
        let final_distance = time_remaining * time_push;
        if final_distance > d {
            return time_push;
        }
        time_push += 1
    }
    return time_push;
}

fn last_win(mut time_push: i64, t: i64, d: i64) -> i64 {
    while time_push > 0 {
        let time_remaining = t - time_push;
        let final_distance = time_remaining * time_push;
        if final_distance > d {
            return time_push;
        }
        time_push -= 1
    }
    return time_push;
}

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

    let t = *(&lines[0]);
    let d = *(&lines[1]);
    // we could do brute force
    // let nb_wins = nb_wins(t, d);
    // println!("p2 res for {}: {}", input, nb_wins);

    // or be smarter
    let first_win_ = first_win(0, t, d);
    let last_win_ = last_win(t - 1, t, d);
    println!("p2 res for {}: {}", input, last_win_ - first_win_ + 1);
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
