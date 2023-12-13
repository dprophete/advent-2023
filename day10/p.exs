#!/usr/bin/env elixir

defmodule P1 do
  @base_connections %{
    ?| => [:north, :south],
    ?- => [:east, :west],
    ?L => [:north, :east],
    ?J => [:north, :west],
    ?7 => [:south, :west],
    ?F => [:south, :east]
  }

  def connections_from_char(c) do
    @base_connections[c] || []
  end

  def char_from_connections([dir1, dir2]) do
    {c, _} =
      @base_connections
      |> Enum.find(fn {_, dirs} -> [dir1, dir2] == dirs || [dir2, dir1] == dirs end)

    c
  end

  def opposite(:north), do: :south
  def opposite(:south), do: :north
  def opposite(:east), do: :west
  def opposite(:west), do: :east

  def move({x, y}, :south), do: {x, y + 1}
  def move({x, y}, :north), do: {x, y - 1}
  def move({x, y}, :east), do: {x + 1, y}
  def move({x, y}, :west), do: {x - 1, y}

  # get the value at position {x, y}
  def at(maze, {x, y}) do
    maze |> Enum.at(y) |> Enum.at(x)
  end

  # move to the next position
  # it needs the previous position to avoid going back
  def nx(maze, current, previous) do
    [dir1, dir2] = at(maze, current) |> connections_from_char

    case move(current, dir1) do
      ^previous -> move(current, dir2)
      new_pos -> new_pos
    end
  end

  # follow the path until we go back to the starting node
  def loop_path(maze, start) do
    [dir1, _] = find_dirs(maze, start)
    first = move(start, dir1)

    loop_path(maze, first, start, [first, start])
  end

  def loop_path(maze, current, previous, path) do
    new_pos = nx(maze, current, previous)

    case at(maze, new_pos) do
      ?S -> path
      _ -> loop_path(maze, new_pos, current, [new_pos | path])
    end
  end

  def parse_file(filename) do
    for line <- File.read!(filename) |> String.split("\n") do
      String.to_charlist(line)
    end
  end

  # surround the maze with .
  def surround(maze) do
    m1 =
      maze
      |> Enum.map(fn line ->
        [?.] ++ line ++ [?.]
      end)

    l0 = List.duplicate(?., length(Enum.at(m1, 0)))
    [l0] ++ m1 ++ [l0]
  end

  # find S position
  def find_s(maze) do
    Enum.reduce_while(maze, 0, fn line, acc ->
      case Enum.find_index(line, &(&1 == ?S)) do
        nil -> {:cont, acc + 1}
        index -> {:halt, {index, acc}}
      end
    end)
  end

  # find the directions under S
  def find_dirs(maze, start) do
    [:west, :east, :north, :south]
    |> Enum.filter(fn dir ->
      pos = move(start, dir)

      case at(maze, pos) |> connections_from_char do
        [d1, d2] -> d1 == opposite(dir) || d2 == opposite(dir)
        _ -> false
      end
    end)
  end

  def run(filename) do
    maze = parse_file(filename) |> surround
    start = find_s(maze)
    path = loop_path(maze, start)

    div(length(path), 2)
    |> IO.puts()
  end
end

defmodule P2 do
  # general rules:
  # we change whether we are in/out based on the combinations of two walls generally
  # for instance:
  #   L----7 -> we switch after the 7
  #   L----J -> we don't switch
  def nx_in_out(in?, last_c, new_c) do
    case {in?, last_c, new_c} do
      # F J -> we switch
      {_, ?F, ?J} -> {!in?, ?.}
      {_, ?J, ?F} -> {!in?, ?.}
      # F 7 -> don't switch
      {_, ?F, ?7} -> {in?, ?.}
      {_, ?7, ?F} -> {in?, ?.}
      # L 7 -> we switch
      {_, ?L, ?7} -> {!in?, ?.}
      {_, ?7, ?L} -> {!in?, ?.}
      # L J -> don't switch
      {_, ?L, ?J} -> {in?, ?.}
      {_, ?J, ?L} -> {in?, ?.}
      # | -> we switch
      {_, _, ?|} -> {!in?, ?.}
      # stating new potential switch
      {_, _, ?J} -> {in?, new_c}
      {_, _, ?F} -> {in?, new_c}
      {_, _, ?7} -> {in?, new_c}
      {_, _, ?L} -> {in?, new_c}
      # don't change anything
      {_, _, _} -> {in?, last_c}
    end
  end

  def run(filename) do
    maze = P1.parse_file(filename) |> P1.surround()
    start = P1.find_s(maze)
    path = P1.loop_path(maze, start) |> MapSet.new()

    Enum.with_index(maze)
    |> Enum.reduce([], fn {line, y}, tiles_in ->
      {_, _, tiles_in} =
        Enum.with_index(line)
        |> Enum.reduce({false, ?., tiles_in}, fn {c, x}, {in?, last_c, tiles_in} ->
          if MapSet.member?(path, {x, y}) do
            c =
              case {x, y} == start do
                true -> P1.char_from_connections(P1.find_dirs(maze, start))
                false -> c
              end

            {new_in?, new_c} = nx_in_out(in?, last_c, c)
            {new_in?, new_c, tiles_in}
          else
            case in? do
              true -> {in?, last_c, [{x, y, to_string([c])} | tiles_in]}
              false -> {in?, last_c, tiles_in}
            end
          end
        end)

      tiles_in
    end)
    # |> IO.inspect()
    |> length
    |> IO.puts()
  end
end

# P1.run("sample.txt")
# P1.run("sample2.txt")
# P1.run("input.txt")

# P2.run("sample.txt")
# P2.run("sample3.txt")
# P2.run("sample6.txt")
# P2.run("sample4.txt")
# P2.run("sample5.txt")
P2.run("input.txt")
