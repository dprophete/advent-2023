#!/usr/bin/env elixir

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
  def run(filename) do
    boxes = %{}

    steps =
      for step <- P1.parse_file(filename) do
        case String.split(step, "=") do
          [label, focal_lenght] -> {:equal, label, String.to_integer(focal_lenght)}
          _ -> {:minus, String.slice(step, 0, String.length(step) - 1)}
        end
      end

    boxes =
      steps
      |> Enum.reduce(boxes, fn step, boxes ->
        label =
          case step do
            {:equal, label, _} -> label
            {:minus, label} -> label
          end

        box_to_goto = P1.hash_str(label)
        content = Map.get(boxes, box_to_goto, [])

        content =
          case step do
            {:equal, label, focal_length} ->
              case Enum.find(content, fn {lbl, _} -> lbl == label end) do
                nil ->
                  content ++ [{label, focal_length}]

                _ ->
                  content
                  |> Enum.map(fn {lbl, fl} ->
                    case lbl == label do
                      true -> {lbl, focal_length}
                      false -> {lbl, fl}
                    end
                  end)
              end

            {:minus, label} ->
              content |> Enum.reject(fn {lbl, _} -> lbl == label end)
          end

        case content do
          [] -> Map.delete(boxes, box_to_goto)
          _ -> Map.put(boxes, box_to_goto, content)
        end
      end)

    boxes
    |> Map.to_list()
    |> Enum.map(fn {box_nb, content} ->
      (1 + box_nb) *
        (content
         |> Enum.with_index()
         |> Enum.map(fn {{_, fl}, idx} -> fl * (idx + 1) end)
         |> Enum.sum())
    end)
    |> Enum.sum()
    |> IO.inspect(label: "[DDA] total")

    # |> Enum.map(&P1.hash_str/1)
    # |> Enum.sum()
    # |> IO.inspect()
  end
end

defmodule P do
  def start() do
    Cache.setup()
    # P1.run("sample.txt")
    # P1.run("input.txt")
    # P2.run("sample.txt")
    P2.run("input.txt")
  end
end
