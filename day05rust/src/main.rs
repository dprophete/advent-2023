use std::{cmp, fs};

#[derive(Debug, Copy, Clone)]
struct SeedRange {
    src: i64,
    end: i64,
    mapped: bool,
}

#[derive(Debug)]
struct Range {
    dst: i64,
    src: i64,
    end: i64,
}

impl Range {
    fn maybe_map_seed(&self, seed: i64) -> Option<i64> {
        if seed >= self.src && seed <= self.end {
            return Some(seed - self.src + self.dst);
        }
        return None;
    }

    fn map_seed_range(&self, sr: &SeedRange) -> Vec<SeedRange> {
        if sr.mapped {
            return vec![sr.clone()];
        }
        let mut res = vec![];
        let mut sr_src = sr.src;
        let offset = self.dst - self.src;

        // left part (identity)
        if sr.src < self.src {
            // we have a piece on the left of the range
            if sr.end < self.src {
                // are completely on the left of the range -> add identity and we are done
                res.push(SeedRange {
                    src: sr.src,
                    end: sr.end,
                    mapped: false,
                });
                return res;
            }

            // let's remove slice on the left of src
            res.push(SeedRange {
                src: sr.src,
                end: self.src - 1,
                mapped: false,
            });
            sr_src = self.src;
        }

        // middle part (need to be projected)
        if sr_src <= self.end {
            if sr.end <= self.end {
                // we are completely inside the range
                res.push(SeedRange {
                    src: sr_src + offset,
                    end: sr.end + offset,
                    mapped: true,
                });
                return res;
            }

            res.push(SeedRange {
                src: sr_src + offset,
                end: self.end + offset,
                mapped: true,
            });
            sr_src = self.end + 1;
        }

        // right part (identity)
        res.push(SeedRange {
            src: sr_src,
            end: sr.end,
            mapped: false,
        });
        return res;
    }
}

#[derive(Debug)]
struct Section {
    name: String,
    ranges: Vec<Range>,
}

impl Section {
    fn map_seed(&self, seed: i64) -> i64 {
        for rg in self.ranges.iter() {
            if let Some(dst) = rg.maybe_map_seed(seed) {
                return dst;
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
            ranges.push(Range {
                dst,
                src,
                end: src + len - 1,
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
            src: seed,
            end: seed + len - 1,
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
            let [dst, src, len] = rg[..] else {
                panic!("invalid range")
            };
            ranges.push(Range {
                dst,
                src,
                end: src + len - 1,
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
        res.sort_by_key(|sr| sr.src);
        min = cmp::min(min, res[0].src);
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
