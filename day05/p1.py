#!/usr/bin/env python

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


def dst_for_val(phase, val):
    for part in phase:
        dst = part["dst"]
        src = part["src"]
        length = part["length"]
        if val < src:
            return val
        if val < src + length:
            return dst + (val-src)
    return val


seeds = []
step = Step.start
phases = {x.value: [] for x in Step}
res = -1


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
                {"dst": dst, "src": src, "length": length})
            # print(f"for step {step} -> {nbs}")

# sort ranges based on src
for phase in phases.values():
    phase.sort(key=lambda x: x["src"])

for seed in seeds:
    v = seed
    for step in Step:
        if step == Step.start:
            continue
        v = dst_for_val(phases[step.value], v)
    print(f"seed {seed} -> {v}")
    if res == -1 or v < res:
        res = v

print(f"result: {res}")
