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
    # visited = MapSet.put(visited, node)
    nxs = Map.get(graph, node)

    if nxs == nil do
      IO.puts("[DDA] invalid node #{node}")
      visited
    else
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

    node1 = Enum.at(nodes, 0)

    for {conn1, idx1} <- Enum.with_index(base_conns),
        {conn2, idx2} <- Enum.with_index(base_conns),
        {conn3, idx3} <- Enum.with_index(base_conns),
        idx1 < idx2 && idx2 < idx3,
        reduce: 0 do
      count ->
        if rem(count, 1000) == 0 do
          IO.puts("[DDA] #{count}...")
        end

        graph =
          graph
          |> remove_full_conn(conn1)
          |> remove_full_conn(conn2)
          |> remove_full_conn(conn3)

        if Enum.count(ring(graph, node1)) != nb_nodes do
          IO.puts("[DDA] #{inspect(conn1)}, #{inspect(conn2)}, #{inspect(conn3)}")

          non_full_rings =
            nodes
            |> Enum.map(fn node -> Enum.count(ring(graph, node)) end)
            |> Enum.filter(fn count -> count != nb_nodes end)
            |> Enum.uniq()

          IO.puts("[DDA] -> will lead to splits #{inspect(non_full_rings)}")

          count + 1
        else
          count + 1
        end
    end

    # graph =
    #   graph
    #   |> remove_full_conn({"hfx", "pzl"})
    #   |> remove_full_conn({"bvb", "cmg"})
    #   |> remove_full_conn({"nvd", "jqt"})
    #   IO.puts("ring #{n1}: #{Enum.count(ring(graph, n1))}")
    # end

    # IO.inspect(graph, label: "[DDA] graph")
    # r_bvb = ring(graph, "bvb")
    # IO.puts("ring bvb: #{Enum.count(r_bvb)} -> #{inspect(r_bvb)}")
  end
end

defmodule P2 do
end

defmodule P do
  def start() do
    Cache.setup()
    P1.run("sample.txt")
    # P1.run("input.txt")
    # P2.run("input.txt")
  end
end
