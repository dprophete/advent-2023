#!/usr/bin/env elixir

# DSL:
#   modules:
#     {:broadcaster, dests} -> dests = array of names
#     {:flip, dests} -> dests = array of names
#     {:conj, inputs, dests} -> inputs, dests = array of names
#
#   states:
#     :broadcaster -> :nada
#     :flip -> :on | :off
#     :conj -> map: input -> :low | :high
#
#   signals:
#     {input, :low | :high, dest}
defmodule P1 do
  def get_dest(type) do
    case type do
      {:flip, dests} -> dests
      {:conj, _, dests} -> dests
      {:broadcaster, dests} -> dests
    end
  end

  def get_conj_inputs(name, machine) do
    machine
    |> Enum.filter(fn {_, type} -> name in get_dest(type) end)
    |> Enum.map(fn {name, _} -> name end)
  end

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
    for {name, type} <- machine, into: %{} do
      case type do
        {:conj, [], dests} -> {name, {:conj, get_conj_inputs(name, machine), dests}}
        _ -> {name, type}
      end
    end
  end

  def signals_for_dests(input, pulse, dests) do
    Enum.map(dests, fn dest -> {input, pulse, dest} end)
  end

  def send_signal(machine, states, {input, pulse, dest}) do
    # IO.inspect("[DDA] processing signal to #{dest}: #{inspect(signal)}")
    dest_mod = Map.get(machine, dest)
    dest_state = Map.get(states, dest)

    {new_dest_state, new_signals} =
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
            case Map.get(dest_state, input) do
              :low -> Map.put(dest_state, input, :high)
              :high -> Map.put(dest_state, input, :low)
            end

          {dest_state,
           case Enum.all?(dest_state, fn {_, value} -> value == :high end) do
             true -> signals_for_dests(dest, :low, dests)
             false -> signals_for_dests(dest, :high, dests)
           end}
      end

    new_states = Map.put(states, dest, new_dest_state)
    {new_states, new_signals}
  end

  def send_signals(_machine, states, nb_lows, nb_highs, []), do: {states, nb_lows, nb_highs}

  def send_signals(machine, states, nb_lows, nb_highs, [signal | signals]) do
    # IO.puts("")
    {new_states, new_signals} = send_signal(machine, states, signal)
    # IO.inspect("[DDA] new states #{inspect(new_states)}")
    # IO.inspect("[DDA] need to send more signals #{inspect(new_signals)}")

    {_, pulse, _} = signal

    {nb_lows, nb_highs} =
      case pulse do
        :low -> {nb_lows + 1, nb_highs}
        :high -> {nb_lows, nb_highs + 1}
      end

    send_signals(machine, new_states, nb_lows, nb_highs, signals ++ new_signals)
  end

  def run(filename) do
    machine = parse_file(filename)

    start_states =
      for {name, type} <- machine, into: %{} do
        {name,
         case type do
           {:flip, _} -> :off
           {:conj, inputs, _} -> for input <- inputs, into: %{}, do: {input, :low}
           {:broadcaster, _} -> :nada
         end}
      end

    IO.puts("\n--- machine for #{filename} ---")
    machine |> Enum.each(fn {name, type} -> IO.inspect({name, type}) end)
    # IO.inspect(start_states, label: "[DDA] start_states")

    {_, nb_lows, nb_highs} =
      for _i <- 1..1000, reduce: {start_states, 0, 0} do
        {states, nb_lows, nb_highs} ->
          send_signals(machine, states, nb_lows, nb_highs, [{"button", :low, "broadcaster"}])
      end

    IO.inspect(nb_lows, label: "[DDA] nb_lows")
    IO.inspect(nb_highs, label: "[DDA] nb_highs")
    IO.inspect(nb_lows * nb_highs, label: "[DDA] nb_lows * nb_highs")
  end
end

defmodule P2 do
end

defmodule P do
  def start() do
    Cache.setup()
    P1.run("sample.txt")
    P1.run("sample2.txt")
    P1.run("input.txt")
    # P2.run("sample.txt")
    # P2.run("input.txt")
  end

  # sample: 32000000
  # sample2: 11687500
  # input: 831459892 -> it says it is too low
end
