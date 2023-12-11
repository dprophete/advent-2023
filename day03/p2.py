#!/usr/bin/env python

import re

all_numbers = []
all_gears = set()


def positions_of_number(nb_info):
    x_start = nb_info["x_start"]
    x_end = nb_info["x_end"]
    y = nb_info["y"]
    return [(x, y-1) for x in range(x_start-1, x_end+2)] + [(x, y+1) for x in range(x_start-1, x_end+2)] + [(x_start-1, y), (x_end+1, y)]


def is_number_next_to_gear(nb_info, symbol):
    return symbol in positions_of_number(nb_info)


def detect_symbol(line_nb, line):
    nb = 0
    nb_start = 0

    for idx, c in enumerate("." + line + "."):
        if c in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]:
            if nb == 0:
                nb_start = idx
            nb = nb*10 + int(c)
        else:
            if nb > 0:
                all_numbers.append(
                    {"nb": nb, "x_start": nb_start, "x_end": idx-1, "y": line_nb})
                nb = 0

            if c == "*":
                all_gears.add((idx, line_nb))


res = 0

with open("input.txt") as file:
    for line_nb, line in enumerate(file.readlines()):
        line = line.strip()
        detect_symbol(line_nb + 1, line)

print(f"nb gears: {len(all_gears)}")
for gear in all_gears:
    # find all the numbers next to a gear
    nbs_next_to_gear = [nb_info["nb"]
                        for nb_info in all_numbers if is_number_next_to_gear(nb_info, gear)]
    if len(nbs_next_to_gear) == 2:
        [nb1, nb2] = nbs_next_to_gear
        res += nb1*nb2

print(res)
