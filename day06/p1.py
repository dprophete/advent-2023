#!/usr/bin/env python

import re


res = 1

times = []
distances = []


def clean_str(s):
    return re.sub(' +', ' ', s.strip())


def nb_wins_for_race(t, d):
    nb_solves = 0
    for time_push in range(1, t-1):
        time_remaining = t - time_push
        final_distance = time_remaining * time_push
        if (final_distance > d):
            nb_solves += 1
    return nb_solves


# parse file
with open("input.txt") as file:
    for line_nb, line in enumerate(file.readlines()):
        line = clean_str(line.strip())
        if line.startswith("Time:"):
            times = [int(t) for t in line.split(":")[1].strip().split(" ")]
        if line.startswith("Distance:"):
            distances = [int(d) for d in line.split(":")[1].strip().split(" ")]

for (t, d) in zip(times, distances):
    res *= nb_wins_for_race(t, d)

print(f"times: {times}")
print(f"distances: {distances}")
print(f"result: {res}")
