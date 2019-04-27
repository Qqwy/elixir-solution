defmodule SolutionTest do
  use ExUnit.Case
  doctest Solution

  test "greets the world" do
    assert Solution.hello() == :world
  end
end
