defmodule Utils do
  # a base transpose function
  def transpose(rows) do
    rows
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  def lcm(a, b) do
    div(a * b, Integer.gcd(a, b))
  end
end
