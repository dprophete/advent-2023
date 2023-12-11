#!/usr/bin/env python

import functools
import math
import re


instructions = ""
nodes = {}  # name -> (left, right)


@functools.cache
def follow_instructions(node):
    for i in instructions:
        if i == "L":
            node = nodes[node][0]
        if i == "R":
            node = nodes[node][1]
    return node


def solve_for_node(node):
    nb_loops = 0
    while node[-1] != 'Z':
        node = follow_instructions(node)
        nb_loops += 1
    print(f"node: {node}, nb_loops: {nb_loops}")
    return nb_loops


def clean_str(s):
    return re.sub(' +', '', s.strip())


# parse file
with open("input.txt") as file:
    for line_nb, line in enumerate(file.readlines()):
        line = clean_str(line.strip())
        if line_nb == 0:
            instructions = line
            continue
        if line_nb >= 2:
            [name, rest] = line.split("=")
            [left, right] = rest[1:-1].split(",")
            nodes[name] = (left, right)


starting_nodes = [node for node in nodes.keys() if node[-1] == "A"]
print(f"starting_nodes: {starting_nodes}")
loops = [solve_for_node(node) for node in starting_nodes]
lcm = math.lcm(*loops)

print(f"result: {lcm * len(instructions)}")
