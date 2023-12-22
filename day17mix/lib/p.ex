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
      line |> String.split("", trim: true) |> Enum.map(&String.to_integer/1)
    end
  end

  # return :wall | val
  def at(blocks, {x, y}) do
    w = Cache.get(:w)
    h = Cache.get(:h)

    if x < 0 || y < 0 || x >= w || y >= h do
      :wall
    else
      blocks |> Enum.at(y) |> Enum.at(x)
    end
  end

  def mv({x, y}, :up), do: {x, y - 1}
  def mv({x, y}, :down), do: {x, y + 1}
  def mv({x, y}, :left), do: {x - 1, y}
  def mv({x, y}, :right), do: {x + 1, y}

  # return list of [{p, dirs}]
  # d1 = direction we are coming from
  def nx_potential_points(p0, {d1, d2, d3}) do
    other_dirs =
      case d1 do
        nil -> [:left, :right, :up, :down]
        :left -> [:up, :down]
        :right -> [:up, :down]
        :up -> [:left, :right]
        :down -> [:left, :right]
      end

    next_dirs =
      if d1 == nil || (d1 == d2 and d2 == d3) do
        # we have to move 90 degrees
        other_dirs
      else
        # we can go anywhere, except where we are coming from
        [d1 | other_dirs]
      end

    next_dirs
    |> Enum.map(fn d -> {mv(p0, d), {d, d1, d2}} end)
  end

  def nx_round(blocks, {p0, dirs0, cost0, visited0}) do
    nx_potential_points(p0, dirs0)
    |> Enum.filter(fn {p1, _} -> !MapSet.member?(visited0, p1) && at(blocks, p1) != :wall end)
    |> Enum.map(fn {p1, dirs1} ->
      {p1, dirs1, cost0 + at(blocks, p1), MapSet.put(visited0, p1)}
    end)
  end

  def bfs(blocks, dest, min_cost, nx0, costs, step) do
    IO.inspect({step, min_cost, Enum.count(nx0)}, label: "[DDA] step, min_cost, count")

    nx1 =
      nx0
      |> Enum.flat_map(&nx_round(blocks, &1))
      |> Enum.filter(fn {p0, _, _, _} ->
        if Map.get(costs, p0) == nil do
          true
        else
          # we have already gotten here
        end

        p1 != dest
      end)

    {min_cost, nx1} =
      nx1
      |> Enum.reduce({min_cost, []}, fn {p0, _, cost0, _} = info, {min_cost, acc} ->
        if p0 == dest do
          if cost0 < min_cost do
            # new min cost and we stop
            {cost0, acc}
          else
            {min_cost, acc}
          end
        else
          {min_cost, [info | acc]}
        end
      end)

    nx1 = nx1 |> Enum.filter(fn {_, _, cost0, _} -> cost0 < min_cost end)

    if nx1 == [] do
      min_cost
    else
      bfs(blocks, dest, min_cost, nx1, costs, step + 1)
    end
  end

  def dfs(blocks, dest, min_cost, {p0, dirs, cost0, _} = info0, step) do
    key = {:cost, p0, :dirs, dirs}

    case Cache.get(key) do
      nil ->
        Cache.put(key, cost0)
        _dfs(blocks, dest, min_cost, info0, step)

      cost_at_point ->
        if cost_at_point <= cost0 do
          # we have already been here with a lower cost
          min_cost
        else
          Cache.put(key, cost0)
          _dfs(blocks, dest, min_cost, info0, step)
        end
    end
  end

  def _dfs(blocks, dest, min_cost, {p0, _, cost0, _} = info0, step) do
    cond do
      cost0 >= min_cost ->
        min_cost

      p0 == dest ->
        if rem(min_cost, 1000) == 0 do
          IO.inspect("[DDA] found exit cost #{cost0}, min_cost #{min_cost}, step #{step}")
        end

        min(cost0, min_cost)

      true ->
        nxs = nx_round(blocks, info0)

        if nxs == [] do
          # we are done
          min_cost
        else
          nxs
          |> Enum.reduce(min_cost, fn info1, min_cost ->
            min_cost1 = dfs(blocks, dest, min_cost, info1, step + 1)
            min(min_cost1, min_cost)
          end)
        end
    end
  end

  def run_dfs(filename) do
    blocks = parse_file(filename)
    h = blocks |> Enum.count()
    w = Enum.at(blocks, 0) |> Enum.count()
    Cache.put(:h, h)
    Cache.put(:w, w)

    start = {0, 0}
    dest = {w - 1, h - 1}
    min_cost = 1_000_000_000

    res =
      dfs(blocks, dest, min_cost, {start, {nil, nil, nil}, 0, MapSet.new([start])}, 0)

    IO.inspect(res, label: "[DDA] dfs")
  end

  def run_bfs(filename) do
    blocks = parse_file(filename)
    h = blocks |> Enum.count()
    w = Enum.at(blocks, 0) |> Enum.count()
    Cache.put(:h, h)
    Cache.put(:w, w)

    start = {0, 0}
    dest = {w - 1, h - 1}
    min_cost = 1_000_000_000

    res =
      bfs(blocks, dest, min_cost, [{start, {nil, nil, nil}, 0, MapSet.new([start])}], %{}, 0)

    IO.inspect(res, label: "[DDA] bfs")
  end
end

defmodule P2 do
  # def run(filename) do
  #   blocks = P1.parse_file(filename)
  #   w = blocks |> Enum.count()
  #   h = Enum.at(blocks, 0) |> Enum.count()
  #   Cache.put(:h, h)
  #   Cache.put(:w, w)

  #   top = for x <- 0..(w - 1), do: {{x, -1}, :down}
  #   bottom = for x <- 0..(w - 1), do: {{x, h}, :up}
  #   left = for y <- 0..(h - 1), do: {{-1, y}, :down}
  #   rigth = for y <- 0..(h - 1), do: {{w, y}, :up}

  #   (top ++ bottom ++ left ++ rigth)
  #   |> Enum.map(fn {p0, dir} -> P1.solve_for(blocks, p0, dir) end)
  #   |> Enum.max()
  #   |> IO.inspect(label: "[DDA] max")
  # end
end

Cache.setup()
# P1.run_dfs("sample.txt")
P1.run_bfs("sample.txt")
# P1.run("input.txt")
# P2.run("sample.txt")
# P2.run("input.txt")
