#!/usr/bin/env elixir

defmodule P1 do
  def process_line(line) do
    line
    |> String.to_charlist()
    |> Enum.filter(&(&1 in ?0..?9))
    |> Enum.map(&(&1 - ?0))
    |> then(fn digits -> List.first(digits) * 10 + List.last(digits) end)
  end

  def run(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
    |> Enum.map(&process_line/1)
    |> Enum.sum()
    |> IO.puts()
  end
end

defmodule P2 do
  @str_digits %{
    one: "o1e",
    two: "t2o",
    three: "t3e",
    four: "f4r",
    five: "f5e",
    six: "s6x",
    seven: "s7n",
    eight: "e8t",
    nine: "n9e"
  }

  def replace_digits(line) do
    Enum.reduce(@str_digits, line, fn {k, v}, acc ->
      String.replace(acc, Atom.to_string(k), v)
    end)
  end

  def run(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
    |> Enum.map(&replace_digits/1)
    |> Enum.map(&P1.process_line/1)
    |> Enum.sum()
    |> IO.puts()
  end
end

P1.run("sample.txt")
# P1.run("input.txt")
# P2.run("sample2.txt")
# P2.run("input.txt")
