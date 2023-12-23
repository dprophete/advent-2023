#!/usr/bin/env elixir

defmodule GraphSearch1 do
  @max_dist 1_000_000_000

  def weight_between(graph, x, y) do
    graph |> Enum.at(y) |> Enum.at(x)
  end

  # return unvisited node which has the minimum distance
  def min_distance(distances, unvisited) do
    distances
    |> Enum.reduce({-1, @max_dist}, fn {nd, dist}, {min_nd, min_dist} ->
      if MapSet.member?(unvisited, nd) && dist < min_dist do
        {nd, dist}
      else
        {min_nd, min_dist}
      end
    end)
  end

  def dijkstra(graph, source) do
    # initialize
    nb_vertices = graph |> Enum.count()

    # all distances are set to infinity initally
    distances = for v <- 0..(nb_vertices - 1), into: %{}, do: {v, @max_dist}

    unvisited = for v <- 0..(nb_vertices - 1), into: MapSet.new(), do: v

    # set source distance to 0
    distances = Map.put(distances, source, 0)

    {distances, _unvisited} =
      0..(nb_vertices - 1)
      |> Enum.reduce({distances, unvisited}, fn _, {distances, unvisited} ->
        # find node with min distance
        {min_node, _} = min_distance(distances, unvisited)

        # mark it as visited
        unvisited = MapSet.delete(unvisited, min_node)

        # update distances to the adjacent nodes
        distances =
          0..(nb_vertices - 1)
          |> Enum.reduce(distances, fn nd, distances ->
            weight = weight_between(graph, min_node, nd)
            dist_min_node = Map.get(distances, min_node)
            dist_nd = Map.get(distances, nd)

            if weight > 0 && MapSet.member?(unvisited, nd) && dist_nd > dist_min_node + weight do
              Map.put(distances, nd, dist_min_node + weight)
            else
              distances
            end
          end)

        {distances, unvisited}
      end)

    distances
  end
end

defmodule GraphSearch2 do
  @max_dist 1_000_000_000

  # return unvisited node which has the minimum distance
  def min_distance(distances, unvisited) do
    distances
    |> Enum.reduce({-1, @max_dist}, fn {nd, dist}, {min_nd, min_dist} ->
      if MapSet.member?(unvisited, nd) && dist < min_dist do
        {nd, dist}
      else
        {min_nd, min_dist}
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

      if min_node == dest do
        {:halt, min_dist}
      else
        # mark it as visited
        unvisited = MapSet.delete(unvisited, min_node)

        # update distances to the adjacent nodes
        distances =
          Map.get(graph, min_node)
          |> Enum.reduce(distances, fn {nd, weight}, distances ->
            dist_min_node = Map.get(distances, min_node)
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

  def dijkstra(graph, source) do
    # initialize
    nodes = Map.keys(graph)

    # all distances are set to infinity initally
    distances = for node <- nodes, into: %{}, do: {node, @max_dist}

    unvisited = MapSet.new(nodes)

    # set source distance to 0
    distances = Map.put(distances, source, 0)

    {distances, _unvisited} =
      nodes
      |> Enum.reduce({distances, unvisited}, fn _, {distances, unvisited} ->
        # find node with min distance
        {min_node, _} = min_distance(distances, unvisited)

        # mark it as visited
        unvisited = MapSet.delete(unvisited, min_node)

        # update distances to the adjacent nodes

        distances =
          Map.get(graph, min_node)
          |> Enum.reduce(distances, fn {nd, weight}, distances ->
            dist_min_node = Map.get(distances, min_node)
            dist_nd = Map.get(distances, nd)

            if MapSet.member?(unvisited, nd) && dist_nd > dist_min_node + weight do
              Map.put(distances, nd, dist_min_node + weight)
            else
              distances
            end
          end)

        {distances, unvisited}
      end)

    distances
  end
end

defmodule GraphSearch3 do
  @max_dist 1_000_000_000

  # return unvisited node which has the minimum distance
  def min_distance(distances, unvisited) do
    distances
    |> Enum.reduce({-1, @max_dist}, fn {nd, dist}, {min_nd, min_dist} ->
      if MapSet.member?(unvisited, nd) && dist < min_dist do
        {nd, dist}
      else
        {min_nd, min_dist}
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

      if min_node == dest do
        {:halt, min_dist}
      else
        # mark it as visited
        unvisited = MapSet.delete(unvisited, min_node)

        # update distances to the adjacent nodes
        distances =
          Map.get(graph, min_node)
          |> Enum.reduce(distances, fn {nd, weight}, distances ->
            dist_min_node = Map.get(distances, min_node)
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
