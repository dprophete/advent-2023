#!/usr/bin/env elixir

# DSL:

defmodule P1 do
  # --------------------------------------------------------------------------------
  # - parsing
  # --------------------------------------------------------------------------------

  def parse_file(filename) do
    # first pass, get name and dests
    {map, start} =
      for {line, y} <-
            File.read!(filename) |> String.split("\n", trim: true) |> Enum.with_index(),
          reduce: {%{}, {-1, -1}} do
        {map, start} ->
          for {c, x} <- line |> String.to_charlist() |> Enum.with_index(), reduce: {map, start} do
            {map, start} ->
              case c do
                ?# -> {Map.put(map, {x, y}, c), start}
                ?S -> {Map.put(map, {x, y}, ?O), {x, y}}
                _ -> {map, start}
              end
          end
      end

    {w, h} =
      for {x, y} <- Map.keys(map), reduce: {0, 0} do
        {w, h} ->
          {max(w, x), max(h, y)}
      end

    {map, start, {w + 2, h + 2}}
  end

  # --------------------------------------------------------------------------------
  # - running
  # --------------------------------------------------------------------------------

  def at(map, {w, h}, {x, y}) do
    cond do
      x < 0 or x >= w or y < 0 or y >= h -> :wall
      Map.get(map, {x, y}) == ?# -> :rock
      true -> :sand
    end
  end

  def valid_moves(map, size, {x, y}) do
    [
      {x - 1, y},
      {x + 1, y},
      {x, y - 1},
      {x, y + 1}
    ]
    |> Enum.filter(fn {x, y} -> at(map, size, {x, y}) == :sand end)
  end

  def move_one(map, size, {x, y}) do
    moves = valid_moves(map, size, {x, y})

    map = Map.delete(map, {x, y})

    map =
      for move <- moves, reduce: map do
        map ->
          Map.put(map, move, ?O)
      end

    {map, moves}
  end

  def find_os(map, _size) do
    for {x, y} <- Map.keys(map), reduce: [] do
      acc ->
        case Map.get(map, {x, y}) do
          ?O -> [{x, y} | acc]
          _ -> acc
        end
    end
  end

  def move_ones(map, size) do
    # find all the Os
    os = find_os(map, size)

    map =
      for o <- os, reduce: map do
        map ->
          {map, _} = move_one(map, size, o)
          map
      end

    map
  end

  def pp_map(map, {w, h}) do
    for y <- 0..(w - 1) do
      for x <- 0..(h - 1) do
        IO.write(
          case Map.get(map, {x, y}) do
            nil -> [?.]
            c -> [c]
          end
        )
      end

      IO.puts("")
    end
  end

  def run(filename) do
    {map, _start, size} = parse_file(filename)

    IO.puts("--- original map ---")
    pp_map(map, size)

    map =
      for _i <- 1..64, reduce: map do
        map ->
          move_ones(map, size)
      end

    IO.puts("--- after moves ---")
    pp_map(map, size)

    IO.puts("--- count ---")
    IO.inspect(find_os(map, size) |> Enum.count())
  end
end

