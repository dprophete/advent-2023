#!/usr/bin/env elixir

defmodule P1 do
  @max_dist 1_000_000_000

  def dijkstra_pq(blocks, {s_x, s_y}, {d_x, d_y}) do
    h = blocks |> Enum.count()
    w = Enum.at(blocks, 0) |> Enum.count()
    Cache.put(:h, h)
    Cache.put(:w, w)

    nodes =
      for y <- 0..(h - 1) do
        for x <- 0..(w - 1) do
          {x, y, {nil, nil, nil}}
        end
      end
      |> Enum.concat()

    source = {s_x, s_y, {nil, nil, nil}}

    # all distances are set to infinity initally
    distances = for node <- nodes, into: %{}, do: {node, @max_dist}
    distances = Map.put(distances, source, 0)

    unvisited = Heap.new(fn {_, d1}, {_, d2} -> d1 < d2 end)
    unvisited = Heap.push(unvisited, {source, 0})

    distances = dijkstra_pq_inner(blocks, unvisited, distances)

    distances
    |> Map.filter(fn {{x, y, _}, _} -> {x, y} == {d_x, d_y} end)
    |> Map.values()
    |> Enum.min()
  end

  defp dijkstra_pq_inner(blocks, unvisited, distances) do
    if Heap.empty?(unvisited) do
      distances
    else
      {current_nd, current_dist} = Heap.root(unvisited)
      unvisited = Heap.pop(unvisited)

      if current_dist > Map.get(distances, current_nd) do
        dijkstra_pq_inner(blocks, unvisited, distances)
      else
        {unvisited, distances} =
          P1.full_connections_for_point(blocks, current_nd)
          |> Enum.reduce({unvisited, distances}, fn {neighboor, weight}, {unvisited, distances} ->
            dist_neighboor = current_dist + weight

            if dist_neighboor < Map.get(distances, neighboor) do
              {
                Heap.push(unvisited, {neighboor, dist_neighboor}),
                Map.put(distances, neighboor, dist_neighboor)
              }
            else
              {unvisited, distances}
            end
          end)

        dijkstra_pq_inner(blocks, unvisited, distances)
      end
    end
  end

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
  def op(nil), do: :nonnil

  def is_valid({d1, d2, d3}) do
    d1 != op(d2) && d2 != op(d3)
  end

  def full_connections_for_point(blocks, {x, y, {d1, d2, d3}}) do
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

  def connections_for_point(blocks, {x, y}) do
    for d <- [:le, :ri, :up, :dn] do
      {x1, y1} = mv({x, y}, d)
      val = at(blocks, {x1, y1})

      cond do
        val == :wall -> nil
        true -> {{x1, y1}, val}
      end
    end
    |> Enum.reject(&is_nil/1)
  end

  def run(filename) do
    blocks = parse_file(filename)
    h = blocks |> Enum.count()
    w = Enum.at(blocks, 0) |> Enum.count()
    Cache.put(:h, h)
    Cache.put(:w, w)

    source = {0, 0}
    dest = {w - 1, h - 1}

    dijkstra_pq(blocks, source, dest)
    |> IO.inspect(label: "graph: dist start -> dest")
  end
end

defmodule P2 do
  @max_dist 1_000_000_000

  def dijkstra_pq(blocks, {s_x, s_y}, {d_x, d_y}) do
    h = blocks |> Enum.count()
    w = Enum.at(blocks, 0) |> Enum.count()
    Cache.put(:h, h)
    Cache.put(:w, w)

    nodes =
      for y <- 0..(h - 1) do
        for x <- 0..(w - 1) do
          {x, y, {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil}}
        end
      end
      |> Enum.concat()

    source = {s_x, s_y, {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil}}

    # all distances are set to infinity initally
    distances = for node <- nodes, into: %{}, do: {node, @max_dist}
    distances = Map.put(distances, source, 0)

    unvisited = Heap.new(fn {_, d1}, {_, d2} -> d1 < d2 end)
    unvisited = Heap.push(unvisited, {source, 0})

    distances = dijkstra_pq_inner(blocks, unvisited, distances)

    distances
    |> Map.filter(fn {{x, y, _}, _} -> {x, y} == {d_x, d_y} end)
    |> Map.values()
    |> Enum.min()
  end

  defp dijkstra_pq_inner(blocks, unvisited, distances) do
    if Heap.empty?(unvisited) do
      distances
    else
      {current_nd, current_dist} = Heap.root(unvisited)
      unvisited = Heap.pop(unvisited)

      if current_dist > Map.get(distances, current_nd) do
        dijkstra_pq_inner(blocks, unvisited, distances)
      else
        {unvisited, distances} =
          full_connections_for_point(blocks, current_nd)
          |> Enum.reduce({unvisited, distances}, fn {neighboor, weight}, {unvisited, distances} ->
            dist_neighboor = current_dist + weight

            if dist_neighboor < Map.get(distances, neighboor) do
              {
                Heap.push(unvisited, {neighboor, dist_neighboor}),
                Map.put(distances, neighboor, dist_neighboor)
              }
            else
              {unvisited, distances}
            end
          end)

        dijkstra_pq_inner(blocks, unvisited, distances)
      end
    end
  end

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
  def op(_), do: :nothing

  def full_connections_for_point(blocks, {x, y, {d1, d2, d3, d4, d5, d6, d7, d8, d9, d10}}) do
    for d11 <- [:le, :ri, :up, :dn] do
      {x1, y1} = P1.mv({x, y}, d11)
      val = P1.at(blocks, {x1, y1})
      dirs = {d2, d3, d4, d5, d6, d7, d8, d9, d10, d11}

      cond do
        val == :wall ->
          nil

        d10 == op(d11) ->
          nil

        !(d10 == d11 || (d10 != d11 && (d7 == d8 && d8 == d9 && d9 == d10))) ->
          nil

        # can't have 11 in a row
        {d1, d2, d3, d4, d5, d6, d7, d8, d9, d10} == {d2, d3, d4, d5, d6, d7, d8, d9, d10, d11} ->
          nil

        true ->
          {{x1, y1, dirs}, val}
      end
    end
    |> Enum.reject(&is_nil/1)
  end

  def connections_for_point(blocks, {x, y}) do
    for d <- [:le, :ri, :up, :dn] do
      {x1, y1} = mv({x, y}, d)
      val = at(blocks, {x1, y1})

      cond do
        val == :wall -> nil
        true -> {{x1, y1}, val}
      end
    end
    |> Enum.reject(&is_nil/1)
  end

  def run(filename) do
    blocks = parse_file(filename)
    h = blocks |> Enum.count()
    w = Enum.at(blocks, 0) |> Enum.count()
    Cache.put(:h, h)
    Cache.put(:w, w)

    source = {0, 0}
    dest = {w - 1, h - 1}

    dijkstra_pq(blocks, source, dest)
    |> IO.inspect(label: "graph: dist start -> dest")
  end
end

defmodule P do
  def start() do
    Cache.setup()
    # P1.run("sample.txt")
    # P1.run("input.txt")

    # P2.run("sample.txt")
    # P2.run("sample0.txt")
    P2.run("input.txt")
  end
end
