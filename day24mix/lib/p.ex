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
  def parralels?({vx1, vy1, vz1}, {vx2, vy2, vz2}) do
    abs(vx1 * vy2 - vy1 * vx2) < 1.0 && abs(vx1 * vz2 - vz1 * vx2) < 1.0 &&
      abs(vy1 * vz2 - vz1 * vy2) < 1.0
  end

  def base_distance({x1, y1, z1}, {x2, y2, z2}) do
    abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)
  end

  def throw_rock(lines, idx1, idx2, idx3) do
    # note: with 2 non skew lines, we have an infinity of lines which intersect both
    # but with a 3rd non skew line, we only have 1 line with croess everything (seems intuitive, haven't provved it)
    # so we should be able to solve this by only considering the first 3 lines
    # (if we have 2 parrallel lines, we can just use another line)
    #
    # rock: p + t * v (p = {px, py, pz}, v = {vx, vy, vz})
    # ray-i = pi + t * vi (pi = {pix, piy, piz}, vi = {vix, viy, viz}))
    #
    # they collide at ti: p + ti * v = pi + ti * vi
    #   => p - pi = ti * (vi - v)
    #   => ti = (p - pi) / (vi - v)  (assuming vi != v)
    #
    # we can remove ti, by projecting on xyz
    #   (px - pix) / (vix - vx) = (py - piy) / (viy - vy) = (pz - piz) / (viz - vz)
    #
    # considering px/py, we have:
    #   (px - pix) * (viy - vy) = (py - piy) * (vix - vx)
    #   => px*viy - px*vy - pix*viy + pix*vy = py*vix - py*vx - piy*vix + piy*vx
    #   => (px*viy - py*vix) + (pix*vy - piy*vx) + (piy*vix - pix*viy) = px*vy - py*vx
    #
    # the right hand side doesn't depend on i, so if we call eq-i the left hand side, we have: eq1 = eq2 = eq3
    #
    # eq1 = eq2: (px*v1y - py*v1x) + (p1x*vy - p1y*vx) + (p1y*v1x - p1x*v1y) = (px*v2y - py*v2x) + (p2x*vy - p2y*vx) + (p2y*v2x - p2x*v2y)
    #   => px*(v1y - v2y) + py*(v2x - v1x) + vx*(p2y - p1y) + vy*(p1x - p2x) = (p2y*v2x - p2x*v2y) - (p1y*v1x - p1x*v1y)
    # and with eq1 = eq3
    #   => px*(v1y - v3y) + py*(v3x - v1x) + vx*(p3y - p1y) + vy*(p1x - p3x) = (p3y*v3x - p3x*v3y) - (p1y*v1x - p1x*v1y)
    #
    # now by considering px/pz, we have:
    #   => px*(v1z - v2z) + pz*(v2x - v1x) + vx*(p2z - p1z) + vz*(p1x - p2x) = (p2z*v2x - p2x*v2z) - (p1z*v1x - p1x*v1z)
    #   => px*(v1z - v3z) + pz*(v3x - v1x) + vx*(p3z - p1z) + vz*(p1x - p3x) = (p3z*v3x - p3x*v3z) - (p1z*v1x - p1x*v1z)
    #
    # and considering pz/py, we have:
    #   => pz*(v1y - v2y) + py*(v2z - v1z) + vz*(p2y - p1y) + vy*(p1z - p2z) = (p2y*v2z - p2z*v2y) - (p1y*v1z - p1z*v1y)
    #   => pz*(v1y - v3y) + py*(v3z - v1z) + vz*(p3y - p1y) + vy*(p1z - p3z) = (p3y*v3z - p3z*v3y) - (p1y*v1z - p1z*v1y)
    #
    # that gives us 6 linear equations with 6 unknowns (px, py, pz, vx, vy, vz)

    # IO.inspect("[DDA] --- throw_rock for #{idx1}, #{idx2}, #{idx3}")
    line1 = Enum.at(lines, idx1)
    line2 = Enum.at(lines, idx2)
    line3 = Enum.at(lines, idx3)
    {{p1x, p1y, p1z}, v1 = {v1x, v1y, v1z}} = line1
    {{p2x, p2y, p2z}, v2 = {v2x, v2y, v2z}} = line2
    {{p3x, p3y, p3z}, v3 = {v3x, v3y, v3z}} = line3

    if parralels?(v1, v2) || parralels?(v1, v3) || parralels?(v2, v3) do
      nil
    else
      # IO.inspect("[DDA] parralels? 1 // 2 #{parralels?(elem(line1, 1), elem(line2, 1))}")
      # IO.inspect("[DDA] parralels? 1 // 3 #{parralels?(elem(line1, 1), elem(line3, 1))}")
      # IO.inspect("[DDA] parralels? 2 // 3 #{parralels?(elem(line2, 1), elem(line3, 1))}")

      # we will use:
      #
      # M = [[m11, m12, m13, m14, m15, m16],
      #      [m21, m22, m23, m24, m25, m26],
      #      [m31, m32, m33, m34, m35, m36],
      #      [m41, m42, m43, m44, m45, m46],
      #      [m51, m52, m53, m54, m55, m56],
      #      [m61, m62, m63, m64, m65, m66]]
      #
      # V = [px, py, pz, vx, vy, vz]
      # A = [a1, a2, a3, a4, a5, a6]
      # and resolve: M * V = A => V = M^-1 * A
      #
      # so you 6 equations are:
      #  px*(v1y - v2y) + py*(v2x - v1x) + vx*(p2y - p1y) + vy*(p1x - p2x) = (p2y*v2x - p2x*v2y) - (p1y*v1x - p1x*v1y)
      #  px*(v1y - v3y) + py*(v3x - v1x) + vx*(p3y - p1y) + vy*(p1x - p3x) = (p3y*v3x - p3x*v3y) - (p1y*v1x - p1x*v1y)
      #  px*(v1z - v2z) + pz*(v2x - v1x) + vx*(p2z - p1z) + vz*(p1x - p2x) = (p2z*v2x - p2x*v2z) - (p1z*v1x - p1x*v1z)
      #  px*(v1z - v3z) + pz*(v3x - v1x) + vx*(p3z - p1z) + vz*(p1x - p3x) = (p3z*v3x - p3x*v3z) - (p1z*v1x - p1x*v1z)
      #  pz*(v1y - v2y) + py*(v2z - v1z) + vz*(p2y - p1y) + vy*(p1z - p2z) = (p2y*v2z - p2z*v2y) - (p1y*v1z - p1z*v1y)
      #  pz*(v1y - v3y) + py*(v3z - v1z) + vz*(p3y - p1y) + vy*(p1z - p3z) = (p3y*v3z - p3z*v3y) - (p1y*v1z - p1z*v1y)
      #
      # rewritten to be rectangular:
      #  px*(v1y - v2y) + py*(v2x - v1x) + pz*0           + vx*(p2y - p1y) + vy*(p1x - p2x) + vz*0           = (p2y*v2x - p2x*v2y) - (p1y*v1x - p1x*v1y)
      #  px*(v1y - v3y) + py*(v3x - v1x) + pz*0           + vx*(p3y - p1y) + vy*(p1x - p3x) + vz*0           = (p3y*v3x - p3x*v3y) - (p1y*v1x - p1x*v1y)
      #  px*(v1z - v2z) + py*0           + pz*(v2x - v1x) + vx*(p2z - p1z) + vy*0           + vz*(p1x - p2x) = (p2z*v2x - p2x*v2z) - (p1z*v1x - p1x*v1z)
      #  px*(v1z - v3z) + py*0           + pz*(v3x - v1x) + vx*(p3z - p1z) + vy*0           + vz*(p1x - p3x) = (p3z*v3x - p3x*v3z) - (p1z*v1x - p1x*v1z)
      #  px*0           + py*(v2z - v1z) + pz*(v1y - v2y) + vx*0           + vy*(p1z - p2z) + vz*(p2y - p1y) = (p2y*v2z - p2z*v2y) - (p1y*v1z - p1z*v1y)
      #  px*0           + py*(v3z - v1z) + pz*(v1y - v3y) + vx*0           + vy*(p1z - p3z) + vz*(p3y - p1y) = (p3y*v3z - p3z*v3y) - (p1y*v1z - p1z*v1y)
      a1 = p2y * v2x - p2x * v2y - (p1y * v1x - p1x * v1y)
      a2 = p3y * v3x - p3x * v3y - (p1y * v1x - p1x * v1y)
      a3 = p2z * v2x - p2x * v2z - (p1z * v1x - p1x * v1z)
      a4 = p3z * v3x - p3x * v3z - (p1z * v1x - p1x * v1z)
      a5 = p2y * v2z - p2z * v2y - (p1y * v1z - p1z * v1y)
      a6 = p3y * v3z - p3z * v3y - (p1y * v1z - p1z * v1y)

      row1 = [v1y - v2y, v2x - v1x, 0, p2y - p1y, p1x - p2x, 0]
      row2 = [v1y - v3y, v3x - v1x, 0, p3y - p1y, p1x - p3x, 0]
      row3 = [v1z - v2z, 0, v2x - v1x, p2z - p1z, 0, p1x - p2x]
      row4 = [v1z - v3z, 0, v3x - v1x, p3z - p1z, 0, p1x - p3x]
      row5 = [0, v2z - v1z, v1y - v2y, 0, p1z - p2z, p2y - p1y]
      row6 = [0, v3z - v1z, v1y - v3y, 0, p1z - p3z, p3y - p1y]

      m = [row1, row2, row3, row4, row5, row6]
      a = [[a1], [a2], [a3], [a4], [a5], [a6]]

      invM = Matrix.inv(m)
      v = Matrix.mult(invM, a)
      [px, py, pz, vx, vy, vz] = Enum.map(v, fn [i] -> i end)
      t1 = (px - p1x) / (v1x - vx)
      t2 = (px - p2x) / (v2x - vx)
      t3 = (px - p3x) / (v3x - vx)
      p = {px, py, pz}
      v = {vx, vy, vz}

      # let's look at how far we are really from the intersection
      # because of rounding errors, this could get quite large
      rock1_int = {px + t1 * vx, py + t1 * vy, pz + t1 * vz}
      p1_int = {p1x + t1 * v1x, p1y + t1 * v1y, p1z + t1 * v1z}
      dist1 = base_distance(rock1_int, p1_int)

      rock2_int = {px + t2 * vx, py + t2 * vy, pz + t2 * vz}
      p2_int = {p2x + t2 * v2x, p2y + t2 * v2y, p2z + t2 * v2z}
      dist2 = base_distance(rock2_int, p2_int)

      rock3_int = {px + t3 * vx, py + t3 * vy, pz + t3 * vz}
      p3_int = {p3x + t3 * v3x, p3y + t3 * v3y, p3z + t3 * v3z}
      dist3 = base_distance(rock3_int, p3_int)

      {p, v, {t1, t2, t3}, {dist1, dist2, dist3}}
    end
  end

  def is_int(x) do
    abs(round(x) - x) < 0.01
  end

  def run(filename) do
    lines = P1.parse_file(filename)
    nb_lines = Enum.count(lines)
    # IO.inspect(lines, label: "[DDA] lines")

    {dist, {px, py, pz}} =
      for idx1 <- 0..(nb_lines - 1),
          idx2 <- 0..(nb_lines - 1),
          idx3 <- 0..(nb_lines - 1),
          idx1 < idx2,
          idx2 < idx3,
          reduce: {1_000_000_000, {0, 0, 0}} do
        {dist0, p0} ->
          case throw_rock(lines, idx1, idx2, idx3) do
            nil ->
              {dist0, p0}

            {{px, py, pz} = p, _v, {t1, t2, t3}, {dist1, dist2, dist3}} ->
              if t1 < 0 || t2 < 0 || t3 < 0 do
                {dist0, p0}
              else
                dist = dist1 + dist2 + dist3

                if dist < dist0 do
                  IO.inspect(
                    "[DDA] new potential solution: #{px + py + pz} with a dist of #{dist}"
                  )

                  {dist, p}
                else
                  {dist0, p0}
                end
              end
          end
      end

    IO.puts("[DDA] solution: #{px + py + pz} with a dist of #{dist}")
  end
end

defmodule P do
  def start() do
    Cache.setup()
    # P1.run("sample.txt", 7, 21)
    # P1.run("input.txt", 200_000_000_000_000, 400_000_000_000_000)
    # P2.run("sample.txt")
    P2.run("input.txt")
  end
end
