#!/usr/bin/env elixir

# DSL:
#   module types:
#     {:broadcaster, dests} -> dests = array of names
#     {:flip, dests} -> dests = array of names
#     {:conj, inputs, dests} -> inputs, dests = array of names
#
#   state for modules:
#     :broadcaster -> :nada
#     :flip -> :on | :off
#     :conj -> map: input -> :low | :high
#
#   signals:
#     {input, pulse, dest}
#
#   pulse:
#     :low | :high
#
#  machine: map: mod name -> mod type
#  states: map: mod name -> mod state

defmodule P1 do
  # --------------------------------------------------------------------------------
  # - parsing
  # --------------------------------------------------------------------------------

  def parse_file(filename) do
    # first pass, get name and dests
    machine =
      for line <- File.read!(filename) |> String.split("\n", trim: true), into: %{} do
        [mod, dests] = String.split(line, " -> ", trim: true)
        dests = String.split(dests, ", ", trim: true)
        potential_name = String.slice(mod, 1, String.length(mod))

        cond do
          String.first(mod) == "%" -> {potential_name, {:flip, dests}}
          String.first(mod) == "&" -> {potential_name, {:conj, [], dests}}
          mod == "broadcaster" -> {mod, {:broadcaster, dests}}
        end
      end

    # now get the inputs for the conjonctions
    machine =
      for {name, type} <- machine, into: %{} do
        case type do
          {:conj, [], dests} -> {name, {:conj, get_conj_inputs(name, machine), dests}}
          _ -> {name, type}
        end
      end

    start_states =
      for {name, type} <- machine, into: %{} do
        {name,
         case type do
           {:flip, _} -> :off
           {:conj, inputs, _} -> for input <- inputs, into: %{}, do: {input, :low}
           {:broadcaster, _} -> :nada
         end}
      end

    {machine, start_states}
  end

  def get_dests(mod_type) do
    case mod_type do
      {:flip, dests} -> dests
      {:conj, _, dests} -> dests
      {:broadcaster, dests} -> dests
      nil -> []
    end
  end

  def get_conj_inputs(name, machine) do
    machine
    |> Enum.filter(fn {_, type} -> name in get_dests(type) end)
    |> Enum.map(fn {name, _} -> name end)
  end

  # --------------------------------------------------------------------------------
  # - running
  # --------------------------------------------------------------------------------

  # create signals for all dests
  def signals_for_dests(input, pulse, dests) do
    Enum.map(dests, fn dest -> {input, pulse, dest} end)
  end

  # send signal from input to dest with pulse
  # return: {new_states, new_signals}
  def send_signal(machine, states, {input, pulse, dest}) do
    dest_mod = Map.get(machine, dest)
    dest_state = Map.get(states, dest)

    {new_dest_state, new_signals_to_send} =
      case dest_mod do
        nil ->
          {dest_state, []}

        {:broadcaster, dests} ->
          {dest_state, signals_for_dests(dest, pulse, dests)}

        {:flip, dests} ->
          case pulse do
            :high ->
              {dest_state, []}

            :low ->
              case dest_state do
                :on -> {:off, signals_for_dests(dest, :low, dests)}
                :off -> {:on, signals_for_dests(dest, :high, dests)}
              end
          end

        {:conj, _, dests} ->
          dest_state =
            Map.put(dest_state, input, pulse)

          {dest_state,
           case Enum.all?(dest_state, fn {_, value} -> value == :high end) do
             true -> signals_for_dests(dest, :low, dests)
             false -> signals_for_dests(dest, :high, dests)
           end}
      end

    new_states = Map.put(states, dest, new_dest_state)
    {new_states, new_signals_to_send}
  end

  # we are done 
  def send_signals(_machine, states, nb_lows, nb_highs, []), do: {states, nb_lows, nb_highs}

  # send signals
  # return: {new_states, nb_lows, nb_highs}
  def send_signals(machine, states, nb_lows, nb_highs, [signal | signals]) do
    {new_states, new_signals} = send_signal(machine, states, signal)

    {_, pulse, _} = signal

    {nb_lows, nb_highs} =
      case pulse do
        :low -> {nb_lows + 1, nb_highs}
        :high -> {nb_lows, nb_highs + 1}
      end

    send_signals(machine, new_states, nb_lows, nb_highs, signals ++ new_signals)
  end

  def run(filename) do
    {machine, start_states} = parse_file(filename)

    IO.puts("\n--- machine for #{filename} ---")
    machine |> Enum.each(&IO.inspect/1)

    IO.puts("\n--- start states ---")
    start_states |> Enum.each(&IO.inspect/1)

    IO.puts("\n--- results ---")

    {_, nb_lows, nb_highs} =
      for _i <- 1..1000, reduce: {start_states, 0, 0} do
        {states, nb_lows, nb_highs} ->
          send_signals(machine, states, nb_lows, nb_highs, [{"button", :low, "broadcaster"}])
      end

    IO.puts("nb_lows #{nb_lows}, nb_highs #{nb_lows} -> product #{nb_lows * nb_highs}")
  end
end

defmodule P2 do
  # we are done 
  def send_signals(_machine, states, count, data, []), do: {states, count, data}

  # send signals
  # return: {new_states, nb_lows, nb_highs}
  def send_signals(machine, states, count, data, [signal | signals]) do
    {input, pulse, dest} = signal
    dest_mod = Map.get(machine, dest)

    data =
      if "rx" in P1.get_dests(dest_mod) and pulse == :high do
        Map.update(data, input, [], fn counts_for_data -> [count | counts_for_data] end)
      else
        data
      end

    {new_states, new_signals} = P1.send_signal(machine, states, signal)

    send_signals(machine, new_states, count, data, signals ++ new_signals)
  end

  def press_until_rx_low(machine, states, count, data) do
    {states, count, data} =
      send_signals(machine, states, count, data, [{"button", :low, "broadcaster"}])

    enough_data =
      data |> Enum.all?(fn {_, counts} -> Enum.count(counts) > 5 end)

    if enough_data do
      data
    else
      press_until_rx_low(machine, states, count + 1, data)
    end
  end

  def run(filename) do
    {machine, start_states} = P1.parse_file(filename)

    {_, type} = machine |> Enum.find(fn {_, type} -> "rx" in P1.get_dests(type) end)
    {:conj, inputs_to_check, _} = type
    data = for input <- inputs_to_check, into: %{}, do: {input, []}

    data = press_until_rx_low(machine, start_states, 0, data)

    cycles =
      data
      |> Map.values()
      |> Enum.map(fn counts ->
        [l1, l2, l3, l4 | _] = counts

        case l1 - l2 == l2 - l3 && l2 - l3 == l3 - l4 do
          true -> l1 - l2
          _ -> nil
        end
      end)

    if Enum.any?(cycles, fn x -> x == nil end) do
      IO.puts("error, can't detect cycles")
    else
      IO.inspect(cycles, label: "[DDA] cycles")

      lcm = Enum.reduce(cycles, &Utils.lcm/2)
      IO.inspect(lcm, label: "[DDA] got cycles, lcm")
    end
  end
end

defmodule P do
  def start() do
    Cache.setup()
    # P1.run("sample.txt")
    # P1.run("sample2.txt")
    # P1.run("input.txt")
    # P2.run("sample.txt")
    P2.run("input.txt")
  end

  # sample: 32000000 -> good
  # sample2: 11687500 -> good
  # input: 831459892 ->  not good
end
