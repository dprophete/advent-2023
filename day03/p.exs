#!/usr/bin/env elixir

defmodule P1 do
  # return list of {nb, x_start, x_end, y} for each number
  def detect_nbs({line, line_idx}) do
    Regex.scan(~r/\d+/, line, return: :index)
    |> Enum.map(fn [{idx, len}] ->
      [
        nb: line |> String.slice(idx, len) |> String.to_integer(),
        x_start: idx,
        x_end: idx + len - 1,
        y: line_idx
      ]
    end)
  end

  # return list of {x, y} for each symbol
  def detect_symbols({line, line_idx}) do
    Regex.scan(~r{[^0-9.]}, line, return: :index)
    |> Enum.map(fn [{idx, _len}] ->
      {idx, line_idx}
    end)
  end

  def is_symbol_at(symbols, point) do
    Enum.member?(symbols, point)
  end

  # return all the points to check for a given number
  def points_to_check(_nb_info = [nb: _nb, x_start: x_start, x_end: x_end, y: y]) do
    Enum.concat(Enum.map((x_start - 1)..(x_end + 1), &[{&1, y - 1}, {&1, y + 1}])) ++
      [{x_start - 1, y}, {x_end + 1, y}]
  end

  # return true if the number is next to a symbol
  def is_number_valid(symbols, nb_info) do
    nb_info
    |> points_to_check
    |> Enum.any?(&is_symbol_at(symbols, &1))
  end

  def run(filename) do
    lines =
      File.read!(filename)
      |> String.split("\n", trim: true)
      |> Enum.with_index(0)

    all_nbs =
      lines |> Enum.flat_map(&detect_nbs/1)

    all_symbols =
      lines
      |> Enum.flat_map(&detect_symbols/1)

    all_nbs
    |> Enum.filter(&is_number_valid(all_symbols, &1))
    |> Enum.map(& &1[:nb])
    |> Enum.sum()
    |> IO.puts()
  end
end

defmodule P2 do
  def detect_gears({line, line_idx}) do
    Regex.scan(~r{[*]}, line, return: :index)
    |> Enum.map(fn [{idx, _len}] ->
      {idx, line_idx}
    end)
  end

  # return true if the number is next to a gear
  def is_number_next_to_gear(gear, nb_info) do
    Enum.member?(P1.points_to_check(nb_info), gear)
  end

  # return all the numbers next to a gear
  def numbers_next_to_gear(gear, all_nbs) do
    all_nbs
    |> Enum.filter(&is_number_next_to_gear(gear, &1))
    |> Enum.map(& &1[:nb])
  end

  def run(filename) do
    lines =
      File.read!(filename)
      |> String.split("\n", trim: true)
      |> Enum.with_index(0)

    all_nbs =
      lines |> Enum.flat_map(&P1.detect_nbs/1)

    all_gears =
      lines |> Enum.flat_map(&detect_gears/1)

    all_gears
    |> Enum.map(fn gear ->
      case numbers_next_to_gear(gear, all_nbs) do
        [nb1, nb2] -> nb1 * nb2
        _ -> 0
      end
    end)
    |> Enum.sum()
    |> IO.puts()
  end
end

# P1.run("sample.txt")
# P1.run("input.txt")
# P2.run("sample.txt")
P2.run("input.txt")
