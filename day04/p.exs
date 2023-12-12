#!/usr/bin/env elixir

defmodule P1 do
  def parse_line(line) do
    [_, rest] = String.split(line, ": ")

    for nbs <- String.split(rest, " | ") do
      for [nb] <- Regex.scan(~r/\d+/, nbs), into: MapSet.new() do
        String.to_integer(nb)
      end
    end
  end

  def run(filename) do
    for line <- File.read!(filename) |> String.split("\n", trim: true) do
      [winning_nbs, my_nbs] = parse_line(line)

      case winning_nbs |> MapSet.intersection(my_nbs) |> MapSet.size() do
        0 -> 0
        nb -> 2 ** (nb - 1)
      end
    end
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
    for line <- File.read!(filename) |> String.split("\n", trim: true) do
      [winning_nbs, my_nbs] = P1.parse_line(line)
      winning_nbs |> MapSet.intersection(my_nbs) |> MapSet.size()
    end
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
