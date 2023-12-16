#!/usr/bin/env elixir

defmodule P1 do
  # a base transpose function
  def transpose(rows) do
    rows
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  def parse_file(filename) do
    for pattern <- File.read!(filename) |> String.split("\n\n", trim: true) do
      pattern |> String.split("\n", trim: true) |> Enum.map(&String.to_charlist/1)
    end
  end

  def find_reflection_after_row(pattern, row_idx) do
    res =
      0..min(row_idx, Enum.count(pattern) - 1 - row_idx)
      |> Enum.reduce_while([], fn i, acc ->
        above = row_idx - i
        below = row_idx + 1 + i

        row_above = Enum.at(pattern, above)
        row_below = Enum.at(pattern, below)

        case row_above == row_below do
          true -> {:cont, [above, below]}
          false -> {:halt, acc}
        end
      end)

    # it only counts if we reached the one of the sides
    nb_rows = Enum.count(pattern) - 1

    case res do
      [0, _] -> row_idx + 1
      [_, ^nb_rows] -> row_idx + 1
      _ -> 0
    end
  end

  def find_reflections(pattern) do
    nb_rows = Enum.count(pattern)

    0..(nb_rows - 1)
    |> Enum.map(&find_reflection_after_row(pattern, &1))
    |> Enum.max()
  end

  def run(filename) do
    for {pattern, idx} <- parse_file(filename) |> Enum.with_index() do
      hori = pattern |> find_reflections()
      vert = pattern |> transpose |> find_reflections()
      (hori * 100 + vert) |> IO.inspect(label: "pattern #{idx}")
    end
    |> Enum.sum()
    |> IO.inspect(label: "total")
  end
end

defmodule P2 do
  def run(filename) do
    for {pattern, idx} <- P1.parse_file(filename) |> Enum.with_index() do
      hori = pattern |> P1.find_reflections()
      vert = pattern |> P1.transpose() |> P1.find_reflections()
      (hori * 100 + vert) |> IO.inspect(label: "pattern #{idx}")
    end
    |> Enum.sum()
    |> IO.inspect(label: "total")
  end
end

# P1.run("sample.txt")
# P1.run("input.txt")
P2.run("sample.txt")
# P2.run("input.txt")
#
