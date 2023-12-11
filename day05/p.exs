#!/usr/bin/env elixir

defmodule P1 do
  # file: [:seeds, :phases]
  # phase: [:name, :mappings]
  # mapping: [:src, :dst, :len, :end]
  # intersection: [:src, :end, :dst]
  # interval: [:src, :end]
  def parse_file(filename) do
    [str_seeds | str_phases] =
      File.read!(filename) |> String.split("\n\n")

    seeds =
      String.split(str_seeds, ": ")
      |> List.last()
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)

    phases =
      str_phases
      |> Enum.map(fn str_phase ->
        [step_name, str_mappings] = String.split(str_phase, " map:\n")

        mappings =
          str_mappings
          |> String.split("\n", trim: true)
          |> Enum.map(fn str_mapping ->
            [dst, src, len] =
              str_mapping |> String.split(" ") |> Enum.map(&String.to_integer/1)

            [dst: dst, src: src, len: len, end: src + len - 1]
          end)
          |> Enum.sort_by(fn mapping -> mapping[:src] end)

        [name: step_name, mappings: mappings]
      end)

    [seeds: seeds, phases: phases]
  end

  def is_in_mapping(mapping, val) do
    [dst: dst, src: src, len: _, end: end_] = mapping

    cond do
      val < src -> {:halt, val}
      val <= end_ -> {:halt, dst + (val - src)}
      true -> {:cont, val}
    end
  end

  def dst_for_val(phase, val) do
    Enum.reduce_while(phase[:mappings], val, &is_in_mapping/2)
  end

  def run(filename) do
    [seeds: seeds, phases: phases] = parse_file(filename)

    for seed <- seeds do
      final_dst = phases |> Enum.reduce(seed, &dst_for_val/2)
      IO.puts("seed: #{seed} -> #{final_dst}")
      final_dst
    end
    |> Enum.min()
    |> IO.puts()
  end
end

defmodule P2 do
  def interval_for_intersection(intersection) do
    [src: src, end: end_, dst: dst] = intersection
    [src: dst, end: dst + (end_ - src)]
  end

  def intersections_for_mapping(mapping, {intersections, interval}) do
    [dst: m_dst, src: m_src, len: _, end: m_end] = mapping
    [src: i_src, end: i_end] = interval

    intersection_left = [src: i_src, end: min(i_end, m_src - 1), dst: i_src]

    intersection_middle = [
      src: max(i_src, m_src),
      end: min(i_end, m_end),
      dst: m_dst + (max(i_src, m_src) - m_src)
    ]

    interval_right = [src: max(i_src, m_end + 1), end: i_end]

    cond do
      i_end < m_src ->
        # r:            [-------------]
        # i:  [------]
        {:halt, intersections ++ [intersection_left]}

      i_src > m_end ->
        # r:            [-------------]
        # i:                             [------]
        {:cont, {intersections, interval_right}}

      i_src >= m_src and i_end <= m_end ->
        # r:            [-------------]
        # i:                [----]
        {:halt, intersections ++ [intersection_middle]}

      i_src < m_src and i_end <= m_end ->
        # r:            [-------------]
        # i:        [------]
        {:halt, intersections ++ [intersection_left, intersection_middle]}

      i_src >= m_src and i_end > m_end ->
        # r:            [-------------]
        # i:                       [------]
        {:cont, {intersections ++ [intersection_middle], interval_right}}

      i_src < m_src and i_end > m_end ->
        # r:            [-------------]
        # i:        [---------------------]
        {:cont, {intersections ++ [intersection_left, intersection_middle], interval_right}}
    end
  end

  def intersections_for_mappings(mappings, interval) do
    case mappings |> Enum.reduce_while({[], interval}, &intersections_for_mapping/2) do
      {intersections, [src: i_src, end: i_end]} ->
        intersections ++ [[src: i_src, end: i_end, dst: i_src]]

      intersections ->
        intersections
    end
  end

  def run(filename) do
    [seeds: seeds, phases: phases] = P1.parse_file(filename)
    seed_pairs = Enum.chunk_every(seeds, 2)

    intervals =
      for [src, len] <- seed_pairs do
        [src: src, end: src + len - 1]
      end

    final_intervals =
      phases
      |> Enum.reduce(intervals, fn phase, intervals ->
        res =
          for interval <- intervals do
            phase[:mappings]
            |> intersections_for_mappings(interval)
            |> Enum.map(&interval_for_intersection/1)
          end
          |> Enum.concat()

        IO.puts("phase: #{phase[:name]} -> nb intervals: #{length(res)}")

        res
      end)

    final_intervals
    |> Enum.map(& &1[:src])
    |> Enum.sort()
    |> List.first()
    |> IO.puts()
  end
end

# P1.run("sample.txt")
# P1.run("input.txt")
# P2.run("sample.txt")
P2.run("input.txt")
