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


def is_acceptable_set(set):
    for color, max in maxes.items():
        if set[color] > max:
            return False
    return True


with open("sample.txt") as file:
    for line_nb, line in enumerate(file.readlines()):
        game_nb = line_nb + 1
        line = line.strip()
        [_, rest] = line.split(":")
        sets = [parse_set(set.strip()) for set in rest.split(";")]
        has_impossible_sets = [
            set for set in sets if not is_acceptable_set(set)]
        if (len(has_impossible_sets) == 0):
            res += game_nb
        else:
            print(f"{game_nb}: impossible sets")

print(res)
