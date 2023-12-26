defmodule PTest do
  use ExUnit.Case
  doctest P

  @tag timeout: :infinity
  test "P.start" do
    P.start()
  end
end
