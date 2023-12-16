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

  def move_left(c, ?#), do: {c, ?#}
  def move_left(?., c), do: {c, ?.}
  def move_left(c1, c2), do: {c1, c2}

  def move_left(row) do
    # .oo..#o..o.. => oo...#o.o...
    # oo...#o.o... => oo...#oo....
    row1 = row ++ [?.]

    {[_ | new_row], _} =
      row1
      |> Enum.reduce({[], ?#}, fn c, {acc, previous} ->
        {c1, c2} = move_left(previous, c)
        {acc ++ [c1], c2}
      end)

    new_row
  end

  def move_north(platform) do
    platform
    |> transpose()
    |> Enum.map(&move_left/1)
    |> transpose()
  end

  def full_move_north(platform) do
    new_platform = move_north(platform)

    case new_platform == platform do
      true -> new_platform
      false -> full_move_north(new_platform)
    end
  end

  def pp(platform) do
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
    |> full_move_north()
    |> pp()
    |> weigh()
    |> IO.inspect(label: "total")
  end
end

defmodule P2 do
end

# P1.run("sample.txt")
P1.run("input.txt")
# P2.run("sample.txt")
# P2.run("input.txt")
