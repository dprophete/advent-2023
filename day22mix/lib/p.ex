#!/usr/bin/env elixir

# DSL:

defmodule P1 do
  # --------------------------------------------------------------------------------
  # - parsing
  # --------------------------------------------------------------------------------

  def sort({x1, x2}) do
    if x1 < x2, do: {x1, x2}, else: {x2, x1}
  end

  def range({x1, x2}), do: x1..x2

  def expand_brick({x1, y1, z1}, {x2, y2, z2}) do
    cond do
      x1 != x2 -> for x <- range(sort({x1, x2})), do: {x, y1, z1}
      y1 != y2 -> for y <- range(sort({y1, y2})), do: {x1, y, z1}
      z1 != z2 -> for z <- range(sort({z1, z2})), do: {x1, y1, z}
      true -> [{x1, y1, z1}]
    end
  end

  def parse_file(filename) do
    for {line, idx} <-
          File.read!(filename) |> String.split("\n", trim: true) |> Enum.with_index(),
        into: %{} do
      [lhs, rhs] = String.split(line, "~")
      [x1, y1, z1] = String.split(lhs, ",") |> Enum.map(&String.to_integer/1)
      [x2, y2, z2] = String.split(rhs, ",") |> Enum.map(&String.to_integer/1)
      {idx, expand_brick({x1, y1, z1}, {x2, y2, z2})}
    end
  end

  # --------------------------------------------------------------------------------
  # - pp
  # --------------------------------------------------------------------------------

  def format(x) when x < 10, do: " #{x}"
  def format(x), do: "#{x}"

  def size(space) do
    min_x = space |> Enum.map(fn {{x, _, _}, _} -> x end) |> Enum.min()
    max_x = space |> Enum.map(fn {{x, _, _}, _} -> x end) |> Enum.max()
    min_y = space |> Enum.map(fn {{_, y, _}, _} -> y end) |> Enum.min()
    max_y = space |> Enum.map(fn {{_, y, _}, _} -> y end) |> Enum.max()
    min_z = space |> Enum.map(fn {{_, _, z}, _} -> z end) |> Enum.min()
    max_z = space |> Enum.map(fn {{_, _, z}, _} -> z end) |> Enum.max()
    {{min_x, max_x}, {min_y, max_y}, {min_z, max_z}}
  end

  def visualize_space_y(space) do
    {{min_x, max_x}, {min_y, max_y}, {_min_z, max_z}} = size(space)

    IO.write("\n  x ")
    for x <- min_x..max_x, do: IO.write("#{format(x)} ")
    IO.puts("")
    IO.write(" z+-")
    for _x <- min_x..max_x, do: IO.write("---")
    IO.puts("")

    for z <- max_z..1 do
      IO.write("#{format(z)}| ")

      for x <- min_x..max_x do
        case Enum.filter(min_y..max_y, fn y -> Map.get(space, {x, y, z}) != nil end) do
          [] ->
            IO.write(" . ")

          [y] ->
            IO.write("#{format(Map.get(space, {x, y, z}))} ")

          [y | rest] ->
            first = Map.get(space, {x, y, z})

            case Enum.all?(rest, fn y1 -> Map.get(space, {x, y1, z}) == first end) do
              true -> IO.write("#{format(Map.get(space, {x, y, z}))}*")
              false -> IO.write("#{format(Map.get(space, {x, y, z}))}?")
            end
        end
      end

      IO.puts("")
    end

    IO.puts("")
  end

  def visualize_space_x(space) do
    {{min_x, max_x}, {min_y, max_y}, {_min_z, max_z}} = size(space)

    IO.write("  y ")
    for y <- min_y..max_y, do: IO.write("#{format(y)} ")
    IO.puts("")
    IO.write(" z+-")
    for _x <- min_y..max_y, do: IO.write("---")
    IO.puts("")

    for z <- max_z..1 do
      IO.write("#{format(z)}| ")

      for y <- min_y..max_y do
        case Enum.filter(min_x..max_x, fn x -> Map.get(space, {x, y, z}) != nil end) do
          [] ->
            IO.write(" . ")

          [x] ->
            IO.write("#{format(Map.get(space, {x, y, z}))} ")

          [x | rest] ->
            first = Map.get(space, {x, y, z})

            case Enum.all?(rest, fn x1 -> Map.get(space, {x1, y, z}) == first end) do
              true -> IO.write("#{format(Map.get(space, {x, y, z}))}*")
              false -> IO.write("#{format(Map.get(space, {x, y, z}))}?")
            end
        end
      end

      IO.puts("")
    end

    IO.puts("")
  end

  # --------------------------------------------------------------------------------
  # - running
  # --------------------------------------------------------------------------------

  # return set of bricks supported by this brick
  def bricks_for_space(space) do
    space
    |> Enum.to_list()
    |> Enum.group_by(fn {_, idx} -> idx end, fn {cube, _} -> cube end)
  end

  def space_for_bricks(bricks) do
    for {idx, brick} <- bricks, {x, y, z} <- brick, into: %{} do
      {{x, y, z}, idx}
    end
  end

  def can_fall?(space, {idx, cubes}) do
    Enum.all?(cubes, fn {x, y, z} ->
      if z == 1 do
        false
      else
        under = Map.get(space, {x, y, z - 1})
        under == nil || under == idx
      end
    end)
  end

  def lower_cube({x, y, z}), do: {x, y, z - 1}

  def fall(bricks) do
    space = space_for_bricks(bricks)

    falling = bricks |> Enum.filter(&can_fall?(space, &1))

    if falling == [] do
      bricks
    else
      for {idx, cubes} <- falling, reduce: bricks do
        bricks ->
          Map.put(bricks, idx, Enum.map(cubes, &lower_cube/1))
      end
      |> fall()
    end
  end

  def can_be_desintegrated(bricks, idx) do
    # let's remove the brick and see if anything falls
    bricks = bricks |> Map.delete(idx)
    space = space_for_bricks(bricks)
    falling = bricks |> Enum.filter(&can_fall?(space, &1))
    falling == []
  end

  def run(filename) do
    bricks = parse_file(filename)

    space = space_for_bricks(bricks)

    IO.inspect("[DDA] == orignal ===")
    visualize_space_y(space)
    visualize_space_x(space)

    IO.inspect("[DDA] == after falling ===")
    bricks = fall(bricks)
    space = space_for_bricks(bricks)
    visualize_space_y(space)
    visualize_space_x(space)

    IO.inspect("[DDA] == can be desintegrated ===")

    bricks
    |> Enum.map(fn {idx, _brick} -> idx end)
    |> Enum.filter(&can_be_desintegrated(bricks, &1))
    |> Enum.count()
    |> IO.inspect()
  end
end

defmodule P2 do
end

defmodule P do
  def start() do
    Cache.setup()
    # P1.run("sample.txt")
    P1.run("input.txt")
  end
end
