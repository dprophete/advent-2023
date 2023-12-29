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
      {lhs, rhs}
    end
  end

  # --------------------------------------------------------------------------------
  # - running
  # --------------------------------------------------------------------------------

  # Karger’s algorithm
  def contract(graph, fconn) do
    {{lhs, rhs}, _oconn} = fconn

    new_name = "#{lhs}-#{rhs}"

    for fconn0 = {{lhs_, rhs_}, oconn} <- graph do
      cond do
        lhs_ == lhs && rhs_ == rhs -> nil
        lhs_ == rhs && rhs_ == lhs -> nil
        lhs_ == lhs -> {{new_name, rhs_}, oconn}
        lhs_ == rhs -> {{new_name, rhs_}, oconn}
        rhs_ == rhs -> {{lhs_, new_name}, oconn}
        rhs_ == lhs -> {{lhs_, new_name}, oconn}
        true -> fconn0
      end
    end
    |> Enum.filter(fn x -> x != nil end)
  end

  def kargers_split(graph) do
    if nb_nodes(graph) == 2 do
      graph
    else
      # pick a random connection and 'contract it'
      fconn = Enum.random(graph)
      graph = contract(graph, fconn)
      kargers_split(graph)
    end
  end

  def nb_nodes(graph) do
    graph |> nodes() |> Enum.count()
  end

  def nodes(graph) do
    graph
    |> Enum.map(fn {{lhs, rhs}, _} -> [lhs, rhs] end)
    |> List.flatten()
    |> Enum.uniq()
  end

  def split_until_3(graph, count \\ 1) do
    if Enum.count(graph) == 3 do
      graph
    else
      new_graph = kargers_split(graph)

      IO.puts(
        "[DDA] splitting #{count}... nb conns: #{Enum.count(new_graph)}, #{inspect(new_graph |> Enum.map(fn {_, oconn} -> oconn end))}"
      )

      if Enum.count(new_graph) == 3 do
        new_graph
      else
        split_until_3(graph, count + 1)
      end
    end
  end

  def run(filename) do
    graph = parse_file(filename)

    # naming convention:
    #   lhs, rhs = base node names
    #   conn = {lhs, rhs}
    #   oconn = orignal connection {lhs, rhs}
    #   fconn = full connection {conn, oconn}
    graph =
      for {lhs, rhs} <- graph, rhs <- rhs do
        # for each side, we will keep track of the original connection
        # so that when we crontract, we can still find the original connection
        # (contract will only change the first part of the tuple)
        {{lhs, rhs}, {lhs, rhs}}
      end

    graph = split_until_3(graph)

    [{{lhs, rhs}, _oconn} | _] = graph

    IO.inspect(graph |> Enum.map(fn {_, oconn} -> oconn end),
      label: "[DDA] connections to remove to split"
    )

    nb_lhs = lhs |> String.split("-") |> Enum.count()
    nb_rhs = rhs |> String.split("-") |> Enum.count()
    IO.puts("size of groups: #{nb_lhs}, #{nb_rhs} -> #{nb_lhs * nb_rhs}")
  end
end

defmodule P do
  def start() do
    Cache.setup()
    # P1.run("sample0.txt")
    P1.run("sample.txt")
    # P1.run("input.txt")
  end
end
