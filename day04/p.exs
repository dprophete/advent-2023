#!/usr/bin/env elixir

defmodule P1 do
  def parse_line(line) do
    [_, rest] = String.split(line, ": ")
    [left, right] = String.split(rest, " | ")

    wining_nbs =
      Regex.scan(~r/\d+/, left)
      |> Enum.map(&List.first/1)
      |> Enum.map(&String.to_integer/1)
      |> MapSet.new()

    my_nbs =
      Regex.scan(~r/\d+/, right)
      |> Enum.map(&List.first/1)
      |> Enum.map(&String.to_integer/1)
      |> MapSet.new()

    wining_nbs
    |> MapSet.intersection(my_nbs)
    |> MapSet.size()
  end

  def run(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.filter(&(&1 > 0))
    |> Enum.map(&(2 ** (&1 - 1)))
    |> Enum.sum()
    |> IO.puts()
  end
end

defmodule P2 do
  def nb_cards_gained(cards_gained, line_nb) do
    Map.get(cards_gained, line_nb, 0)
  end

  def handle_new_wins({nb_wins, line_nb}, {cards_gained, gains}) do
    # IO.puts("line #{line_nb} has #{nb_wins} wins")

    nb_cards_current_line = 1 + nb_cards_gained(cards_gained, line_nb)

    cards_gained =
      line_nb..(line_nb + nb_wins)
      |> Enum.reduce(cards_gained, fn i, cards_gained ->
        Map.put(cards_gained, i, nb_cards_current_line + nb_cards_gained(cards_gained, i))
      end)

    {cards_gained, gains + nb_cards_current_line}
  end

  def run(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
    |> Enum.map(&P1.parse_line/1)
    |> Enum.with_index(1)
    |> Enum.reduce({%{}, 0}, &handle_new_wins/2)
    |> then(fn {_cards_gained, gains} -> gains end)
    |> IO.puts()
  end
end

# P1.run("sample.txt")
# P1.run("input.txt")
# P2.run("sample.txt")
P2.run("input.txt")
