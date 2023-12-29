#!/usr/bin/env elixir

defmodule P1 do
  def parse_file(filename) do
    for line <- File.read!(filename) |> String.split("\n", trim: true) do
      [dir, nb, _] = String.split(line, " ", trim: true)
      nb = String.to_integer(nb)

      dir =
        case dir do
          "R" -> :r
          "L" -> :l
          "U" -> :u
          "D" -> :d
        end

      {dir, nb}
    end
  end

  def get_min_max(map) do
    min_x = map |> Enum.map(fn {{x, _}, _} -> x end) |> Enum.min()
    max_x = map |> Enum.map(fn {{x, _}, _} -> x end) |> Enum.max()
    min_y = map |> Enum.map(fn {{_, y}, _} -> y end) |> Enum.min()
    max_y = map |> Enum.map(fn {{_, y}, _} -> y end) |> Enum.max()
    {{min_x, min_y}, {max_x, max_y}}
  end

  def map_to_array(map) do
    {{min_x, min_y}, {max_x, max_y}} = get_min_max(map)

    arr =
      for y <- max_y..min_y do
        for x <- min_x..max_x do
          case Map.get(map, {x, y}) do
            nil -> ?.
            ?O -> ?O
            _ -> ?#
          end
        end
      end

    {arr, {min_x, min_y}, {max_x, max_y}}
  end

  def color(map, points) do
    if Enum.count(points) == 0 do
      map
    else
      new_points =
        for {x, y} <- points do
          [
            {x + 1, y},
            {x - 1, y},
            {x, y + 1},
            {x, y - 1}
          ]
        end
        |> List.flatten()
        |> Enum.filter(fn {x, y} -> Map.get(map, {x, y}) == nil end)
        |> Enum.uniq()

      map =
        Enum.reduce(points, map, fn pt, map ->
          Map.put(map, pt, ?O)
        end)

      color(map, new_points)
    end
  end

  def pp_array(arr) do
    for line <- arr do
      IO.puts(line)
    end
  end

  def run(filename) do
    lines = parse_file(filename)
    map = %{}
    start = {0, 0}

    {_, map} =
      lines
      |> Enum.reduce({start, map}, fn {dir, nb}, {{x, y}, map} ->
        case dir do
          :r ->
            map = 1..nb |> Enum.reduce(map, fn i, map -> Map.put(map, {x + i, y}, ?#) end)
            {{x + nb, y}, map}

          :l ->
            map = 1..nb |> Enum.reduce(map, fn i, map -> Map.put(map, {x - i, y}, ?#) end)
            {{x - nb, y}, map}

          :u ->
            map = 1..nb |> Enum.reduce(map, fn i, map -> Map.put(map, {x, y + i}, ?#) end)
            {{x, y + nb}, map}

          :d ->
            map = 1..nb |> Enum.reduce(map, fn i, map -> Map.put(map, {x, y - i}, ?#) end)
            {{x, y - nb}, map}
        end
      end)

    {arr, {min_x, min_y}, {max_x, _max_y}} = map_to_array(map)
    # lets find the top left corner of the shape
    first_x = min_x..max_x |> Enum.find(fn x -> Map.get(map, {x, min_y}) != nil end)
    point_start = {first_x + 1, min_y + 1}
    pp_array(arr)
    map = color(map, [point_start])

    IO.puts("")
    {arr, _, _} = map_to_array(map)
    pp_array(arr)

    nb = map |> Enum.count()
    IO.inspect(nb, label: "[DDA] nb")
  end
end

defmodule P2 do
  def parse_file(filename) do
    for line <- File.read!(filename) |> String.split("\n", trim: true) do
      [_, _, rest] = String.split(line, " ", trim: true)
      nb = String.slice(rest, 2, 5)
      nb = Integer.parse(nb, 16) |> elem(0)
      dir = String.slice(rest, 7, 1)

      dir =
        case dir do
          "0" -> :r
          "1" -> :d
          "2" -> :l
          "3" -> :u
        end

      {dir, nb}
    end
  end

  def run(filename) do
    lines = parse_file(filename)

    {_, vertices} =
      for {dir, nb} <- lines, reduce: {{0, 0}, []} do
        {{x, y}, arr} ->
          pt =
            case dir do
              :r -> {x + nb, y}
              :l -> {x - nb, y}
              :u -> {x, y + nb}
              :d -> {x, y - nb}
            end

          {pt, [pt | arr]}
      end

    # shoelace formula
    inside_area =
      vertices
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [{x1, y1}, {x2, y2}] -> x1 * y2 - x2 * y1 end)
      |> Enum.sum()
      |> div(2)
      |> abs()

    border = lines |> Enum.map(fn {_, nb} -> nb end) |> Enum.sum()

    IO.inspect(inside_area + div(border, 2) + 1, label: "[DDA] inside_area + border")
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
