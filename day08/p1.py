#!/usr/bin/env python

import re


def clean_str(s):
    return re.sub(' +', '', s.strip())


hands_data = []  # array of (hand, val, bid)
instructions = ""
nodes = {}  # name -> (left, right)


def follow_instructions(node):
    for i in instructions:
        if i == "L":
            node = nodes[node][0]
        if i == "R":
            node = nodes[node][1]
    return node


# parse file
with open("input.txt") as file:
    for line_nb, line in enumerate(file.readlines()):
        line = clean_str(line.strip())
        if line_nb == 0:
            instructions = line
            continue
        if line_nb < 2:
            continue
        [name, rest] = line.split("=")
        [left, right] = rest[1:-1].split(",")
        nodes[name] = (left, right)


#  print(f"instructions: {instructions}")
#  print(f"nodes: {nodes}")

res = 0
dst = 'AAA'
while dst != 'ZZZ':
    dst = follow_instructions(dst)
    res += len(instructions)

print(f"result: {res}")
