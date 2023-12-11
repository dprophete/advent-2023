#!/usr/bin/env python

import re


res = 0


def clean_str(s):
    return re.sub(' +', ' ', s.strip())


def without_1(h):
    return [h[0], h[1], h[2], h[3], "a"]


def without_2(h):
    return [h[0], h[1], h[2], "a", "b"]


def without_3(h):
    return [h[0], h[1], "a", "b", "c"]


def without_4(h):
    return [h[0], "a", "b", "c", "d"]


def is_five_of_a_kind(s_hand):
    [s0, s1, s2, s3, s4] = s_hand
    if _is_five_of_a_kind(s_hand):
        return True
    if s4 == "0" and _is_four_of_a_kind(without_1(s_hand)):
        return True
    if (s3 + s4 == "00") and _is_three_of_a_kind(without_2(s_hand)):
        return True
    if (s2 + s3 + s4 == "000") and _is_pair(without_3(s_hand)):
        return True
    if (s1 + s2 + s3 + s4 == "0000"):
        return True
    return False


def is_four_of_a_kind(s_hand):
    [s0, s1, s2, s3, s4] = s_hand
    if _is_four_of_a_kind(s_hand):
        return True
    if (s4 == "0") and _is_three_of_a_kind(without_1(s_hand)):
        return True
    if (s3 + s4 == "00") and _is_pair(without_2(s_hand)):
        return True
    if (s2 + s3 + s4 == "000"):
        return True
    return False


def is_full_house(s_hand):
    [s0, s1, s2, s3, s4] = s_hand
    if _is_full_house(s_hand):
        return True
    if (s4 == "0") and _is_two_pairs(without_1(s_hand)):
        return True
    if (s4 == "0") and _is_three_of_a_kind(without_1(s_hand)):
        return True
    if (s3 + s4 == "00") and _is_pair(without_2(s_hand)):
        return True
    return False


def is_three_of_a_kind(s_hand):
    [s0, s1, s2, s3, s4] = s_hand
    if _is_three_of_a_kind(s_hand):
        return True
    if (s4 == "0") and _is_pair(without_1(s_hand)):
        return True
    if (s3 + s4 == "00"):
        return True
    return False


def is_two_pairs(s_hand):
    [s0, s1, s2, s3, s4] = s_hand
    if _is_two_pairs(s_hand):
        return True
    if (s4 == "0") and _is_pair(without_1(s_hand)):
        return True
    return False


def is_pair(s_hand):
    [s0, s1, s2, s3, s4] = s_hand
    if _is_pair(s_hand):
        return True
    if s4 == "0":
        return True
    return False


def _is_five_of_a_kind(s_hand):
    return s_hand[0] == s_hand[1] == s_hand[2] == s_hand[3] == s_hand[4]


def _is_four_of_a_kind(s_hand):
    return (s_hand[0] == s_hand[1] == s_hand[2] == s_hand[3]) or (s_hand[1] == s_hand[2] == s_hand[3] == s_hand[4])


def _is_full_house(s_hand):
    return ((s_hand[0] == s_hand[1] == s_hand[2]) and (s_hand[3] == s_hand[4])) or ((s_hand[0] == s_hand[1]) and (s_hand[2] == s_hand[3] == s_hand[4]))


def _is_three_of_a_kind(s_hand):
    return s_hand[0] == s_hand[1] == s_hand[2] or (s_hand[1] == s_hand[2] == s_hand[3]) or (s_hand[2] == s_hand[3] == s_hand[4])


def _is_two_pairs(s_hand):
    if (s_hand[0] == s_hand[1]) and ((s_hand[2] == s_hand[3]) or (s_hand[3] == s_hand[4])):
        return True
    if (s_hand[1] == s_hand[2]) and (s_hand[3] == s_hand[4]):
        return True
    return False


def _is_pair(s_hand):
    return s_hand[0] == s_hand[1] or (s_hand[1] == s_hand[2]) or (s_hand[2] == s_hand[3]) or (s_hand[3] == s_hand[4])


def val(hand):
    m_hand = remap(hand)
    s_hand = ''.join(sorted(m_hand, reverse=True))

    if is_five_of_a_kind(s_hand):
        print(f"is_five_of_a_kind: {s_hand}, was {hand}")
        return "7" + m_hand
    if is_four_of_a_kind(s_hand):
        print(f"is_four_of_a_kind: {s_hand}, was {hand}")
        return "6" + m_hand
    if is_full_house(s_hand):
        print(f"is_full_house: {s_hand}, was {hand}")
        return "5" + m_hand
    if is_three_of_a_kind(s_hand):
        print(f"is_three_of_a_kind: {s_hand}, was {hand}")
        return "4" + m_hand
    if is_two_pairs(s_hand):
        print(f"is_two_pairs: {s_hand}, was {hand}")
        return "3" + m_hand
    if is_pair(s_hand):
        print(f"is_pair: {s_hand}, was {hand}")
        return "2" + m_hand
    return "1" + m_hand


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
            res.append('0')
        elif card == "T":
            res.append('A')
        else:
            res.append(card)
    return ''.join(res)


hands_data = []  # array of (hand, val, bid)
# parse file
with open("input.txt") as file:
    for line_nb, line in enumerate(file.readlines()):
        line = line.strip()
        [hand, bid] = line.split(" ")
        bid = int(bid)
        hands_data.append((hand, val(hand), bid))

# print(f"before hands_data: {hands_data}")
hands_data.sort(key=lambda x: x[1])
# print(f"after hands_data: {hands_data}")

for idx, hand_data in enumerate(hands_data):
    res += (idx + 1) * hand_data[2]
    # print(hand_data[0], hand_data[1])
print(f"result: {res}")
