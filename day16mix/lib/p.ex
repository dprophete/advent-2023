#!/usr/bin/env elixir

defmodule Utils do
  # a base transpose function
  def transpose(rows) do
    rows
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end
end

defmodule Cache do
  def setup() do
    :ets.new(:cache, [:named_table])
  end

  def cache(key, func) do
    case :ets.lookup(:cache, key) do
      [{_, val}] ->
        val

      [] ->
        val = func.()
        :ets.insert(:cache, {key, val})
        val
    end
  end

  def put(key, val) do
    :ets.insert(:cache, {key, val})
  end

  def get(key) do
    case :ets.lookup(:cache, key) do
      [{_, val}] -> val
      _ -> nil
    end
  end
end

defmodule P1 do
  def parse_file(filename) do
    for line <- File.read!(filename) |> String.split("\n", trim: true) do
      String.to_charlist(line)
    end
  end

  # return :wall | val
  def at(maze, {x, y}) do
    w = Cache.get(:w)
    h = Cache.get(:h)

    if x < 0 || y < 0 || x >= w || y >= h do
      :wall
    else
      maze |> Enum.at(y) |> Enum.at(x)
    end
  end

  def mv({x, y}, :up), do: {x, y - 1}
  def mv({x, y}, :down), do: {x, y + 1}
  def mv({x, y}, :left), do: {x - 1, y}
  def mv({x, y}, :right), do: {x + 1, y}

  def nx(maze, {p0, dir}) do
    w = Cache.get(:w)
    h = Cache.get(:h)

    p1 = mv(p0, dir)

    case at(maze, p1) do
      :wall ->
        []

      ?. ->
        [{p1, dir}]

      ?\\ ->
        case dir do
          :right -> [{p1, :down}]
          :left -> [{p1, :up}]
          :up -> [{p1, :left}]
          :down -> [{p1, :right}]
        end

      ?/ ->
        case dir do
          :right -> [{p1, :up}]
          :left -> [{p1, :down}]
          :up -> [{p1, :right}]
          :down -> [{p1, :left}]
        end

      ?- ->
        case dir do
          :right -> [{p1, dir}]
          :left -> [{p1, dir}]
          :up -> [{p1, :left}, {p1, :right}]
          :down -> [{p1, :left}, {p1, :right}]
        end

      ?| ->
        case dir do
          :up -> [{p1, dir}]
          :down -> [{p1, dir}]
          :left -> [{p1, :up}, {p1, :down}]
          :right -> [{p1, :up}, {p1, :down}]
        end
    end
    |> Enum.filter(fn {{x, y}, _} -> x >= 0 && y >= 0 && x < w && y < h end)
  end

  def move_one(maze, beams, visited, step) do
    # IO.inspect("[DDA] step #{step} beam #{inspect(beams)}, visited #{Enum.count(visited)}")

    visited =
      beams |> MapSet.new() |> MapSet.union(visited)

    nx_beams =
      beams
      |> Enum.flat_map(fn beam -> nx(maze, beam) end)
      |> Enum.filter(fn beam -> not MapSet.member?(visited, beam) end)

    case nx_beams do
      [] ->
        visited

      _ ->
        move_one(maze, nx_beams, visited, step + 1)
    end
  end

  def run(filename) do
    maze = parse_file(filename)
    Cache.put(:h, maze |> Enum.count())
    Cache.put(:w, Enum.at(maze, 0) |> Enum.count())

    w = Cache.get(:w)
    h = Cache.get(:h)

    beams = [{{0, 0}, :right}]
    visited = MapSet.new()

    move_one(maze, beams, visited, 0)
    |> MapSet.to_list()
    |> Enum.map(fn {{x, y}, _} -> {x + 1, y + 1} end)
    |> MapSet.new()
    |> MapSet.to_list()
    |> Enum.sort()
    # |> IO.inspect(label: "[DDA] MapSet")
    |> Enum.count()
    |> IO.inspect(label: "[DDA] visited")
  end
end

defmodule P2 do
end

Cache.setup()
# P1.run("sample.txt")
P1.run("input.txt")
# P2.run("sample.txt")
# P2.run("input.txt")
