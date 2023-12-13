#!/usr/bin/env elixir

defmodule P1 do
  # | is a vertical pipe connecting north and south.
  # - is a horizontal pipe connecting east and west.
  # L is a 90-degree bend connecting north and east.
  # J is a 90-degree bend connecting north and west.
  # 7 is a 90-degree bend connecting south and west.
  # F is a 90-degree bend connecting south and east.
  # . is ground; there is no pipe in this tile.
  # S is the starting position of the animal; there is a pipe on this tile, but your sketch doesn't show what shape the pipe has.

  def connections(c) do
    case c do
      ?| -> [:north, :south]
      ?- -> [:east, :west]
      ?L -> [:north, :east]
      ?J -> [:north, :west]
      ?7 -> [:south, :west]
      ?F -> [:south, :east]
      ?. -> []
      ?S -> []
    end
  end

  def opposite(:north), do: :south
  def opposite(:south), do: :north
  def opposite(:east), do: :west
  def opposite(:west), do: :east

  def move({x, y}, :south), do: {x, y + 1}
  def move({x, y}, :north), do: {x, y - 1}
  def move({x, y}, :east), do: {x + 1, y}
  def move({x, y}, :west), do: {x - 1, y}

  def at(maze, {x, y}) do
    maze |> Enum.at(y) |> Enum.at(x)
  end

  def nx(maze, current, previous) do
    [dir1, dir2] = at(maze, current) |> connections

    case move(current, dir1) do
      ^previous -> move(current, dir2)
      new_pos -> new_pos
    end
  end

  def longuest_path(maze, current, previous, count) do
    new_pos = nx(maze, current, previous)

    case at(maze, new_pos) do
      ?S -> count + 1
      _ -> longuest_path(maze, new_pos, current, count + 1)
    end
  end

  def parse_file(filename) do
    for line <- File.read!(filename) |> String.split("\n") do
      String.to_charlist(line)
    end
  end

  def surround(maze) do
    m1 =
      maze
      |> Enum.map(fn line ->
        [?.] ++ line ++ [?.]
      end)

    l0 = List.duplicate(?., length(Enum.at(m1, 0)))
    [l0] ++ m1 ++ [l0]
  end

  def find_s(maze) do
    Enum.reduce_while(maze, 0, fn line, acc ->
      case Enum.find_index(line, &(&1 == ?S)) do
        nil -> {:cont, acc + 1}
        index -> {:halt, {index, acc}}
      end
    end)
  end

  def run(filename) do
    maze = parse_file(filename) |> surround
    start = find_s(maze)

    [dir1, _] =
      [:west, :east, :north, :south]
      |> Enum.filter(fn dir ->
        pos = move(start, dir)

        case at(maze, pos) |> connections do
          [d1, d2] -> d1 == opposite(dir) || d2 == opposite(dir)
          _ -> false
        end
      end)

    first = move(start, dir1)

    div(longuest_path(maze, first, start, 1), 2)
    |> IO.puts()
  end
end

defmodule P2 do
end

# P1.run("sample.txt")
# P1.run("sample2.txt")
P1.run("input.txt")
# P2.run("sample.txt")
# P2.run("input.txt")
