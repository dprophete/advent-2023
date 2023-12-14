#!/usr/bin/env elixir

defmodule P1 do
  # a base transpose function
  def transpose(rows) do
    rows
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  def reduce_with_index(list, acc, fun) do
    list |> Enum.with_index() |> Enum.reduce(acc, fun)
  end

  # surround the galaxy with .
  def add_row_at(galaxy, y) do
    row = List.duplicate(?., length(Enum.at(galaxy, 0)))
    galaxy |> List.insert_at(y, row)
  end

  def add_empty_rows(galaxy) do
    galaxy
    |> Enum.reduce({0, galaxy}, fn row, {idx, galaxy} ->
      case Enum.member?(row, ?#) do
        true -> {idx + 1, galaxy}
        false -> {idx + 2, add_row_at(galaxy, idx)}
      end
    end)
    |> elem(1)
  end

  def expand(galaxy) do
    galaxy |> add_empty_rows |> transpose |> add_empty_rows |> transpose
  end

  def print(galaxy) do
    galaxy |> Enum.with_index() |> Enum.map(&IO.inspect/1)
  end

  def parse_file(filename) do
    for line <- File.read!(filename) |> String.split("\n", trim: true) do
      String.to_charlist(line)
    end
  end

  def find_stars(galaxy) do
    reduce_with_index(galaxy, [], fn {row, y}, stars ->
      reduce_with_index(row, stars, fn {char, x}, stars ->
        case char do
          ?# -> [{x, y} | stars]
          _ -> stars
        end
      end)
    end)
  end

  def distance({x1, y1}, {x2, y2}) do
    abs(x2 - x1) + abs(y2 - y1)
  end

  def all_distances(stars) do
    for star1 <- stars, star2 <- stars, star1 != star2 do
      distance(star1, star2)
    end
  end

  def run(filename) do
    galaxy = parse_file(filename) |> expand
    stars = find_stars(galaxy)

    # print(galaxy)

    all_distances(stars)
    |> Enum.sum()
    |> then(&div(&1, 2))
    |> IO.puts()
  end
end

defmodule P2 do
  def sort({a, b}) do
    case a < b do
      true -> {a, b}
      false -> {b, a}
    end
  end

  def find_empty_rows(galaxy) do
    galaxy
    |> Enum.with_index()
    |> Enum.filter(fn {row, _} -> !Enum.member?(row, ?#) end)
    |> Enum.map(fn {_, y} -> y end)
  end

  def distance(p1, p2, expansion, empty_rows, empty_cols) do
    {x1, x2} = sort(p1)
    {y1, y2} = sort(p2)
    extra_cols = Enum.count(empty_cols, fn x -> x1 < x && x < x2 end)
    extra_rows = Enum.count(empty_rows, fn y -> y1 < y && y < y2 end)
    P1.distance(p1, p2) + (extra_cols + extra_rows) * (expansion - 1)
  end

  def all_distances(stars, expansion, empty_rows, empty_cols) do
    for star1 <- stars, star2 <- stars, star1 != star2 do
      distance(star1, star2, expansion, empty_rows, empty_cols)
    end
  end

  def run(filename, expansion) do
    galaxy = P1.parse_file(filename)
    stars = P1.find_stars(galaxy)

    # P1.print(galaxy)

    empty_rows = galaxy |> find_empty_rows
    empty_cols = galaxy |> P1.transpose() |> find_empty_rows

    all_distances(stars, expansion, empty_rows, empty_cols)
    |> Enum.sum()
    |> then(&div(&1, 2))
    |> IO.puts()
  end
end

# P1.run("sample.txt")
P1.run("input.txt")
# P2.run("sample.txt", 10)
P2.run("input.txt", 1_000_000)
