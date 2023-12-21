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

defmodule GraphSearch do
  @max_dist 1_000_000_000

  # return unvisited node which has the minimum distance
  def min_distance(distances, unvisited) do
    unvisited
    |> Enum.reduce({-1, @max_dist}, fn nd, acc = {_, min_dist} ->
      dist = Map.get(distances, nd)

      if dist < min_dist do
        {nd, dist}
      else
        acc
      end
    end)

    # distances
    # |> Enum.reduce({-1, @max_dist}, fn {nd, dist}, {min_nd, min_dist} ->
    #   if MapSet.member?(unvisited, nd) && dist < min_dist do
    #     {nd, dist}
    #   else
    #     {min_nd, min_dist}
    #   end
    # end)
  end

  def dijkstra2(graph, source, dest) do
    # initialize
    nodes = Map.keys(graph)

    # all distances are set to infinity initally
    distances = for node <- nodes, into: %{}, do: {node, @max_dist}

    unvisited = MapSet.new(nodes)

    # set source distance to 0
    distances = Map.put(distances, source, 0)

    nodes
    |> Enum.reduce_while({distances, unvisited}, fn _, {distances, unvisited} ->
      {min_node, min_dist} = min_distance(distances, unvisited)

      if dest == min_node do
        {:halt, min_dist}
      else
        unvisited = MapSet.delete(unvisited, min_node)

        if rem(Enum.count(unvisited), 1000) == 0 do
          IO.inspect(
            "[DDA] found min #{inspect(min_dist)} for #{inspect(min_node)} (#{Enum.count(unvisited)} to go)"
          )
        end

        # update distances to the adjacent nodes
        dist_min_node = Map.get(distances, min_node)

        distances =
          Map.get(graph, min_node)
          |> Enum.filter(fn {nd, _} -> MapSet.member?(unvisited, nd) end)
          |> Enum.reduce(distances, fn {nd, weight}, distances ->
            dist_nd = Map.get(distances, nd)

            if dist_nd > dist_min_node + weight do
              Map.put(distances, nd, dist_min_node + weight)
            else
              distances
            end
          end)

        {:cont, {distances, unvisited}}
      end
    end)
  end

  def dijkstra(graph, source, dest) do
    # initialize
    nodes = Map.keys(graph)

    # all distances are set to infinity initally
    distances = for node <- nodes, into: %{}, do: {node, @max_dist}

    unvisited = MapSet.new(nodes)

    # set source distance to 0
    distances = Map.put(distances, source, 0)

    nodes
    |> Enum.reduce_while({distances, unvisited}, fn _, {distances, unvisited} ->
      # find node with min distance
      {min_node, min_dist} = min_distance(distances, unvisited)

      if dest == min_node do
        {:halt, min_dist}
      else
        # mark it as visited
        unvisited = MapSet.delete(unvisited, min_node)

        if rem(Enum.count(unvisited), 1000) == 0 do
          IO.inspect(
            "[DDA] found min #{inspect(min_dist)} for #{inspect(min_node)} (#{Enum.count(unvisited)} to go)"
          )
        end

        # update distances to the adjacent nodes
        dist_min_node = Map.get(distances, min_node)

        distances =
          Map.get(graph, min_node)
          |> Enum.reduce(distances, fn {nd, weight}, distances ->
            dist_nd = Map.get(distances, nd)

            if MapSet.member?(unvisited, nd) && dist_nd > dist_min_node + weight do
              Map.put(distances, nd, dist_min_node + weight)
            else
              distances
            end
          end)

        {:cont, {distances, unvisited}}
      end
    end)
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
  def mv({x, y}, :dn), do: {x, y + 1}
  def mv({x, y}, :le), do: {x - 1, y}
  def mv({x, y}, :ri), do: {x + 1, y}

  def op(:le), do: :ri
  def op(:ri), do: :le
  def op(:up), do: :dn
  def op(:dn), do: :up

  def is_valid({d1, d2, d3}) do
    d1 != op(d2) && d2 != op(d3)
  end

  # 1 point -> 36 points
  def expand_point({x, y}) do
    for d1 <- [:le, :ri, :up, :dn],
        d2 <- [:le, :ri, :up, :dn],
        d3 <- [:le, :ri, :up, :dn] do
      potential = {x, y, {d1, d2, d3}}
      if is_valid({d1, d2, d3}), do: potential, else: nil
    end
    |> Enum.reject(&is_nil/1)
  end

  def connections_for_point(blocks, {x, y, {d1, d2, d3}}) do
    for d4 <- [:le, :ri, :up, :dn] do
      {x1, y1} = P1.mv({x, y}, d4)
      val = P1.at(blocks, {x1, y1})
      dirs = {d2, d3, d4}

      cond do
        val == :wall -> nil
        !is_valid(dirs) -> nil
        d1 == d2 && d2 == d3 && d3 == d4 -> nil
        true -> {{x1, y1, dirs}, val}
      end
    end
    |> Enum.reject(&is_nil/1)
  end

  def run(filename) do
    blocks = P1.parse_file(filename)
    h = blocks |> Enum.count()
    w = Enum.at(blocks, 0) |> Enum.count()
    Cache.put(:h, h)
    Cache.put(:w, w)

    start = {0, 0}
    finish = {w - 1, h - 1}

    # build graph for dijkstra
    # dir order: le, ri, up, dn
    graph =
      for y <- 0..(h - 1) do
        for x <- 0..(w - 1) do
          expand_point({x, y})
          |> Enum.map(fn p -> {p, connections_for_point(blocks, p)} end)
        end
      end
      |> Enum.concat()
      |> Enum.concat()
      |> Enum.into(%{})

    pts = graph |> Map.keys()

    # add 'fake connections' to start and finish
    fake_start_conns =
      for pt = {x, y, _} when {x, y} == start <- pts do
        {pt, 0}
      end

    finish_pts =
      for pt = {x, y, _} when {x, y} == finish <- pts do
        pt
      end

    graph =
      graph
      |> Map.put(start, fake_start_conns)
      |> Map.put(finish, [])

    conns_to_finnish = [{finish, 0}]

    graph =
      finish_pts
      |> Enum.reduce(graph, fn pt, graph ->
        graph
        |> Map.update(pt, [], fn conns -> conns ++ conns_to_finnish end)
      end)

    # ([{start, fake_start_conns}, {finish, fake_finish_conns}] ++ conns)
    # |> Enum.into(%{})

    graph
    |> Enum.count()
    |> IO.inspect(label: "graph: nb nodes")

    # GraphSearch.dijkstra(graph, start, finish)
    GraphSearch.dijkstra2(graph, start, finish)
    |> IO.inspect(label: "graph: dist start -> finish")
  end
end

defmodule P2 do
end

Cache.setup()

# P1.run("sample.txt")
# P1.run("input.txt")

# P1.run("sample0.txt")
P1.run("sample.txt")
# P1.run("input.txt")

# P2.run("sample.txt")
# P2.run("input.txt")

# warning: variable "finish" is unused (if the variable is not meant to be used, prefix it with an underscore)
