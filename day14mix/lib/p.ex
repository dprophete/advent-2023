#!/usr/bin/env elixir

defmodule P1 do
  # a base transpose function
  def transpose(rows) do
    rows
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  def parse_file(filename) do
    for row <- File.read!(filename) |> String.split("\n", trim: true) do
      String.to_charlist(row)
    end
  end

  def _move_west(c, ?#), do: {c, ?#}
  def _move_west(?., c), do: {c, ?.}
  def _move_west(c1, c2), do: {c1, c2}

  def _move_west(row) do
    # .oo..#o..o.. => oo...#o.o...
    # oo...#o.o... => oo...#oo....
    row1 = row ++ [?.]

    {[_ | new_row], _} =
      row1
      |> Enum.reduce({[], ?#}, fn c, {acc, previous} ->
        {c1, c2} = _move_west(previous, c)
        {acc ++ [c1], c2}
      end)

    new_row
  end

  def move_north(platform) do
    platform
    |> transpose()
    |> Enum.map(&_move_west/1)
    |> transpose()
  end

  def move_west(platform) do
    platform
    |> Enum.map(&_move_west/1)
  end

  def move_south(platform) do
    platform
    |> Enum.reverse()
    |> transpose()
    |> Enum.map(&_move_west/1)
    |> transpose()
    |> Enum.reverse()
  end

  def move_east(platform) do
    platform
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(&_move_west/1)
    |> Enum.map(&Enum.reverse/1)
  end

  def full_move(platform, func) do
    new_platform = func.(platform)

    case new_platform == platform do
      true -> new_platform
      false -> full_move(new_platform, func)
    end
  end

  def full_move_north(platform), do: full_move(platform, &move_north/1)
  def full_move_west(platform), do: full_move(platform, &move_west/1)
  def full_move_south(platform), do: full_move(platform, &move_south/1)
  def full_move_east(platform), do: full_move(platform, &move_east/1)

  def pp(platform, txt) do
    IO.puts("========= #{txt}")

    platform
    |> Enum.map(&List.to_string/1)
    |> Enum.each(&IO.puts/1)

    platform
  end

  def weigh(platform) do
    nb_rows = Enum.count(platform)

    platform
    |> Enum.with_index()
    |> Enum.map(fn {row, idx} -> Enum.count(row, &(&1 == ?O)) * (nb_rows - idx) end)
    |> Enum.sum()
  end

  def run(filename) do
    platform = parse_file(filename)

    platform
    |> pp("original")
    |> full_move_north()
    |> pp("after full move north")
    |> weigh()
    |> IO.inspect(label: "total")
  end
end

defmodule P2 do
  def tilt(platform) do
    key = platform

    case :ets.lookup(:cache, key) do
      [{_, platform}] ->
        platform

      [] ->
        new_platform =
          platform
          |> P1.full_move_north()
          |> P1.full_move_west()
          |> P1.full_move_south()
          |> P1.full_move_east()

        :ets.insert(:cache, {key, new_platform})
        new_platform
    end
  end

  def run(filename) do
    :ets.new(:cache, [:named_table])

    platform = P1.parse_file(filename)

    nb = 1_000_000_000

    {platform, i} =
      1..nb
      |> Enum.reduce_while({platform, -1}, fn i, {platform, _} ->
        hit? = :ets.lookup(:cache, platform) != []

        platform = tilt(platform)

        case hit? do
          true -> {:halt, {platform, i}}
          false -> {:cont, {platform, -1}}
        end
      end)

    IO.puts("got into cache at: #{i}")

    cycle =
      0..i
      |> Enum.reduce_while({platform, MapSet.new()}, fn j, {platform, set} ->
        platform = tilt(platform)

        case MapSet.member?(set, platform) do
          true -> {:halt, j}
          false -> {:cont, {platform, MapSet.put(set, platform)}}
        end
      end)

    IO.puts("got a cycle of: #{cycle}")

    left = nb - i - 1
    left = rem(left, cycle)

    IO.puts("left: #{left}")

    platform =
      0..left
      |> Enum.reduce(platform, fn _, platform ->
        platform = tilt(platform)
        platform
      end)

    platform
    |> P1.weigh()
    |> IO.inspect(label: "total")
  end
end

# P1.run("sample.txt")
# P1.run("input.txt")
# P2.run("sample.txt")
P2.run("input.txt")
