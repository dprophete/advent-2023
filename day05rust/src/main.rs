use std::{cmp, fs, ops::RangeInclusive};

#[derive(Debug, Clone)]
struct SeedRange {
    rg: RangeInclusive<i64>,
    mapped: bool,
}

#[derive(Debug)]
struct XRange {
    rg: RangeInclusive<i64>,
    delta: i64,
}

impl XRange {
    fn map_seed_range(&self, sr: &SeedRange) -> Vec<SeedRange> {
        if sr.mapped {
            return vec![sr.clone()];
        }
        let mut res = vec![];
        let mut sr_src = *sr.rg.start();
        let sr_end = *sr.rg.end();
        let self_src = *self.rg.start();
        let self_end = *self.rg.end();

        // left part (identity)
        if sr_src < self_src {
            // we have a piece on the left of the range
            if sr_end < self_src {
                // are completely on the left of the range -> add identity and we are done
                res.push(SeedRange {
                    rg: sr_src..=sr_end,
                    mapped: false,
                });
                return res;
            }

            // let's remove slice on the left of src
            res.push(SeedRange {
                rg: sr_src..=(self_src - 1),
                mapped: false,
            });
            sr_src = *self.rg.start();
        }

        // middle part (need to be projected)
        if sr_src <= self_end {
            if sr_end <= self_end {
                // we are completely inside the range
                res.push(SeedRange {
                    rg: sr_src + self.delta..=sr_end + self.delta,
                    mapped: true,
                });
                return res;
            }

            res.push(SeedRange {
                rg: sr_src + self.delta..=self_end + self.delta,
                mapped: true,
            });
            sr_src = self_end + 1;
        }

        // right part (identity)
        res.push(SeedRange {
            rg: sr_src..=sr_end,
            mapped: false,
        });
        return res;
    }
}

#[derive(Debug)]
struct Section {
    name: String,
    ranges: Vec<XRange>,
}

impl Section {
    fn map_seed(&self, seed: i64) -> i64 {
        for xrg in self.ranges.iter() {
            if xrg.rg.contains(&seed) {
                return seed + xrg.delta;
            }
        }
        return seed;
    }

    fn map_seed_range(&self, sr: &SeedRange) -> Vec<SeedRange> {
        let mut sr = sr.clone();
        sr.mapped = false;
        let mut res = vec![sr];
        for range in self.ranges.iter() {
            res = res.iter().flat_map(|sr| range.map_seed_range(sr)).collect()
        }
        return res;
    }
}

//--------------------------------------------------------------------------------
// p1
//--------------------------------------------------------------------------------

fn map_seed(mut seed: i64, sections: &Vec<Section>) -> i64 {
    for section in sections.iter() {
        seed = section.map_seed(seed);
    }
    return seed;
}

fn str_to_list_of_ints(s: &str) -> Vec<i64> {
    s.split(" ")
        .map(|x| x.parse::<i64>().unwrap())
        .collect::<Vec<_>>()
}

fn p1(input: &str) {
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
            let [dst, src, len] = rg[..].try_into().unwrap();
            ranges.push(XRange {
                rg: src..=src + len - 1,
                delta: dst - src,
            })
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

fn map_seed_range(sr: &SeedRange, sections: &Vec<Section>) -> Vec<SeedRange> {
    let mut res = vec![sr.clone()];
    for section in sections.iter() {
        res = res
            .iter()
            .flat_map(|sr| section.map_seed_range(sr))
            .collect();
    }

    return res;
}

fn p2(input: &str) {
    // let mut sum = 0;
    let mut file_content = fs::read_to_string(input).expect("cannot read sample file");
    file_content.pop();

    let parts = file_content.split("\n\n").collect::<Vec<_>>();
    let (seeds_str, sections_str) = parts.split_first().unwrap();

    let (_, seeds_str) = seeds_str.split_once(": ").unwrap();
    let base_seeds = str_to_list_of_ints(seeds_str);

    let mut seeds = vec![];
    for chunk in base_seeds.chunks(2) {
        let [seed, len] = chunk[..] else {
            panic!("invalid chunk")
        };
        seeds.push(SeedRange {
            rg: seed..=seed + len - 1,
            mapped: false,
        });
    }

    let mut sections = vec![];
    for section in sections_str {
        let lines = section.split("\n").collect::<Vec<_>>();
        let (name, ranges_str) = lines.split_first().unwrap();

        let mut ranges = vec![];
        for range_str in ranges_str {
            let rg = str_to_list_of_ints(range_str);
            let [dst, src, len] = rg[..].try_into().unwrap();
            ranges.push(XRange {
                rg: src..=src + len - 1,
                delta: dst - src,
            })
        }

        sections.push(Section {
            name: name.to_string(),
            ranges,
        })
    }

    let mut min = i64::MAX;
    for sr in seeds.iter() {
        let mut res = map_seed_range(sr, &sections);
        res.sort_by_key(|sr| *sr.rg.start());
        min = cmp::min(min, *res[0].rg.start());
    }

    println!("p2 min for {}: {}", input, min);
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
