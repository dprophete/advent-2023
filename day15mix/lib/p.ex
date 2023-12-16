#!/usr/bin/env elixir

defmodule Utils do
  # a base transpose function
  def transpose(rows) do
    rows
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end
end

defmodule Cache do
  def setup() do
    :ets.new(:cache, [:named_table])
  end

  def cache(key, func) do
    case :ets.lookup(:cache, key) do
      [{_, val}] ->
        val

      [] ->
        val = func.()
        :ets.insert(:cache, {key, val})
        val
    end
  end
end

defmodule P1 do
  def hash_char(val, char) do
    rem((val + char) * 17, 256)
  end

  def hash_str(str) do
    str
    |> String.to_charlist()
    |> Enum.reduce(0, &hash_char/2)
  end

  def parse_file(filename) do
    for step <- File.read!(filename) |> String.split(",", trim: true) do
      String.trim(step)
    end
  end

  def run(filename) do
    parse_file(filename)
    |> Enum.map(&hash_str/1)
    |> Enum.sum()
    |> IO.inspect()
  end
end

defmodule P2 do
end

Cache.setup()
# P1.run("sample.txt")
P1.run("input.txt")
# P2.run("sample.txt")
# P2.run("input.txt")
