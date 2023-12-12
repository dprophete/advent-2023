#!/usr/bin/env elixir

defmodule P1 do
  def parse_file(filename) do
    for line <- File.read!(filename) |> String.split("\n") do
      line |> String.split(" ") |> Enum.map(&String.to_integer/1)
    end
  end

  def is_final_row(row) do
    Enum.all?(row, &(&1 == 0))
  end

  def compute_next_row(row) do
    row |> Enum.chunk_every(2, 1, :discard) |> Enum.map(fn [a, b] -> b - a end)
  end

  def compute_rows(row, res) do
    case is_final_row(row) do
      true -> [row | res]
      false -> compute_rows(compute_next_row(row), [row | res])
    end
  end

  def process_history(history) do
    compute_rows(history, [])
    |> Enum.reduce(0, fn row, acc -> List.last(row) + acc end)
  end

  def run(filename) do
    parse_file(filename)
    |> Enum.map(&process_history/1)
    |> Enum.sum()
    |> IO.puts()
  end
end

defmodule P2 do
  def process_history(history) do
    P1.compute_rows(history, [])
    |> Enum.reduce(0, fn [first | _], acc -> first - acc end)
  end

  def run(filename) do
    P1.parse_file(filename)
    |> Enum.map(&process_history/1)
    |> Enum.sum()
    |> IO.puts()
  end
end

# P1.run("sample.txt")
# P1.run("input.txt")
# P2.run("sample.txt")
P2.run("input.txt")
