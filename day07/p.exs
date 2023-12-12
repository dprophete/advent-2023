#!/usr/bin/env elixir

defmodule P1 do
  def remap(hand, j \\ ?B) do
    for c <- String.to_charlist(hand) do
      case c do
        ?A -> ?E
        ?K -> ?D
        ?Q -> ?C
        ?J -> j
        ?T -> ?A
        _ -> c
      end
    end
  end

  def is_five_of_a_kind([c0, c1, c2, c3, c4]) do
    c0 == c1 && c1 == c2 && c2 == c3 && c3 == c4
  end

  def is_four_of_a_kind([c0, c1, c2, c3, c4]) do
    (c0 == c1 && c1 == c2 && c2 == c3) || (c1 == c2 && c2 == c3 && c3 == c4)
  end

  def is_full_house([c0, c1, c2, c3, c4]) do
    (c0 == c1 && c1 == c2 && c3 == c4) || (c0 == c1 && c2 == c3 && c3 == c4)
  end

  def is_three_of_a_kind([c0, c1, c2, c3, c4]) do
    (c0 == c1 && c1 == c2) || (c1 == c2 && c2 == c3) || (c2 == c3 && c3 == c4)
  end

  def is_two_pairs([c0, c1, c2, c3, c4]) do
    cond do
      c0 == c1 && (c2 == c3 || c3 == c4) -> true
      c1 == c2 && c3 == c4 -> true
      true -> false
    end
  end

  def is_pair([c0, c1, c2, c3, c4]) do
    c0 == c1 || c1 == c2 || c2 == c3 || c3 == c4
  end

  def val(hand) do
    m_hand = remap(hand)
    s_hand = m_hand |> Enum.sort()

    cond do
      is_five_of_a_kind(s_hand) -> [?7 | m_hand]
      is_four_of_a_kind(s_hand) -> [?6 | m_hand]
      is_full_house(s_hand) -> [?5 | m_hand]
      is_three_of_a_kind(s_hand) -> [?4 | m_hand]
      is_two_pairs(s_hand) -> [?3 | m_hand]
      is_pair(s_hand) -> [?2 | m_hand]
      true -> [?1 | m_hand]
    end
  end

  def parse_file(filename) do
    for line <- File.read!(filename) |> String.split("\n", trim: true) do
      [hand, bid] = String.split(line, " ")
      [hand, String.to_integer(bid)]
    end
  end

  def run(filename) do
    for [hand, bid] <- parse_file(filename) do
      [hand: hand, val: val(hand), bid: bid]
    end
    |> Enum.sort_by(& &1[:val])
    |> Enum.with_index(1)
    |> Enum.map(fn {hand_data, idx} -> idx * hand_data[:bid] end)
    |> Enum.sum()
    |> IO.puts()
  end
end

defmodule P2 do
  @j ?0

  def without_1([c0, c1, c2, c3, _c4]) do
    [c0, c1, c2, c3, ?a]
  end

  def without_2([c0, c1, c2, _c3, _c4]) do
    [c0, c1, c2, ?b, ?a]
  end

  def without_3([c0, c1, _c2, _c3, _c4]) do
    [c0, c1, ?c, ?b, ?a]
  end

  def without_4([c0, _c1, _c2, _c3, _c4]) do
    [c0, ?d, ?c, ?b, ?a]
  end

  def is_five_of_a_kind([_c0, c1, c2, c3, c4] = hand) do
    cond do
      P1.is_five_of_a_kind(hand) -> true
      c4 == @j && P1.is_four_of_a_kind(without_1(hand)) -> true
      [c3, c4] == [@j, @j] && P1.is_three_of_a_kind(without_2(hand)) -> true
      [c2, c3, c4] == [@j, @j, @j] && P1.is_pair(without_3(hand)) -> true
      [c1, c2, c3, c4] == [@j, @j, @j, @j] -> true
      true -> false
    end
  end

  def is_four_of_a_kind([_c0, _c1, c2, c3, c4] = hand) do
    cond do
      P1.is_four_of_a_kind(hand) -> true
      c4 == @j && P1.is_three_of_a_kind(without_1(hand)) -> true
      [c3, c4] == [@j, @j] && P1.is_pair(without_2(hand)) -> true
      [c2, c3, c4] == [@j, @j, @j] -> true
      true -> false
    end
  end

  def is_full_house([_c0, _c1, _c2, c3, c4] = hand) do
    cond do
      P1.is_full_house(hand) -> true
      c4 == @j && P1.is_two_pairs(without_1(hand)) -> true
      c4 == @j && P1.is_three_of_a_kind(without_1(hand)) -> true
      [c3, c4] == [@j, @j] && P1.is_pair(without_2(hand)) -> true
      true -> false
    end
  end

  def is_three_of_a_kind([_c0, _c1, _c2, c3, c4] = hand) do
    cond do
      P1.is_three_of_a_kind(hand) -> true
      c4 == @j && P1.is_pair(without_1(hand)) -> true
      [c3, c4] == [@j, @j] -> true
      true -> false
    end
  end

  def is_two_pairs([_c0, _c1, _c2, _c3, c4] = hand) do
    cond do
      P1.is_two_pairs(hand) -> true
      c4 == @j && P1.is_pair(without_1(hand)) -> true
      true -> false
    end
  end

  def is_pair([_c0, _c1, _c2, _c3, c4] = hand) do
    cond do
      P1.is_pair(hand) -> true
      c4 == @j -> true
      true -> false
    end
  end

  def val(hand) do
    m_hand = P1.remap(hand, @j)
    s_hand = m_hand |> Enum.sort() |> Enum.reverse()

    cond do
      is_five_of_a_kind(s_hand) -> [?7 | m_hand]
      is_four_of_a_kind(s_hand) -> [?6 | m_hand]
      is_full_house(s_hand) -> [?5 | m_hand]
      is_three_of_a_kind(s_hand) -> [?4 | m_hand]
      is_two_pairs(s_hand) -> [?3 | m_hand]
      is_pair(s_hand) -> [?2 | m_hand]
      true -> [?1 | m_hand]
    end
  end

  def run(filename) do
    for [hand, bid] <- P1.parse_file(filename) do
      [hand: hand, val: val(hand), bid: bid]
    end
    |> Enum.sort_by(& &1[:val])
    |> Enum.with_index(1)
    |> Enum.map(fn {hand_data, idx} -> idx * hand_data[:bid] end)
    |> Enum.sum()
    |> IO.puts()
  end
end

# P1.run("sample.txt")
# P1.run("input.txt")
# P2.run("sample.txt")
P2.run("input.txt")
