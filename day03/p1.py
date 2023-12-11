#!/usr/bin/env python

all_numbers = []  # array of {nb, x_start, x_end, y}
all_symbols = set()  # set of (x, y)


def is_symbol_at(x, y):
    return (x, y) in all_symbols


def positions_of_number(nb_info):
    x_start = nb_info["x_start"]
    x_end = nb_info["x_end"]
    y = nb_info["y"]
    return [(x, y-1) for x in range(x_start-1, x_end+2)] + [(x, y+1) for x in range(x_start-1, x_end+2)] + [(x_start-1, y), (x_end+1, y)]


def is_number_valid(nb_info):
    for (x, y) in positions_of_number(nb_info):
        if is_symbol_at(x, y):
            return True
    return False


def detect_symbol(line_nb, line):
    nb = 0
    nb_start = 0

    for idx, c in enumerate("." + line + "."):
        try:
            digit = int(c)
            if nb == 0:
                nb_start = idx
            nb = nb*10 + digit
        except:
            if nb > 0:
                all_numbers.append(
                    {"nb": nb, "x_start": nb_start, "x_end": idx-1, "y": line_nb})
            nb = 0

            if c != ".":
                #  print(f"symbol at {c}")
                all_symbols.add((idx, line_nb))


res = 0

with open("input.txt") as file:
    for line_nb, line in enumerate(file.readlines()):
        line = line.strip()
        detect_symbol(line_nb + 1, line)

print(f"nb symbols: {len(all_symbols)}")
for nb_info in all_numbers:
    nb = nb_info['nb']
    if is_number_valid(nb_info):
        #  print(f"nb {nb} is valid")
        res += nb
    else:
        pass
        #  print(f"nb {nb} is NOT valid")

# print(f"numbers: {all_numbers}")
# print(f"symbols: {all_symbols}")
print(res)
