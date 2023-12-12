#!/usr/bin/env elixir

defmodule P1 do
  def parse_file(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [_, values] = String.split(line, ":")

      Regex.scan(~r/\d+/, values)
      |> Enum.map(&List.first/1)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def nb_wins_for_race({t, d}) do
    1..(t - 1)
    |> Enum.reduce(0, fn time_push, nb_solves ->
      time_remaining = t - time_push
      final_distance = time_remaining * time_push

      if final_distance > d, do: nb_solves + 1, else: nb_solves
    end)
  end

  def run(filename) do
    [times, distances] = parse_file(filename)

    Enum.zip([times, distances])
    |> Enum.map(&nb_wins_for_race/1)
    |> Enum.product()
    |> IO.puts()
  end
end

defmodule P2 do
  def parse_file(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [_, values] = String.split(line, ":")

      values |> String.replace(" ", "") |> String.to_integer()
    end)
  end

  def first_win(time_push, t, d) do
    time_remaining = t - time_push
    final_distance = time_remaining * time_push

    case time_push == t - 1 || final_distance > d do
      true -> time_push
      false -> first_win(time_push + 1, t, d)
    end
  end

  def last_win(time_push, t, d) do
    time_remaining = t - time_push
    final_distance = time_remaining * time_push

    case time_push == 1 || final_distance > d do
      true -> time_push
      false -> last_win(time_push - 1, t, d)
    end
  end

  def run(filename) do
    [t, d] = parse_file(filename)
    first_win_ = first_win(0, t, d)
    last_win_ = last_win(t - 1, t, d)

    (last_win_ - first_win_ + 1)
    |> IO.puts()
  end
end

# P1.run("sample.txt")
# P1.run("input.txt")
# P2.run("sample.txt")
P2.run("input.txt")
