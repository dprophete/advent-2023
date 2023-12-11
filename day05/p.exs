#!/usr/bin/env elixir

defmodule P1 do
  # file: [:seeds, :phases]
  # phase: [:name, :projs]
  # proj: [:src, :end, :dst]
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
        [step_name, str_projs] = String.split(str_phase, " map:\n")

        projs =
          str_projs
          |> String.split("\n", trim: true)
          |> Enum.map(fn str_proj ->
            [dst, src, len] =
              str_proj |> String.split(" ") |> Enum.map(&String.to_integer/1)

            [src: src, end: src + len - 1, dst: dst]
          end)
          |> Enum.sort_by(fn proj -> proj[:src] end)

        [name: step_name, projs: projs]
      end)

    [seeds: seeds, phases: phases]
  end

  def is_in_proj(proj, val) do
    [src: src, end: end_, dst: dst] = proj

    cond do
      val < src -> {:halt, val}
      val <= end_ -> {:halt, dst + (val - src)}
      true -> {:cont, val}
    end
  end

  def dst_for_val(phase, val) do
    Enum.reduce_while(phase[:projs], val, &is_in_proj/2)
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
  def proj_to_interval(proj) do
    [src: src, end: end_, dst: dst] = proj
    [src: dst, end: dst + (end_ - src)]
  end

  def add_projs_for_interval(proj, {projs, interval}) do
    [src: m_src, end: m_end, dst: m_dst] = proj
    [src: i_src, end: i_end] = interval

    proj_left = [src: i_src, end: min(i_end, m_src - 1), dst: i_src]

    proj_middle = [
      src: max(i_src, m_src),
      end: min(i_end, m_end),
      dst: m_dst + (max(i_src, m_src) - m_src)
    ]

    interval_right = [src: max(i_src, m_end + 1), end: i_end]

    potential_projs =
      [proj_left, proj_middle]
      |> Enum.filter(fn interval -> interval[:src] <= interval[:end] end)

    upd_projs = projs ++ potential_projs

    case interval_right[:src] <= interval_right[:end] do
      true -> {:cont, {upd_projs, interval_right}}
      false -> {:halt, upd_projs}
    end
  end

  def upd_projs_for_interval(projs, interval) do
    case projs |> Enum.reduce_while({[], interval}, &add_projs_for_interval/2) do
      {upd_projs, [src: i_src, end: i_end]} ->
        upd_projs ++ [[src: i_src, end: i_end, dst: i_src]]

      upd_projs ->
        upd_projs
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
            phase[:projs]
            |> upd_projs_for_interval(interval)
            |> Enum.map(&proj_to_interval/1)
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
P1.run("input.txt")
# P2.run("sample.txt")
P2.run("input.txt")