defmodule P2 do
  # --------------------------------------------------------------------------------
  # - running
  # --------------------------------------------------------------------------------

  # def at(map, {w, h}, os, {x, y}) do
  #   cond do
  #     # x < 0 or x >= w or y < 0 or y >= h -> :wall
  #     {rem(x, w), rem(y, h)} in map -> :rock
  #     {x, y} in os -> :o
  #     true -> :sand
  #   end
  # end

  # def valid_moves(map, size, os, {x, y}) do
  #   [
  #     {x - 1, y},
  #     {x + 1, y},
  #     {x, y - 1},
  #     {x, y + 1}
  #   ]
  #   |> Enum.filter(fn {x, y} -> at(map, size, os, {x, y}) == :sand end)
  # end

  # def move_one(map, size, os, {x, y}) do
  #   moves = valid_moves(map, size, os, {x, y}) |> MapSet.new()

  #   os
  #   # |> MapSet.delete({x, y})
  #   |> MapSet.union(moves)
  # end

  def move_ones(map, {w, h}, os) do
    os
    |> Enum.flat_map(fn {x, y} ->
      [
        {x - 1, y},
        {x + 1, y},
        {x, y - 1},
        {x, y + 1}
      ]
    end)
    |> MapSet.new()
    |> Enum.filter(fn {x, y} ->
      x = rem(x, w)
      x = if x < 0, do: x + w, else: x
      y = rem(y, h)
      y = if y < 0, do: y + w, else: y

      !({x, y} in map)
    end)
    |> MapSet.new()
  end

  def pp_map(map, {w, h}, os) do
    for y <- 0..(w - 1) do
      for x <- 0..(h - 1) do
        IO.write(
          cond do
            {x, y} in map -> [?#]
            {x, y} in os -> [?O]
            true -> [?.]
          end
        )
      end

      IO.puts("")
    end
  end

  def os_in_square(os, {w, h}, {x, y}) do
    os
    |> Enum.filter(fn {x1, y1} ->
      x1 >= x * w && x1 < x * w + w && y1 >= y * h && y1 < y * h + h
    end)
    |> Enum.count()
  end

  def handle_pattern(pattern, offset, iter) do
    {start, os} = pattern
    length = Enum.count(os)

    cond do
      iter < offset + start -> 0
      iter < offset + start + length -> Enum.at(os, iter - start - offset)
      true -> Enum.at(os, length - 2 + rem(iter - start - length - offset, 2))
    end
  end

  # predict number of Os in square {x, y} after iter iterations
  def predict_os_in_square({x, y}, iter) do
    cond do
      x == 0 && y == 0 ->
        handle_pattern(Patterns.pattern_0_0(), 0, iter)

      x < 0 && y == 0 ->
        handle_pattern(Patterns.pattern_minus_n_0(), (-x - 1) * 131, iter)

      x > 0 && y == 0 ->
        handle_pattern(Patterns.pattern_n_0(), (x - 1) * 131, iter)

      x == 0 && y < 0 ->
        handle_pattern(Patterns.pattern_0_minus_n(), (-y - 1) * 131, iter)

      x == 0 && y > 0 ->
        handle_pattern(Patterns.pattern_0_n(), (y - 1) * 131, iter)

      x < 0 && y < 0 ->
        handle_pattern(Patterns.pattern_minus_n_minus_m(), (-y - 1 - x - 1) * 131, iter)

      x > 0 && y > 0 ->
        handle_pattern(Patterns.pattern_n_m(), (y - 1 + x - 1) * 131, iter)

      x < 0 && y > 0 ->
        handle_pattern(Patterns.pattern_minus_n_m(), (y - 1 - x - 1) * 131, iter)

      x > 0 && y < 0 ->
        handle_pattern(Patterns.pattern_n_minus_m(), (-y - 1 + x - 1) * 131, iter)

      true ->
        IO.puts("### error for square #{x}, #{y}")
    end
  end

  def run(_filename, nb_steps) do
    # {map, start, _size} = P1.parse_file(filename)
    # map = Map.keys(map) |> MapSet.new() |> MapSet.delete(start)
    # os = MapSet.new([start])

    # IO.puts("--- original map ---")
    # pp_map(map, size, os)

    # square = {1, -1}

    # os =
    #   for i <- 1..nb_steps, reduce: os do
    #     os ->
    #       os = move_ones(map, size, os)

    #       if rem(i, 100) == 0 do
    #         IO.puts("#{i}")
    #       end

    #       # in_square = os_in_square(os, size, square)
    #       # predict = predict_os_in_square(square, i)

    #       # if in_square > 0 do
    #       #   IO.puts("in square #{inspect(square)} for #{i}: #{in_square}")
    #       # end

    #       # if in_square != predict do
    #       #   IO.puts(
    #       #     "### in square #{inspect(square)} for #{i}: in_square #{in_square}, predict #{predict}"
    #       #   )
    #       # end

    #       os
    #   end

    # IO.puts("--- count ---")
    # IO.inspect(Enum.count(os))

    IO.puts("--- predict ---")

    dist = ceil(nb_steps / 131)
    IO.puts("[DDA] dist #{dist}-> will need #{div(4 * dist * dist, 1_000_000_000)} billion tiles")

    res =
      for i <- 1..dist do
        i * predict_os_in_square({1, i}, nb_steps) +
          i * predict_os_in_square({-1, i}, nb_steps) +
          i * predict_os_in_square({-1, -i}, nb_steps) +
          i * predict_os_in_square({1, -i}, nb_steps) +
          predict_os_in_square({i, 0}, nb_steps) +
          predict_os_in_square({0, i}, nb_steps) +
          predict_os_in_square({0, -i}, nb_steps) +
          predict_os_in_square({-i, 0}, nb_steps)
      end
      |> Enum.sum()

    res = res + predict_os_in_square({0, 0}, nb_steps)

    IO.inspect(res, label: "[DDA] res")
  end
end

defmodule P do
  def start() do
    Cache.setup()
    # P1.run("sample.txt")
    # P1.run("input.txt")
    # P2.run("sample.txt", 16)
    # P2.run("sample2.txt", 16)
    # P2.run("input.txt", 400)
    P2.run("input.txt", 26_501_365)
  end

  # sample: 32000000 -> good
  # sample2: 11687500 -> good
  # input: 831459892 ->  not good
end
