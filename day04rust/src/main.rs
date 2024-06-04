use std::{
    collections::{HashMap, HashSet},
    fs,
};

//--------------------------------------------------------------------------------
// p1
//--------------------------------------------------------------------------------

fn p1(input: &str) {
    let mut sum = 0;
    let file_content = fs::read_to_string(input).expect("cannot read sample file");
    for (_idx, line) in file_content.lines().enumerate() {
        let (_, rest) = line.split_once(": ").unwrap();
        let (numbers, winning_numbers) = rest.split_once(" | ").unwrap();

        let numbers = numbers
            .split(" ")
            .filter(|x| x.len() > 0)
            .collect::<HashSet<_>>();

        let winning_numbers = winning_numbers
            .split(" ")
            .filter(|x| x.len() > 0)
            .collect::<HashSet<_>>();

        let nb_winnings = numbers.intersection(&winning_numbers).count() as u32;

        if nb_winnings > 0 {
            sum += 2_i32.pow(nb_winnings - 1);
        }
    }
    println!("p1 sum for {}: {}", input, sum);
}

//--------------------------------------------------------------------------------
// p2
//--------------------------------------------------------------------------------

fn p2(input: &str) {
    let mut sum = 0;
    let mut cards_gained = HashMap::<usize, i32>::new();

    let file_content = fs::read_to_string(input).expect("cannot read sample file");
    for (idx, line) in file_content.lines().enumerate() {
        let (_, rest) = line.split_once(": ").unwrap();
        let (numbers, winning_numbers) = rest.split_once(" | ").unwrap();

        let numbers = numbers
            .split(" ")
            .filter(|x| x.len() > 0)
            .collect::<HashSet<_>>();

        let winning_numbers = winning_numbers
            .split(" ")
            .filter(|x| x.len() > 0)
            .collect::<HashSet<_>>();

        let nb_current_cards = *cards_gained.entry(idx).or_insert(1);

        let nb_winnings = numbers.intersection(&winning_numbers).count();
        if nb_winnings > 0 {
            (idx + 1..idx + 1 + nb_winnings as usize).for_each(|i| {
                cards_gained.insert(i, cards_gained.get(&i).unwrap_or(&1) + nb_current_cards);
            });
        }

        // println!("idx: {}, nb_current_cards: {}", idx + 1, nb_current_cards);
        sum += nb_current_cards;
    }
    println!("p2 sum for {}: {}", input, sum);
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
