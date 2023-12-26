#!/usr/bin/env elixir

# DSL:

defmodule P1 do
  # --------------------------------------------------------------------------------
  # - parsing
  # --------------------------------------------------------------------------------

  def parse_file(filename) do
    map =
      for {line, _idx} <-
            File.read!(filename) |> String.split("\n", trim: true) |> Enum.with_index() do
        String.to_charlist(line)
      end

    entrance = List.first(map) |> Enum.find_index(&(&1 == ?.))
    exit = List.last(map) |> Enum.find_index(&(&1 == ?.))
    {map, {entrance, 0}, {exit, Enum.count(map) - 1}}
  end

  # --------------------------------------------------------------------------------
  # - pp
  # --------------------------------------------------------------------------------

  def pp_map(map) do
    map |> Enum.map(&IO.puts(&1))
  end

  def pp_map_with_path(map, path) do
    map =
      for {px, py} <- path, reduce: map do
        map ->
          row = Enum.at(map, py)
          List.replace_at(map, py, List.replace_at(row, px, ?O))
      end

    pp_map(map)
  end

  # --------------------------------------------------------------------------------
  # - running
  # --------------------------------------------------------------------------------

  def at(map, path, {x, y}) do
    if {x, y} in path do
      :path
    else
      case map |> Enum.at(y) |> Enum.at(x) do
        nil -> :out
        ?# -> :wall
        ?> -> :right
        ?< -> :left
        ?^ -> :up
        ?v -> :down
        ?. -> :empty
      end
    end
  end

  def nx_moves(map, [{x, y} = current | path]) do
    candidate =
      case at(map, path, current) do
        :up ->
          [{x, y - 1}]

        :down ->
          [{x, y + 1}]

        :left ->
          [{x - 1, y}]

        :right ->
          [{x + 1, y}]

        _ ->
          [
            {x, y - 1},
            {x, y + 1},
            {x - 1, y},
            {x + 1, y}
          ]
      end

    candidate
    |> Enum.filter(fn p ->
      p != current && at(map, path, p) in [:empty, :left, :right, :up, :down]
    end)
  end

  # return array of path which ended up succeeding
  def walk_one(_map, exit, [exit | _rest] = path) do
    IO.inspect("[DDA] found exit! with length #{Enum.count(path) - 1}")
    [path]
  end

  def walk_one(map, exit, path) do
    nx_moves(map, path) |> Enum.flat_map(fn p -> walk_one(map, exit, [p | path]) end)
  end

  def run(filename) do
    {map, entrance, exit} = parse_file(filename)
    paths = walk_one(map, exit, [entrance])

    # for path <- paths do
    #   IO.puts("\n== path length #{Enum.count(path) - 1}")
    #   pp_map_with_path(map, path)
    # end

    paths |> Enum.map(&(Enum.count(&1) - 1)) |> Enum.max() |> IO.inspect()
  end
end

defmodule P2 do
  # --------------------------------------------------------------------------------
  # - running
  # --------------------------------------------------------------------------------

  def at(map, {x, y}) do
    case Enum.at(map, y) do
      nil ->
        :wall

      row ->
        case Enum.at(row, x) do
          ?# -> :wall
          ?. -> :empty
        end
    end
  end

  def nx_moves(map, {x, y}, visited) do
    [
      {x, y - 1},
      {x, y + 1},
      {x - 1, y},
      {x + 1, y}
    ]
    |> Enum.filter(fn p -> !(p in visited) && at(map, p) == :empty end)
  end

  def walk_one(map, exit, max_so_far, to_process, {current, visited}, count) do
    process_next = fn potential_max, count ->
      max_so_far = max(max_so_far, potential_max)

      case to_process do
        [] ->
          # nothing else to process -> we are done
          max_so_far

        [first | rest] ->
          walk_one(map, exit, max_so_far, rest, first, count)
      end
    end

    if current == exit do
      # we reached then exit !
      IO.inspect(
        "[DDA] max #{max_so_far}, found exit ##{count + 1} with length #{Enum.count(visited)}"
      )

      process_next.(Enum.count(visited), count + 1)
    else
      case nx_moves(map, current, visited) do
        [] ->
          # no more moves -> we are done with this path
          process_next.(-1, count)

        nxs ->
          visited = MapSet.put(visited, current)
          [first | rest] = nxs |> Enum.map(&{&1, visited})
          walk_one(map, exit, max_so_far, rest ++ to_process, first, count)
      end
    end
  end

  def run(filename) do
    {map, entrance, exit} = P1.parse_file(filename)

    # cleanup map
    map =
      for row <- map do
        for c <- row do
          case c do
            ?> -> ?.
            ?< -> ?.
            ?^ -> ?.
            ?v -> ?.
            _ -> c
          end
        end
      end

    walk_one(map, exit, 0, [], {entrance, MapSet.new()}, 0)
    |> IO.inspect(label: "[DDA] max")

    # for path <- paths do
    #   IO.puts("\n== path length #{Enum.count(path) - 1}")
    #   pp_map_with_path(map, path)
    # end

    # paths |> Enum.map(&(Enum.count(&1) - 1)) |> Enum.max() |> IO.inspect()

    # prepare for dijkstra_dfs
    #   graph =
    #     for {row, y} <- Enum.with_index(map), {c, x} <- Enum.with_index(row) do
    #       case c do
    #         ?. ->
    #           case P1.nx_moves(map, [{x, y}]) do
    #             [] -> nil
    #             neighboors -> {{x, y}, Enum.map(neighboors, &{&1, -1})}
    #           end

    #         _ ->
    #           nil
    #       end
    #     end
    #     |> Enum.filter(&(&1 != nil))
    #     |> Enum.into(%{})
  end
end

defmodule P do
  def start() do
    Cache.setup()
    # P1.run("sample.txt")
    # P1.run("input.txt")
    P2.run("sample.txt")
    # P2.run("input.txt")
  end
end
