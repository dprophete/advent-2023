#!/usr/bin/env python

from itertools import chain
from enum import Enum


class Step(Enum):
    start = 1
    seed_to_soil = 2
    soil_to_fertilizer = 3
    fertilizer_to_water = 4
    water_to_light = 5
    light_to_temperature = 6
    temperature_to_humidity = 7
    humidity_to_location = 8


def range_for_intersection(intersection):
    dst = intersection["dst"]
    src = intersection["src"]
    end = intersection["end"]
    return {"src": dst, "end": dst + (end - src)}


def intersections_for_range_in_phase(phase, range):
    s1 = range["src"]
    e1 = range["end"]
    # note: the phases are in older
    res = []  # list of [start, end] for each intersection
    for part in phase:
        dst = part["dst"]
        src = part["src"]
        end = part["end"]

        if s1 < src:
            # we have a piece on the left of the range

            if e1 < src:
                # are completely on the left of the range -> add identity and we are done
                res.append({"src": s1, "end": e1, "dst": s1})
                return res

            # let's remove slice on the left of src
            res.append({"src": s1, "end": src - 1, "dst": s1})
            s1 = src

        if s1 <= end:
            # we have a piece intersecting the range

            if e1 <= end:
                # we are completely in the range
                res.append({"src": s1, "end": e1, "dst": dst + (s1-src)})
                return res

            # let's remove the slice in the range
            res.append({"src": s1, "end": end, "dst": dst + (s1-src)})
            s1 = end + 1

    # do we have anything left ?
    res.append({"src": s1, "end": e1, "dst": s1})

    return res


seeds = []
step = Step.start
phases = {x.value: [] for x in Step}

# parse file
with open("input.txt") as file:
    for line_nb, line in enumerate(file.readlines()):
        line = line.strip()
        if line == "":
            continue

        if line.startswith("seeds:"):
            seeds = [int(x) for x in line.split(":")[1].strip().split(" ")]

        elif line.startswith("seed-to-soil"):
            step = Step.seed_to_soil

        elif line.startswith("soil-to-fertilizer"):
            step = Step.soil_to_fertilizer

        elif line.startswith("fertilizer-to-water"):
            step = Step.fertilizer_to_water

        elif line.startswith("water-to-ligh"):
            step = Step.water_to_light

        elif line.startswith("light-to-temperature"):
            step = Step.light_to_temperature

        elif line.startswith("temperature-to-humidity"):
            step = Step.temperature_to_humidity

        elif line.startswith("humidity-to-location"):
            step = Step.humidity_to_location

        else:
            nbs = [int(x) for x in line.split(" ")]
            [dst, src, length] = nbs
            phases[step.value].append(
                {"dst": dst, "src": src, "end": src + length - 1})

# sort ranges based on src
for phase in phases.values():
    phase.sort(key=lambda x: x["src"])

# create initial set of ranges
seed_pairs = [seeds[i:i+2] for i in range(0, len(seeds), 2)]
ranges = [{"src": src, "end": src + length - 1}
          for [src, length] in seed_pairs]

for step in Step:
    if step == Step.start:
        print(f"step {step} -> #ranges: {len(ranges)}")
        continue

    # flatmap...
    lists = [[range_for_intersection(i) for i in intersections_for_range_in_phase(
        phases[step.value], range)] for range in ranges]
    ranges = list(chain(*lists))
    print(f"step {step} -> #ranges: {len(ranges)}")

# we got the final ranges. Let's sort them and print the src of the first one
print(f"final #ranges: {len(ranges)}")
all_srcs = [range["src"] for range in ranges]
all_srcs.sort()

print(all_srcs[0])
