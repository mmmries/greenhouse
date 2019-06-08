defmodule GreenhouseTest do
  use ExUnit.Case
  doctest Greenhouse

  test "greets the world" do
    assert Greenhouse.hello() == :world
  end
end
