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

  def find_os(map, size) do
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
      for i <- 1..64, reduce: map do
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
end

defmodule P do
  def start() do
    Cache.setup()
    # P1.run("sample.txt")
    P1.run("input.txt")
    # P2.run("sample.txt")
    # P2.run("input.txt")
  end

  # sample: 32000000 -> good
  # sample2: 11687500 -> good
  # input: 831459892 ->  not good
end
