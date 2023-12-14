#!/usr/bin/env elixir

defmodule P1 do
  def reduce_with_index(list, acc, fun) do
    list |> Enum.with_index() |> Enum.reduce(acc, fun)
  end

  def parse_file(filename) do
    for line <- File.read!(filename) |> String.split("\n", trim: true) do
      [springs, rest] = String.split(line, " ")
      damages = rest |> String.split(",") |> Enum.map(&String.to_integer/1)
      {String.to_charlist(springs), damages}
    end
  end

  def find_range_of_len(spring, start_idx, damage) do
    # we need to find a range of damage damage starting at idx start_idx, made of either ? or .
    # IO.puts("tring for spring #{spring}, start_idx #{start_idx}, damage #{damage}")

    start_idx..(length(spring) - damage)
    |> Enum.filter(fn idx ->
      c_before = Enum.at(spring, idx - 1)
      c_after = Enum.at(spring, idx + damage)

      # IO.puts(
      #   "  at idx #{idx} c_before #{to_string([c_before])}, range #{Enum.slice(spring, idx, damage)},  c_after #{to_string([c_after])}"
      # )

      (c_before == ?. || c_before == ??) &&
        (c_after == ?. || c_after == ??) &&
        spring |> Enum.slice(idx, damage) |> Enum.all?(fn c -> c == ?# or c == ?? end)
    end)
  end

  def put_damage_at(spring, idx, damage) do
    middle = [?.] ++ List.duplicate(?#, damage) ++ [?.]
    first = Enum.slice(spring, 0, idx - 1)
    last = Enum.slice(spring, idx + damage + 1, length(spring) - idx - damage)
    first ++ middle ++ last
  end

  def process_spring({spring, damages}) do
    nb_damages = Enum.sum(damages)

    damages
    |> Enum.reduce([{0, spring}], fn damage, acc ->
      acc
      |> Enum.flat_map(fn {idx, spring} ->
        find_range_of_len(spring, idx, damage)
        |> Enum.map(fn idx -> {idx + damage + 1, put_damage_at(spring, idx, damage)} end)
      end)
    end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.uniq()
    |> Enum.filter(fn spring -> spring |> Enum.count(fn c -> c == ?# end) == nb_damages end)
  end

  def pp_row({spring, damages}), do: "spring #{pp_spring(spring)} #{inspect(damages)}"

  def pp_spring(spring), do: spring |> Enum.slice(1, Enum.count(spring) - 2) |> to_string

  def pp_arrangements(arrs) do
    arrs
    |> Enum.with_index(1)
    |> Enum.map(fn {spring, idx} -> "       #{pp_spring(spring)} (#{idx})" end)
    |> Enum.join("\n")
  end

  def run(filename) do
    for {spring, damages} <- parse_file(filename) do
      spring = [?.] ++ spring ++ [?.]
      arrangements = process_spring({spring, damages})

      IO.puts(
        "#{pp_row({spring, damages})} -> count #{length(arrangements)}\n#{pp_arrangements(arrangements)}\n"
      )

      length(arrangements)
    end
    |> Enum.sum()
    |> IO.inspect(label: "total")
  end
end

defmodule P2 do
  def run(filename) do
    for {{spring, damages}, idx} <- P1.parse_file(filename) |> Enum.with_index() |> Enum.take(6) do
      spring =
        [?.] ++
          spring ++ [??] ++ spring ++ [??] ++ spring ++ [??] ++ spring ++ [??] ++ spring ++ [?.]

      damages = damages ++ damages ++ damages ++ damages ++ damages
      arrangements = P1.process_spring({spring, damages})

      # IO.puts(
      #   "#{P1.pp_row({spring, damages})} -> count #{length(arrangements)}\n#{P1.pp_arrangements(arrangements)}\n"
      # )

      IO.puts("#row #{idx} -> count #{length(arrangements)}")

      length(arrangements)
    end
    |> Enum.sum()
    |> IO.inspect(label: "total")
  end
end

# P1.run("sample.txt")
P1.run("input.txt")
# P2.run("sample.txt")
# P2.run("input.txt")

# time to beat:
#  ~/tmp/advent-2023/day12 (main*) » time ./p.exs 
#  #row 0 -> count 1
#  #row 1 -> count 16384
#  #row 2 -> count 1
#  #row 3 -> count 16
#  #row 4 -> count 2500
#  #row 5 -> count 506250
#  total: 525152
#  ./p.exs  129.99s user 23.40s system 96% cpu 2:39.52 total
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ~/tmp/advent-2023/day12 (main*) » time ./p.exs
# #row 0 -> count 1
# #row 1 -> count 16384
# #row 2 -> count 1
# #row 3 -> count 16
# #row 4 -> count 2500
# #row 5 -> count 506250
# total: 525152
# ./p.exs  92.62s user 12.58s system 98% cpu 1:47.07 total
