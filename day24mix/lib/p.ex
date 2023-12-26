#!/usr/bin/env elixir

# DSL:

defmodule P1 do
  # --------------------------------------------------------------------------------
  # - parsing
  # --------------------------------------------------------------------------------

  def parse_file(filename) do
    for line <- File.read!(filename) |> String.split("\n", trim: true) do
      [pos, vel] = String.split(line, " @ ")

      [x0, y0, z0] =
        String.split(pos, ", ") |> Enum.map(&String.trim/1) |> Enum.map(&String.to_integer/1)

      [vx, vy, vz] =
        String.split(vel, ", ") |> Enum.map(&String.trim/1) |> Enum.map(&String.to_integer/1)

      {{x0, y0, z0}, {vx, vy, vz}}
    end
  end

  # --------------------------------------------------------------------------------
  # - pp
  # --------------------------------------------------------------------------------

  # --------------------------------------------------------------------------------
  # - running
  # --------------------------------------------------------------------------------

  # convert to ax + by + c = 0
  def convert_to_abc({{x0, y0, _z}, {vx, vy, _vz}}) do
    a = vy
    b = -vx
    c = vx * y0 - vy * x0

    {a, b, c}
  end

  def intersection({a1, b1, c1}, {a2, b2, c2}) do
    d = a1 * b2 - a2 * b1

    if d == 0 do
      nil
    else
      x = (b1 * c2 - b2 * c1) / d
      y = (a2 * c1 - a1 * c2) / d

      {x, y}
    end
  end

  def run(filename, min_xy, max_xy) do
    lines0 = parse_file(filename)
    lines1 = lines0 |> Enum.map(&convert_to_abc/1)

    intersections =
      for {l1, idx1} <- Enum.with_index(lines1),
          {l2, idx2} <- Enum.with_index(lines1),
          idx1 < idx2,
          do: {{idx1, idx2}, intersection(l1, l2)}

    intersections =
      intersections |> Enum.filter(fn {_, i} -> i != nil end)

    intersections
    |> Enum.filter(fn {{idx1, idx2}, {ix, iy}} ->
      {{x1, _y1, _z1}, {vx1, _vy1, _vz1}} = Enum.at(lines0, idx1)
      {{x2, _y2, _z2}, {vx2, _vy2, _vz2}} = Enum.at(lines0, idx2)
      t1x = (ix - x1) / vx1
      t2x = (ix - x2) / vx2
      # t1y = (iy - y1) / vy1
      # t2y = (iy - y2) / vy2
      # IO.puts("t1x: #{t1x}, t2x: #{t2x}, t1y: #{t1y}, t2y: #{t2y}")

      ix >= min_xy && iy >= min_xy && ix <= max_xy && iy <= max_xy && t1x >= 0 && t2x >= 0
    end)
    |> Enum.count()
    |> IO.inspect()
  end
end

defmodule P2 do
end

defmodule P do
  def start() do
    Cache.setup()
    # P1.run("sample.txt", 7, 21)
    P1.run("input.txt", 200_000_000_000_000, 400_000_000_000_000)
    # P2.run("sample.txt")
    # P2.run("input.txt")
  end
end
