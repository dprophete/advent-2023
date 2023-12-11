#!/usr/bin/env python

import re


def clean_str(s):
    return re.sub(' +', ' ', s.strip())


def compute_next_row(row):
    return [row[i+1] - row[i] for i in range(len(row) - 1)]


def is_final_row(row):
    return len(row) == 1 or all(x == 0 for x in row)


def process_history(history):
    row = history
    rows = [row]
    while (not is_final_row(row)):
        row = compute_next_row(row)
        rows.append(row)

    rows.reverse()
    rows[0].append(0)
    for i in range(1, len(rows)):
        rows[i].insert(0, rows[i][0] - rows[i-1][0])
    return rows[-1][0]


res = 0
with open("input.txt") as file:
    for line_nb, line in enumerate(file.readlines()):
        line = clean_str(line.strip())
        history = [int(x) for x in line.split(" ")]
        res += process_history(history)


print(f"result: {res}")
