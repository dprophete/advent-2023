#!/usr/bin/env elixir

defmodule Cache do
  def setup() do
    if :ets.info(:cache) != :undefined do
      :ets.delete(:cache)
    end

    :ets.new(:cache, [:named_table])
  end

  def cache(key, func) do
    case :ets.lookup(:cache, key) do
      [{_, val}] ->
        add_hit()
        val

      [] ->
        val = func.()
        :ets.insert(:cache, {key, val})
        val
    end
  end

  defp add_hit() do
    nb_hits =
      case :ets.lookup(:cache, :hits) do
        [{_, val}] ->
          val

        _ ->
          0
      end

    :ets.insert(:cache, {:hits, nb_hits + 1})
  end

  def put(key, val) do
    :ets.insert(:cache, {key, val})
  end

  def get(key) do
    case :ets.lookup(:cache, key) do
      [{_, val}] ->
        add_hit()
        val

      _ ->
        nil
    end
  end
end

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

  # --------------------------------------------------------------------------------
  # - running
  # --------------------------------------------------------------------------------

  # find all the possible idx where this damage can be placed
  def find_idxs_for_damage(spring, start_idx, damage, nb_damages_remaining) do
    len = length(spring)

    key =
      {:idxs, spring, start_idx, damage, nb_damages_remaining}

    Cache.cache(key, fn ->
      # we need to find a range of damage damage starting at idx start_idx, made of either ? or .
      # IO.puts("tring for spring #{spring}, start_idx #{start_idx}, damage #{damage}")

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
              {nb1, nb2} =
                for c <- rest, reduce: {0, 0} do
                  {nb1, nb2} ->
                    case c do
                      ?# -> {nb1 + 1, nb2 + 1}
                      ?? -> {nb1 + 1, nb2}
                      _ -> {nb1, nb2}
                    end
                end

              nb1 >= nb_damages_remaining && nb2 <= nb_damages_remaining
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
    end)
  end

  def process_spring({spring, damages}) do
    process_inner(spring, 0, Enum.sum(damages), damages)
  end

  def process_inner(_spring, _idx, _nb_damages_remaining, []), do: 1

  def process_inner(spring, idx, nb_damages_remaining, damages = [damage | rest]) do
    key = {:process_inner, spring |> Enum.slice(idx, Enum.count(spring)), damages}

    Cache.cache(key, fn ->
      nb_damages_remaining = nb_damages_remaining - damage

      idxs = find_idxs_for_damage(spring, idx, damage, nb_damages_remaining)

      if idxs == [] do
        0
      else
        idxs
        |> Enum.map(fn idx ->
          process_inner(spring, idx + damage + 1, nb_damages_remaining, rest)
        end)
        |> Enum.sum()
      end
    end)
  end

  def run(filename) do
    for {spring, damages} <- parse_file(filename) do
      spring0 = spring
      spring = "." <> spring <> "."

      # small optimization: a sequence of '...' is the same as a single '.'
      spring = Regex.replace(~r/\.+/, spring, ".")
      spring = String.to_charlist(spring)

      nb_arrangements = process_spring({spring, damages})
      IO.puts("#{pp_row({spring, damages})} -> count #{nb_arrangements}")
      nb_arrangements
    end
    |> Enum.sum()
    |> IO.inspect(label: "total")
  end
end

defmodule P2 do
  def run(filename) do
    for {{spring, damages}, idx} <- P1.parse_file(filename) |> Enum.with_index() do
      {base_spring, base_damages} = {spring, damages}
      spring = "." <> Enum.join([spring, spring, spring, spring, spring], "?") <> "."

      # small optimization: a sequence of '...' is the same as a single '.'
      spring = Regex.replace(~r/\.+/, spring, ".")
      spring = String.to_charlist(spring)

      damages = damages ++ damages ++ damages ++ damages ++ damages

      nb_arrangements = P1.process_spring({spring, damages})

      IO.puts(
        "#{P1.pp_row({String.to_charlist(base_spring), base_damages})} -> count #{nb_arrangements}"
      )

      nb_arrangements
    end
    |> Enum.sum()
    |> IO.inspect(label: "total")
  end
end

Cache.setup()
# P1.run("sample.txt")
# P1.run("input.txt")
# P2.run("sample.txt")
P2.run("input.txt")
IO.puts("[DDA] nb hits: #{Cache.get(:hits)}")
