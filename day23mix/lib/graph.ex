#!/usr/bin/env elixir

defmodule Graph do
  @max_dist 1_000_000_000

  # --------------------------------------------------------------------------------
  # dfs
  # --------------------------------------------------------------------------------

  # return unvisited node which has the minimum distance
  defp min_distance(distances, unvisited) do
    # unvisited
    # |> Enum.reduce({-1, @max_dist}, fn nd, acc = {_, min_dist} ->
    #   dist = Map.get(distances, nd)

    #   if dist < min_dist do
    #     {nd, dist}
    #   else
    #     acc
    #   end
    # end)

    distances
    |> Enum.reduce({-1, @max_dist}, fn {nd, dist}, {min_nd, min_dist} ->
      if dist < min_dist && MapSet.member?(unvisited, nd) do
        {nd, dist}
      else
        {min_nd, min_dist}
      end
    end)
  end

  def dijkstra_dfs(graph, source, dest) do
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
        distances =
          Map.get(graph, min_node)
          |> Enum.reduce(distances, fn {nd, weight}, distances ->
            dist_nd = Map.get(distances, nd)

            if dist_nd > min_dist + weight && MapSet.member?(unvisited, nd) do
              Map.put(distances, nd, min_dist + weight)
            else
              distances
            end
          end)

        {:cont, {distances, unvisited}}
      end
    end)
  end

  # --------------------------------------------------------------------------------
  # with priority queue
  # --------------------------------------------------------------------------------

  # graph is a map of node -> list of {neighboor, weight}
  def dijkstra_pq(graph, source, dest) do
    # initialize
    nodes = Map.keys(graph)

    # all distances are set to infinity initally
    distances = for node <- nodes, into: %{}, do: {node, @max_dist}
    distances = Map.put(distances, source, 0)

    unvisited = Heap.new(fn {_, x}, {_, y} -> x < y end)
    unvisited = Heap.push(unvisited, {source, 0})

    distances = dijkstra_pq_inner(graph, unvisited, distances)
    Map.get(distances, dest)
  end

  defp dijkstra_pq_inner(graph, unvisited, distances) do
    if Heap.empty?(unvisited) do
      distances
    else
      {current_nd, current_dist} = Heap.root(unvisited)
      unvisited = Heap.pop(unvisited)

      if current_dist > Map.get(distances, current_nd) do
        dijkstra_pq_inner(graph, unvisited, distances)
      else
        {unvisited, distances} =
          Map.get(graph, current_nd)
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

        dijkstra_pq_inner(graph, unvisited, distances)
      end
    end
  end
end
