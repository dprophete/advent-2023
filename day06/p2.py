#!/usr/bin/env python

import re


time = []
distance = []


def clean_str(s):
    return re.sub(' +', '', s.strip())


def nb_wins_for_race(t, d):
    time_push = 1
    while time_push < t-1:
        time_remaining = t - time_push
        final_distance = time_remaining * time_push
        if (final_distance > d):
            break
        time_push += 1

    first_win = time_push

    time_push = t - 1
    while time_push > 1:
        time_remaining = t - time_push
        final_distance = time_remaining * time_push
        if (final_distance > d):
            break
        time_push -= 1

    last_win = time_push

    return last_win - first_win + 1


# parse file
with open("input.txt") as file:
    for line_nb, line in enumerate(file.readlines()):
        line = clean_str(line.strip())
        if line.startswith("Time:"):
            time = int(line.split(":")[1])
        if line.startswith("Distance:"):
            distance = int(line.split(":")[1])

res = nb_wins_for_race(time, distance)

print(f"times: {time}")
print(f"distances: {distance}")
print(f"result: {res}")
