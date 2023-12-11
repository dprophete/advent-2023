#!/usr/bin/env python

digits = ["one", "two", "three", "four", "five", "six", "seven",
          "eight", "nine", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
values = [1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9]

res = 0

with open("input.txt") as file:
    for line_nb, line in enumerate(file.readlines()):
        line = line.strip()
        indexes = []  # array of (digit, index, value)
        for idx, digit in enumerate(digits):
            leftIdx = line.find(digit)
            rightIdx = line.rfind(digit)
            if leftIdx != -1:
                indexes.append((digit, leftIdx, values[idx]))
            if rightIdx != -1 and rightIdx != leftIdx:
                indexes.append((digit, rightIdx, values[idx]))

        indexes.sort(key=lambda x: x[1])
        print(f"{line_nb:3}: {indexes}")
        (_, _, first) = indexes[0]
        (_, _, last) = indexes[-1]
        res += first*10 + last

print(res)
