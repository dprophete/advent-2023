#!/usr/bin/env python

import re

res = 0


def clean_str(s):
    return re.sub(' +', ' ', s.strip())


cards_gained = {}  # card_# -> nb of cards


def nb_cards_gained(line_nb):
    if cards_gained.get(line_nb) is None:
        return 0
    return cards_gained[line_nb]


with open("input.txt") as file:
    for line_nb, line in enumerate(file.readlines()):
        line = clean_str(line.strip())
        [left, right] = line.split("|")
        winning_nbs = set(left.split(":")[1].strip().split(" "))
        my_nbs = set(right.strip().strip().split(" "))
        nb_winning = len(winning_nbs.intersection(my_nbs))

        print(f"line {line_nb} -> {nb_winning}")
        nb_cards_current_line = 1 + nb_cards_gained(line_nb)
        for i in range(line_nb + 1, line_nb + 1 + nb_winning):
            cards_gained[i] = nb_cards_current_line + nb_cards_gained(i)

        res += nb_cards_current_line


print(cards_gained)
print(res)
