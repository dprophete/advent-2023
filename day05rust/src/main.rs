use std::{cmp, fs};

#[derive(Debug)]
struct Range {
    dst: i64,
    src: i64,
    len: i64,
}

impl Range {
    fn maybe_map(&self, x: i64) -> Option<i64> {
        if x >= self.src && x < self.src + self.len {
            return Some(x - self.src + self.dst);
        }
        return None;
    }
}

#[derive(Debug)]
struct Section {
    name: String,
    ranges: Vec<Range>,
}

impl Section {
    fn map(&self, x: i64) -> i64 {
        for rg in self.ranges.iter() {
            if let Some(y) = rg.maybe_map(x) {
                return y;
            }
        }
        return x;
    }
}

//--------------------------------------------------------------------------------
// p1
//--------------------------------------------------------------------------------

fn map_seed(mut seed: i64, sections: &Vec<Section>) -> i64 {
    for section in sections.iter() {
        seed = section.map(seed);
    }
    return seed;
}

fn str_to_list_of_ints(s: &str) -> Vec<i64> {
    s.split(" ")
        .map(|x| x.parse::<i64>().unwrap())
        .collect::<Vec<_>>()
}

fn p1(input: &str) {
    // let mut sum = 0;
    let mut file_content = fs::read_to_string(input).expect("cannot read sample file");
    file_content.pop();

    let parts = file_content.split("\n\n").collect::<Vec<_>>();
    let (seeds_str, sections_str) = parts.split_first().unwrap();

    let (_, seeds_str) = seeds_str.split_once(": ").unwrap();
    let seeds = str_to_list_of_ints(seeds_str);

    let mut sections = vec![];
    for section in sections_str {
        let lines = section.split("\n").collect::<Vec<_>>();
        let (name, ranges_str) = lines.split_first().unwrap();

        let mut ranges = vec![];
        for range_str in ranges_str {
            let rg = str_to_list_of_ints(range_str);
            let [dst, src, len] = rg[..] else {
                panic!("invalid range")
            };
            ranges.push(Range { dst, src, len })
        }

        sections.push(Section {
            name: name.to_string(),
            ranges,
        })
    }

    let mut min = i64::MAX;
    for seed in seeds.iter() {
        min = cmp::min(min, map_seed(*seed, &sections));
    }
    println!("p1 min for {}: {}", input, min);
}

//--------------------------------------------------------------------------------
// p2
//--------------------------------------------------------------------------------

// fn p2(input: &str) {
//     let mut sum = 0;
//     let mut cards_gained = HashMap::<usize, i64>::new();
//
//     let file_content = fs::read_to_string(input).expect("cannot read sample file");
//     for (idx, line) in file_content.lines().enumerate() {
//         let (_, rest) = line.split_once(": ").unwrap();
//         let (numbers, winning_numbers) = rest.split_once(" | ").unwrap();
//
//         let numbers = numbers
//             .split(" ")
//             .filter(|x| x.len() > 0)
//             .collect::<HashSet<_>>();
//
//         let winning_numbers = winning_numbers
//             .split(" ")
//             .filter(|x| x.len() > 0)
//             .collect::<HashSet<_>>();
//
//         let nb_current_cards = *cards_gained.entry(idx).or_insert(1);
//
//         let nb_winnings = numbers.intersection(&winning_numbers).count();
//         if nb_winnings > 0 {
//             (idx + 1..idx + 1 + nb_winnings as usize).for_each(|i| {
//                 cards_gained.insert(i, cards_gained.get(&i).unwrap_or(&1) + nb_current_cards);
//             });
//         }
//
//         // println!("idx: {}, nb_current_cards: {}", idx + 1, nb_current_cards);
//         sum += nb_current_cards;
//     }
//     println!("p2 sum for {}: {}", input, sum);
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
