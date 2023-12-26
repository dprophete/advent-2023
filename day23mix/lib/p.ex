#!/usr/bin/env elixir

# DSL:

defmodule P1 do
  # --------------------------------------------------------------------------------
  # - parsing
  # --------------------------------------------------------------------------------

  def parse_file(filename) do
    map =
      for {line, _idx} <-
            File.read!(filename) |> String.split("\n", trim: true) |> Enum.with_index() do
        String.to_charlist(line)
      end

    entrance = List.first(map) |> Enum.find_index(&(&1 == ?.))
    exit = List.last(map) |> Enum.find_index(&(&1 == ?.))
    {map, {entrance, 0}, {exit, Enum.count(map) - 1}}
  end

  # --------------------------------------------------------------------------------
  # - pp
  # --------------------------------------------------------------------------------

  def pp_map(map) do
    map |> Enum.map(&IO.puts(&1))
  end

  def pp_map_with_path(map, path) do
    map =
      for {px, py} <- path, reduce: map do
        map ->
          row = Enum.at(map, py)
          List.replace_at(map, py, List.replace_at(row, px, ?O))
      end

    pp_map(map)
  end

  # --------------------------------------------------------------------------------
  # - running
  # --------------------------------------------------------------------------------

  def at(map, path, {x, y}) do
    if {x, y} in path do
      :path
    else
      case map |> Enum.at(y) |> Enum.at(x) do
        nil -> :out
        ?# -> :wall
        ?> -> :right
        ?< -> :left
        ?^ -> :up
        ?v -> :down
        ?. -> :empty
      end
    end
  end

  def nx_moves(map, [{x, y} = current | path]) do
    candidate =
      case at(map, path, current) do
        :up ->
          [{x, y - 1}]

        :down ->
          [{x, y + 1}]

        :left ->
          [{x - 1, y}]

        :right ->
          [{x + 1, y}]

        _ ->
          [
            {x, y - 1},
            {x, y + 1},
            {x - 1, y},
            {x + 1, y}
          ]
      end

    candidate
    |> Enum.filter(fn p ->
      p != current && at(map, path, p) in [:empty, :left, :right, :up, :down]
    end)
  end

  # return array of path which ended up succeeding
  def walk_one(_map, exit, [exit | _rest] = path) do
    IO.inspect("[DDA] found exit! with length #{Enum.count(path) - 1}")
    [path]
  end

  def walk_one(map, exit, path) do
    nx_moves(map, path) |> Enum.flat_map(fn p -> walk_one(map, exit, [p | path]) end)
  end

  def run(filename) do
    {map, entrance, exit} = parse_file(filename)
    paths = walk_one(map, exit, [entrance])

    # for path <- paths do
    #   IO.puts("\n== path length #{Enum.count(path) - 1}")
    #   pp_map_with_path(map, path)
    # end

    paths |> Enum.map(&(Enum.count(&1) - 1)) |> Enum.max() |> IO.inspect()
  end
end

defmodule P2 do
  def run(filename) do
    {map, entrance, exit} = P1.parse_file(filename)

    map =
      for row <- map do
        for c <- row do
          case c do
            ?> -> ?.
            ?< -> ?.
            ?^ -> ?.
            ?v -> ?.
            _ -> c
          end
        end
      end

    paths = P1.walk_one(map, exit, [entrance])

    # for path <- paths do
    #   IO.puts("\n== path length #{Enum.count(path) - 1}")
    #   pp_map_with_path(map, path)
    # end

    paths |> Enum.map(&(Enum.count(&1) - 1)) |> Enum.max() |> IO.inspect()
  end
end

defmodule P do
  def start() do
    Cache.setup()
    # P1.run("sample.txt")
    P1.run("input.txt")
    # P2.run("sample.txt")
    # P2.run("input.txt")
  end
end
