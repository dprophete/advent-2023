#!/usr/bin/env elixir

defmodule P1 do
  def follow_instructions(node, insts, nodes) do
    insts
    |> String.to_charlist()
    |> Enum.reduce(node, fn i, node ->
      case i do
        ?L -> nodes[node][:left]
        ?R -> nodes[node][:right]
      end
    end)
  end

  def parse_file(filename) do
    [insts, rest] = File.read!(filename) |> String.split("\n\n", parts: 2)

    nodes =
      for line <- rest |> String.split("\n", trim: true), into: %{} do
        [[_, name, left, right]] = Regex.scan(~r/(...) = \((...), (...)\)/, line)
        {name, [left: left, right: right]}
      end

    [insts, nodes]
  end

  def until_done({node, nb_loops}, insts, nodes) do
    node = follow_instructions(node, insts, nodes)

    case node do
      "ZZZ" -> nb_loops + 1
      _ -> until_done({node, nb_loops + 1}, insts, nodes)
    end
  end

  def run(filename) do
    [insts, nodes] = parse_file(filename)

    nb_loops = until_done({"AAA", 0}, insts, nodes)
    (nb_loops * String.length(insts)) |> IO.puts()
  end
end

defmodule P2 do
  def until_done({node, nb_loops}, insts, nodes) do
    node = P1.follow_instructions(node, insts, nodes)

    case String.ends_with?(node, "Z") do
      true -> nb_loops + 1
      false -> until_done({node, nb_loops + 1}, insts, nodes)
    end
  end

  def run(filename) do
    [insts, nodes] = P1.parse_file(filename)

    starting_nodes =
      nodes |> Map.keys() |> Enum.filter(&String.ends_with?(&1, "A"))

    loops = starting_nodes |> Enum.map(fn node -> until_done({node, 0}, insts, nodes) end)

    Enum.zip(starting_nodes, loops)
    |> Enum.each(fn {node, loop} -> IO.puts("node #{node} -> nb loops #{loop}") end)

    lcm = Enum.reduce(loops, &lcm/2)
    IO.puts(lcm * String.length(insts))
  end
end

# P1.run("sample.txt")
# P1.run("input.txt")
# P2.run("sample2.txt")
P2.run("input.txt")
