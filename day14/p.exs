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
  @cache %{}

  def tilt(platform) do
    if Map.has_key?(@cache, platform) do
      IO.puts("!!!!!!! cache hit")
      Map.get(@cache, platform)
    else
      new_platform =
        platform
        |> P1.full_move_north()
        |> P1.full_move_west()
        |> P1.full_move_south()
        |> P1.full_move_east()

      Map.put(@cache, platform, new_platform)
      new_platform
    end
  end

  def run(filename) do
    platform = P1.parse_file(filename)

    platform
    |> P1.pp("original")
    |> tilt()
    |> tilt()
    |> tilt()
    |> P1.pp("after 3 tilt")
    |> P1.weigh()
    |> IO.inspect(label: "total")

    0..10_000
    |> Enum.reduce_while(platform, fn i, platform ->
      new_platform = tilt(platform)

      case new_platform == platform do
        true -> {:halt, {:ok, platform, i}}
        false -> {:cont, new_platform}
      end
    end)
    |> IO.inspect(label: "after 10_000 tilt")
  end
end

# P1.run("sample.txt")
P1.run("input.txt")
# P2.run("sample.txt")
# P2.run("input.txt")
