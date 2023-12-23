#!/usr/bin/env elixir

defmodule P1 do
  # DSL:
  # dest = :accept | :reject | {:goto, name}
  # 
  # rule = 
  #  {:always, dest}
  #  {{:lt, var, nb, dest}
  #  {{:gt, var, nb, dest}

  def parse_dest(dest) do
    cond do
      dest == "A" -> :accept
      dest == "R" -> :reject
      true -> {:goto, dest}
    end
  end

  def parse_src(src) do
    cond do
      String.contains?(src, "<") ->
        [var, nb] = Regex.run(~r/(.*)<(.*)/, src, capture: :all_but_first)
        nb = String.to_integer(nb)
        {:lt, var, nb}

      String.contains?(src, ">") ->
        [var, nb] = Regex.run(~r/(.*)>(.*)/, src, capture: :all_but_first)
        nb = String.to_integer(nb)
        {:gt, var, nb}
    end
  end

  def parse_file(filename) do
    [workflows, parts] = File.read!(filename) |> String.split("\n\n", trim: true)

    workflows =
      for workflow <- String.split(workflows, "\n", trim: true), into: %{} do
        [name, rules] = String.split(workflow, "{", trim: true)
        rules = String.slice(rules, 0, String.length(rules) - 1)

        rules =
          for rule <- String.split(rules, ",", trim: true) do
            cond do
              String.contains?(rule, ":") ->
                [src, dest] = String.split(rule, ":", trim: true)
                dest = parse_dest(dest)
                src = parse_src(src)
                {src, dest}

              true ->
                {:always, parse_dest(rule)}
            end
          end

        {name, rules}
      end

    parts =
      for part <- String.split(parts, "\n", trim: true) do
        part = String.slice(part, 1, String.length(part) - 2)

        for ratings <- String.split(part, ",", trim: true), into: %{} do
          [var, nb] = Regex.run(~r/(.*)=(.*)/, ratings, capture: :all_but_first)
          nb = String.to_integer(nb)
          {var, nb}
        end
      end

    {workflows, parts}
  end

  def goto_dest(_workflows, _part, :accept), do: :accept
  def goto_dest(_workflows, _part, :reject), do: :reject
  def goto_dest(workflows, part, {:goto, wf_name}), do: exec_workflow(workflows, part, wf_name)

  def execute_rule(workflows, part, [{{:lt, var, nb}, dest} | rules]) do
    if Map.get(part, var) < nb do
      goto_dest(workflows, part, dest)
    else
      execute_rule(workflows, part, rules)
    end
  end

  def execute_rule(workflows, part, [{{:gt, var, nb}, dest} | rules]) do
    if Map.get(part, var) > nb do
      goto_dest(workflows, part, dest)
    else
      execute_rule(workflows, part, rules)
    end
  end

  def execute_rule(workflows, part, [{:always, dest} | _rules]) do
    goto_dest(workflows, part, dest)
  end

  def exec_workflow(workflows, part, wf_name) do
    wf = Map.get(workflows, wf_name)
    execute_rule(workflows, part, wf)
  end

  def run(filename) do
    {workflows, parts} = parse_file(filename)

    for part <- parts do
      case exec_workflow(workflows, part, "in") do
        :accept -> part |> Map.values() |> Enum.sum()
        :reject -> 0
      end
    end
    |> Enum.sum()
    |> IO.inspect()
  end
end

defmodule P2 do
end

defmodule P do
  def start() do
    Cache.setup()
    # P1.run("sample.txt")
    P1.run("input.txt")
    # P2.run("sample.txt")
    # P2.run("input.txt")
  end
end
