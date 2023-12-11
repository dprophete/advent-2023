#!/usr/bin/env python

import re

res = 0
with open("sample.txt") as file:
    for line in file.readlines():
        line = line.strip()
        line = re.sub(r"[a-z]", "", line)
        first = int(line[0])
        last = int(line[-1])
        res += first*10 + last

print(res)
