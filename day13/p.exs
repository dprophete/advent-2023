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

        # IO.puts(
        #   "comparing #{above} and #{below} -> #{Enum.at(pattern, above) == Enum.at(pattern, below)}"
        # )

        case Enum.at(pattern, above) == Enum.at(pattern, below) do
          true -> {:cont, [above, below]}
          false -> {:halt, acc}
        end
      end)

    # it only counts if we reached the one of the sides
    nb_rows = Enum.count(pattern) - 1

    # dbg(res)

    case res do
      [0, _] -> row_idx + 1
      [_, ^nb_rows] -> row_idx + 1
      _ -> 0
    end
  end

  def find_reflections(pattern) do
    nb_rows = Enum.count(pattern)

    0..(nb_rows - 1)
    |> Enum.map(fn i ->
      find_reflection_after_row(pattern, i)
    end)
    |> Enum.max()
  end

  def run(filename) do
    for pattern <- parse_file(filename) do
      hori = pattern |> find_reflections()
      vert = pattern |> transpose |> find_reflections()
      hori * 100 + vert
    end
    |> Enum.sum()
    |> IO.inspect(label: "total")
  end
end

defmodule P2 do
end

# P1.run("sample.txt")
P1.run("input.txt")
# P2.run("sample.txt")
# P2.run("input.txt")
