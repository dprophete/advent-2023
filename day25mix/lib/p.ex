#!/usr/bin/env elixir

# DSL:

defmodule P1 do
  # --------------------------------------------------------------------------------
  # - parsing
  # --------------------------------------------------------------------------------

  def parse_file(filename) do
    for line <- File.read!(filename) |> String.split("\n", trim: true), into: %{} do
      [lhs, rhs] = String.split(line, ": ")
      rhs = String.split(rhs, " ")
      {lhs, MapSet.new(rhs)}
    end
  end

  # --------------------------------------------------------------------------------
  # - pp
  # --------------------------------------------------------------------------------

  # --------------------------------------------------------------------------------
  # - running
  # --------------------------------------------------------------------------------

  def graph_to_conns(graph) do
    for {lhs, rhs} <- graph, rhs <- rhs do
      [{lhs, rhs}, {rhs, lhs}]
    end
    |> List.flatten()
    |> Enum.uniq()
  end

  def conns_to_graph(conns) do
    for {lhs, rhs} <- conns, reduce: %{} do
      graph ->
        Map.update(graph, lhs, MapSet.new([rhs]), fn list -> MapSet.put(list, rhs) end)
    end
  end

  def remove_full_conn(graph, {lhs, rhs}) do
    graph
    |> Map.update(lhs, MapSet.new([]), fn list -> MapSet.delete(list, rhs) end)
    |> Map.update(rhs, MapSet.new([]), fn list -> MapSet.delete(list, lhs) end)
  end

  def ring(graph, node, visited \\ MapSet.new()) do
    visited = MapSet.put(visited, node)
    nxs = Map.get(graph, node)

    nxs = MapSet.difference(nxs, visited)
    visited = MapSet.union(visited, nxs)

    if Enum.empty?(nxs) do
      visited
    else
      for nx <- nxs, reduce: visited do
        visited ->
          ring(graph, nx, visited)
      end
    end
  end

  def can_reach_all(graph, node) do
    size = graph |> Enum.count()
    size == dfs(graph, node)
  end

  def dfs(graph, source) do
    size = graph |> Enum.count()
    visited = MapSet.new([source])
    queue = [source]
    dfs_inner(graph, size, queue, visited, 1)
  end

  def dfs_inner(_graph, size, _queue, _visited, size = _count), do: size
  def dfs_inner(_graph, _size, [], _visited, count), do: count

  def dfs_inner(graph, size, [nd | queue], visited, count) do
    {queue, visited, count} =
      for neighboor <- Map.get(graph, nd), reduce: {queue, visited, count} do
        {queue, visited, count} ->
          if !(neighboor in visited) do
            {[neighboor | queue], MapSet.put(visited, neighboor), count + 1}
          else
            {queue, visited, count}
          end
      end

    dfs_inner(graph, size, queue, visited, count)
  end

  def run(filename) do
    graph = parse_file(filename)

    base_conns =
      for {lhs, rhs} <- graph, rhs <- rhs do
        {lhs, rhs}
      end
      |> Enum.uniq()

    # let's full recreate the graph
    conns = graph_to_conns(graph)
    graph = conns_to_graph(conns)

    nodes = Map.keys(graph)
    nb_nodes = Enum.count(nodes)

    IO.inspect(Enum.count(base_conns), label: "[DDA] nb base conns")
    IO.inspect(nb_nodes, label: "[DDA] nb nodes")

    # we want to picl a first node that has a lot of connections
    shuffle1 = Enum.shuffle(base_conns)
    shuffle2 = Enum.shuffle(base_conns)
    shuffle3 = Enum.shuffle(base_conns)

    node1 =
      graph
      |> Enum.to_list()
      |> Enum.map(fn {node, v} -> {node, Enum.count(v)} end)
      |> Enum.sort(fn {_, count1}, {_, count2} -> count1 > count2 end)
      |> List.first()
      |> IO.inspect(label: "[DDA] first node")
      |> elem(0)

    for conn1 <- shuffle1,
        conn2 <- shuffle2,
        conn3 <- shuffle3,
        conn2 != conn1,
        conn1 != conn3,
        conn2 != conn3,
        reduce: {0, MapSet.new()} do
      {count, visited} ->
        {lhs1, rhs1} = conn1
        {lhs2, rhs2} = conn2
        {lhs3, rhs3} = conn3
        key = [lhs1, rhs1, lhs2, rhs2, lhs3, rhs3] |> Enum.sort() |> Enum.join("-")

        if MapSet.member?(visited, key) do
          {count + 1, visited}
        else
          graph =
            graph |> remove_full_conn(conn1) |> remove_full_conn(conn2) |> remove_full_conn(conn3)

          visited = MapSet.put(visited, key)

          if rem(count, 1000) == 0 do
            IO.puts("[DDA] #{count}...")
          end

          if !can_reach_all(graph, node1) do
            IO.puts("[DDA] #{inspect(conn1)}, #{inspect(conn2)}, #{inspect(conn3)}")

            non_full_rings =
              nodes
              |> Enum.map(fn node -> Enum.count(ring(graph, node)) end)
              |> Enum.filter(fn count -> count != nb_nodes end)
              |> Enum.uniq()

            IO.puts("[DDA] -> will lead to splits #{inspect(non_full_rings)}")
          end

          {count + 1, visited}
        end
    end
  end
end

defmodule P2 do
end

defmodule P do
  def start() do
    Cache.setup()
    # P1.run("sample.txt")
    P1.run("input.txt")
    # P2.run("input.txt")
  end
end
