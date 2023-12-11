#!/usr/bin/env python

import re


res = 0


def clean_str(s):
    return re.sub(' +', ' ', s.strip())


def is_five_of_a_kind(s_hand, m_hand):
    if s_hand[0] == s_hand[1] == s_hand[2] == s_hand[3] == s_hand[4]:
        print(f"is_five_of_a_kind: {s_hand}, was {m_hand}")
        return m_hand + "000000"
    return -1


def is_four_of_a_kind(s_hand, m_hand):
    if (s_hand[0] == s_hand[1] == s_hand[2] == s_hand[3]) or (s_hand[1] == s_hand[2] == s_hand[3] == s_hand[4]):
        print(f"is_four_of_a_kind: {s_hand}, was {m_hand}")
        return "0" + m_hand + "00000"
    return -1


def is_full_house(s_hand, m_hand):
    if ((s_hand[0] == s_hand[1] == s_hand[2]) and (s_hand[3] == s_hand[4])) or ((s_hand[0] == s_hand[1]) and (s_hand[2] == s_hand[3] == s_hand[4])):
        print(f"is_full_house: {s_hand}, was {m_hand}")
        return "00" + m_hand + "0000"
    return -1


def is_three_of_a_kind(s_hand, m_hand):
    if (s_hand[0] == s_hand[1] == s_hand[2]) or (s_hand[1] == s_hand[2] == s_hand[3]) or (s_hand[2] == s_hand[3] == s_hand[4]):
        print(f"is_three_of_a_kind: {s_hand}, was {m_hand}")
        return "000" + m_hand + "000"
    return -1


def is_two_pairs(s_hand, m_hand):
    if (s_hand[0] == s_hand[1]) and ((s_hand[2] == s_hand[3]) or (s_hand[3] == s_hand[4])):
        print(f"is_two_pairs: {s_hand}, was {m_hand}")
        return "0000" + m_hand + "00"
    if (s_hand[1] == s_hand[2]) and (s_hand[3] == s_hand[4]):
        print(f"is_two_pairs: {s_hand}, was {m_hand}")
        return "0000" + m_hand + "00"
    return -1


def is_pair(s_hand, m_hand):
    if (s_hand[0] == s_hand[1]) or (s_hand[1] == s_hand[2]) or (s_hand[2] == s_hand[3]) or (s_hand[3] == s_hand[4]):
        print(f"is_pair: {s_hand}, was {m_hand}")
        return "00000" + m_hand + "0"
    return -1


def val(hand):
    m_hand = remap(hand)
    m_hand2 = "".join(m_hand)
    s_hand = sorted(m_hand)

    v = is_five_of_a_kind(s_hand, m_hand2)
    if v != -1:
        return v
    v = is_four_of_a_kind(s_hand, m_hand2)
    if v != -1:
        return v
    v = is_full_house(s_hand, m_hand2)
    if v != -1:
        return v
    v = is_three_of_a_kind(s_hand, m_hand2)
    if v != -1:
        return v
    v = is_two_pairs(s_hand, m_hand2)
    if v != -1:
        return v
    v = is_pair(s_hand, m_hand2)
    if v != -1:
        return v
    return "000000" + m_hand2


def remap(hand):
    res = []
    for card in hand:
        if card == "A":
            res.append('E')
        elif card == "K":
            res.append('D')
        elif card == "Q":
            res.append('C')
        elif card == "J":
            res.append('B')
        elif card == "T":
            res.append('A')
        else:
            res.append(card)
    return res


hands_data = []  # array of (hand, val, bid)
# parse file
with open("input.txt") as file:
    for line_nb, line in enumerate(file.readlines()):
        line = line.strip()
        [hand, bid] = line.split(" ")
        bid = int(bid)
        hands_data.append((hand, val(hand), bid))

print(f"before hands_data: {hands_data}")
hands_data.sort(key=lambda x: x[1])
print(f"after hands_data: {hands_data}")

for idx, hand_data in enumerate(hands_data):
    res += (idx + 1) * hand_data[2]
print(f"result: {res}")
