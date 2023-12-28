#!/usr/bin/env elixir

defmodule P1 do
  # --------------------------------------------------------------------------------
  # - parsing
  # --------------------------------------------------------------------------------

  def parse_file(filename) do
    for line <- File.read!(filename) |> String.split("\n", trim: true) do
      # line = "###?.#???.?#.# 4,2,2,1"
      [springs, rest] = String.split(line, " ")
      damages = rest |> String.split(",") |> Enum.map(&String.to_integer/1)
      {springs, damages}
    end
  end

  # --------------------------------------------------------------------------------
  # - pp
  # --------------------------------------------------------------------------------

  def pp_row({spring, damages}), do: "spring #{pp_spring(spring)} #{inspect(damages)}"

  def pp_spring(spring), do: spring |> Enum.slice(1, Enum.count(spring) - 2) |> to_string

  def pp_arrangements(arrs) do
    arrs
    |> Enum.with_index(1)
    |> Enum.map(fn {spring, idx} -> "       #{pp_spring(spring)} (#{idx})" end)
    |> Enum.join("\n")
  end

  # --------------------------------------------------------------------------------
  # - running
  # --------------------------------------------------------------------------------

  def reduce_with_index(list, acc, fun) do
    list |> Enum.with_index() |> Enum.reduce(acc, fun)
  end

  def find_range_of_len(spring, start_idx, damage, nb_damages_remaining) do
    # we need to find a range of damage damage starting at idx start_idx, made of either ? or .
    # IO.puts("tring for spring #{spring}, start_idx #{start_idx}, damage #{damage}")

    len = length(spring)

    start_idx..len
    |> Enum.reduce_while([], fn idx, acc ->
      c_before = Enum.at(spring, idx - 1)
      c_after = Enum.at(spring, idx + damage)

      # valid if:
      # - we have space before
      # - we have space after
      # - all the elements of the range are available
      # - we have enough spots for the remaining damages
      # - we don't have too many spots
      is_valid =
        (c_before == ?. || c_before == ??) &&
          (c_after == ?. || c_after == ??) &&
          spring |> Enum.slice(idx, damage) |> Enum.all?(fn c -> c == ?# or c == ?? end) &&
          spring
          |> Enum.slice(idx + damage + 1, len)
          |> then(fn rest ->
            rest |> Enum.count(fn c -> c == ?# || c == ?? end) >= nb_damages_remaining &&
              rest |> Enum.count(fn c -> c == ?# end) <= nb_damages_remaining
          end)

      case is_valid do
        true ->
          {:cont, [idx | acc]}

        false ->
          # note that we can not skip any #
          if spring
             |> Enum.slice(start_idx, idx - start_idx + 1)
             |> Enum.any?(fn c -> c == ?# == true end) do
            {:halt, acc}
          else
            {:cont, acc}
          end
      end
    end)
  end

  # def put_damage_at(spring, idx, damage) do
  #   middle = List.duplicate(?#, damage)
  #   first = Enum.slice(spring, 0, idx)
  #   last = Enum.slice(spring, idx + damage, length(spring) - idx - damage + 1)
  #   first ++ middle ++ last
  # end

  def process_spring({spring, damages}) do
    nb_damages = Enum.sum(damages)

    for damage <- damages, reduce: [{0, 0, nb_damages}] do
      acc ->
        acc
        |> Enum.flat_map(fn {idx, nb_used_damages, nb_damages_remaining} ->
          nb_damages_remaining = nb_damages_remaining - damage

          for idx <- find_range_of_len(spring, idx, damage, nb_damages_remaining) do
            {idx + damage + 1, nb_used_damages + damage, nb_damages_remaining}
          end
        end)
    end
  end

  def run(filename) do
    for {spring, damages} <- parse_file(filename) do
      spring = "." <> spring <> "."

      # small optimization: a sequence of '...' is the same as a single '.'
      spring = Regex.replace(~r/\.+/, spring, ".")
      spring = String.to_charlist(spring)

      arrangements = process_spring({spring, damages})

      IO.puts(
        # "#{pp_row({spring, damages})} -> count #{length(arrangements)}\n#{pp_arrangements(arrangements)}\n"
        "#{pp_row({spring, damages})} -> count #{length(arrangements)}"
      )

      length(arrangements)
    end
    |> Enum.sum()
    |> IO.inspect(label: "total")
  end
end

defmodule P2 do
  def run(filename) do
    for {{spring, damages}, idx} <- P1.parse_file(filename) |> Enum.with_index() do
      spring = "." <> Enum.join([spring, spring, spring, spring, spring], "?") <> "."

      # small optimization: a sequence of '...' is the same as a single '.'
      spring = Regex.replace(~r/\.+/, spring, ".")
      spring = String.to_charlist(spring)

      damages = damages ++ damages ++ damages ++ damages ++ damages
      arrangements = P1.process_spring({spring, damages})

      IO.puts(
        # "#{pp_row({spring, damages})} -> count #{length(arrangements)}\n#{pp_arrangements(arrangements)}\n"
        "#{P1.pp_row({spring, damages})} -> count #{length(arrangements)}"
      )

      IO.puts("#row #{idx} -> count #{length(arrangements)}")

      length(arrangements)
    end
    |> Enum.sum()
    |> IO.inspect(label: "total")
  end
end

# 4 1 1 4 10
# P1.run("sample.txt")
# P1.run("input.txt")
P2.run("sample.txt")
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
#
#
# #row 0 -> count 1
# #row 1 -> count 16384
# #row 2 -> count 1
# #row 3 -> count 16
# #row 4 -> count 2500
# #row 5 -> count 506250
# total: 525152
# ./p.exs  8.75s user 1.11s system 102% cpu 9.587 total
#
#
# #row 0 -> count 1
# #row 1 -> count 16384
# #row 2 -> count 1
# #row 3 -> count 16
# #row 4 -> count 2500
# #row 5 -> count 506250
# total: 525152
# ./p.exs  3.41s user 0.73s system 112% cpu 3.690 total
#
#
# #row 0 -> count 1
# #row 1 -> count 16384
# #row 2 -> count 1
# #row 3 -> count 16
# #row 4 -> count 2500
# #row 5 -> count 506250
# total: 525152
# ./p.exs  1.32s user 0.55s system 137% cpu 1.358 total
