#!/usr/bin/env elixir

defmodule P1 do
  # a base transpose function
  def transpose(rows) do
    rows
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  def parse_file(filename) do
    for pattern <- File.read!(filename) |> String.split("\n\n", trim: true) do
      pattern |> String.split("\n", trim: true) |> Enum.map(&String.to_charlist/1)
    end
  end

  def find_reflection_after_row(pattern, row_idx) do
    nb_in_betweens = Enum.count(pattern) - 1

    res =
      0..min(row_idx, nb_in_betweens - 1 - row_idx)
      |> Enum.reduce_while([], fn i, acc ->
        above = row_idx - i
        below = row_idx + 1 + i

        row_above = Enum.at(pattern, above)
        row_below = Enum.at(pattern, below)

        case row_above == row_below do
          true -> {:cont, [above, below]}
          false -> {:halt, acc}
        end
      end)

    # it only counts if we reached the one of the sides
    case res do
      [0, _] -> row_idx + 1
      [_, ^nb_in_betweens] -> row_idx + 1
      _ -> 0
    end
  end

  def find_reflections(pattern) do
    nb_in_betweens = Enum.count(pattern) - 1

    0..(nb_in_betweens - 1)
    |> Enum.reduce_while(0, fn row_idx, _ ->
      case find_reflection_after_row(pattern, row_idx) do
        0 -> {:cont, 0}
        _ -> {:halt, row_idx + 1}
      end
    end)
  end

  def run(filename) do
    for {pattern, idx} <- parse_file(filename) |> Enum.with_index() do
      case pattern |> find_reflections() do
        0 -> pattern |> transpose |> find_reflections()
        hori -> hori * 100
      end
      |> IO.inspect(label: "pattern #{idx}")
    end
    |> Enum.sum()
    |> IO.inspect(label: "total")
  end
end

defmodule P2 do
  def find_reflection_after_row(pattern, row_idx, with_flip) do
    nb_in_betweens = Enum.count(pattern) - 1

    # will return [above, below], :flipped | :not_flipped
    res =
      0..min(row_idx, nb_in_betweens - 1 - row_idx)
      |> Enum.reduce_while({[], :not_flipped}, fn i, {_, is_flipped} = acc ->
        above = row_idx - i
        below = row_idx + 1 + i

        row_above = Enum.at(pattern, above)
        row_below = Enum.at(pattern, below)

        case {row_above == row_below, is_flipped} do
          {true, _} ->
            {:cont, {[above, below], is_flipped}}

          {false, :flipped} ->
            {:halt, acc}

          {false, :not_flipped} ->
            if with_flip do
              diffs =
                Enum.zip(row_above, row_below)
                |> Enum.with_index()
                |> Enum.filter(fn {{a, b}, _} -> a != b end)

              case diffs do
                [{_, flip_col}] -> {:cont, {[above, below], :flipped}}
                _ -> {:halt, acc}
              end
            else
              {:halt, acc}
            end
        end
      end)

    {range, is_flipped} = res
    # it only counts if we reached the one of the sides
    has_reflexion =
      case range do
        [0, _] -> true
        [_, ^nb_in_betweens] -> true
        _ -> false
      end

    {has_reflexion, is_flipped}
  end

  def find_reflections(pattern, with_flip) do
    nb_in_betweens = Enum.count(pattern) - 1

    0..(nb_in_betweens - 1)
    |> Enum.reduce_while(0, fn row_idx, _ ->
      case find_reflection_after_row(pattern, row_idx, with_flip) do
        {false, _} -> {:cont, 0}
        {true, :not_flipped} -> {:cont, 0}
        {true, :flipped} -> {:halt, row_idx + 1}
      end
    end)
  end

  def run(filename) do
    for {pattern, idx} <- P1.parse_file(filename) |> Enum.with_index() do
      case pattern |> find_reflections(true) do
        0 -> pattern |> P1.transpose() |> find_reflections(true)
        hori -> hori * 100
      end
      |> IO.inspect(label: "pattern #{idx}")
    end
    |> Enum.sum()
    |> IO.inspect(label: "total")
  end
end

# P1.run("sample.txt")
# P1.run("input.txt")
# P2.run("sample.txt")
P2.run("input.txt")
