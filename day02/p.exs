#!/usr/bin/env elixir

defmodule P1 do
  @maxes %{"red" => 12, "green" => 13, "blue" => 14}

  def process_set(set) do
    set
    |> String.split(", ")
    |> Enum.into(%{"red" => 0, "green" => 0, "blue" => 0}, fn cube ->
      [num, color] = String.split(cube, " ")
      {color, String.to_integer(num)}
    end)
  end

  def is_acceptable_game?(game) do
    @maxes |> Enum.all?(fn {color, num} -> game[color] <= num end)
  end

  def process_line({line, idx}) do
    [_, rest] = String.split(line, ": ")

    is_valid =
      rest
      |> String.split("; ")
      |> Enum.map(&process_set/1)
      |> Enum.all?(&is_acceptable_game?/1)

    if is_valid, do: idx, else: 0
  end

  def run(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
    |> Enum.with_index(1)
    |> Enum.map(&process_line/1)
    |> Enum.sum()
    |> IO.puts()
  end
end

defmodule P2 do
  def compute_max_colors(games) do
    games
    |> Enum.reduce(%{"red" => 0, "green" => 0, "blue" => 0}, fn game, acc ->
      Enum.reduce(game, acc, fn {color, num}, acc ->
        %{acc | color => max(num, acc[color])}
      end)
    end)
  end

  def process_line(line) do
    [_, rest] = String.split(line, ": ")

    rest
    |> String.split("; ")
    |> Enum.map(&P1.process_set/1)
    |> compute_max_colors()
    |> Map.values()
    |> Enum.product()
  end

  def run(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
    |> Enum.map(&process_line/1)
    |> Enum.sum()
    |> IO.puts()
  end
end

P1.run("sample.txt")
# P1.run("input.txt")
# P2.run("sample.txt")
# P2.run("input.txt")
