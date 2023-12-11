#!/usr/bin/env python

import re

res = 0


def clean_str(s):
    return re.sub(' +', ' ', s.strip())


with open("input.txt") as file:
    for line_nb, line in enumerate(file.readlines()):
        line = clean_str(line.strip())
        [left, right] = line.split("|")
        winning_nbs = set(left.split(":")[1].strip().split(" "))
        my_nbs = set(right.strip().strip().split(" "))
        nb_winning = len(winning_nbs.intersection(my_nbs))
        if nb_winning > 0:
            res += 2**(nb_winning-1)
            print(f"line {line_nb} -> {2**(nb_winning-1)}")

print(res)
