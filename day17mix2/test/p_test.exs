defmodule PTest do
  use ExUnit.Case
  doctest P

  test "P.start" do
    P.start()
  end
end
