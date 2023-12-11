#!/usr/bin/env python

res = 0

maxes = {
    "red": 12,
    "green": 13,
    "blue": 14
}


def parse_set(set):
    cubes = set.split(", ")
    res = {"red": 0, "green": 0, "blue": 0}
    for cube in cubes:
        [number, color] = cube.split(" ")
        number = int(number)
        res[color] = number
    return res


def max_colors(sets):
    max = {"red": 0, "green": 0, "blue": 0}
    for set in sets:
        for color, number in set.items():
            if (number > max[color]):
                max[color] = number
    return max


with open("input.txt") as file:
    for line_nb, line in enumerate(file.readlines()):
        game_nb = line_nb + 1
        line = line.strip()
        [_, rest] = line.split(":")
        sets = [parse_set(set.strip()) for set in rest.split(";")]
        maxes = max_colors(sets)
        res += maxes["blue"] * maxes["green"] * maxes["red"]
        print(f"{game_nb}: {maxes}")

print(res)
