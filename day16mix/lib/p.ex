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

  def nx_dirs(?., dir), do: [dir]

  def nx_dirs(?\\, :right), do: [:down]
  def nx_dirs(?\\, :left), do: [:up]
  def nx_dirs(?\\, :up), do: [:left]
  def nx_dirs(?\\, :down), do: [:right]

  def nx_dirs(?/, :right), do: [:up]
  def nx_dirs(?/, :left), do: [:down]
  def nx_dirs(?/, :up), do: [:right]
  def nx_dirs(?/, :down), do: [:left]

  def nx_dirs(?-, :up), do: [:left, :right]
  def nx_dirs(?-, :down), do: [:left, :right]
  def nx_dirs(?-, dir), do: [dir]

  def nx_dirs(?|, :right), do: [:up, :down]
  def nx_dirs(?|, :left), do: [:up, :down]
  def nx_dirs(?|, dir), do: [dir]

  def nx(maze, {p0, dir}) do
    p1 = mv(p0, dir)

    case at(maze, p1) do
      :wall -> []
      c -> nx_dirs(c, dir) |> Enum.map(fn dir -> {p1, dir} end)
    end
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
