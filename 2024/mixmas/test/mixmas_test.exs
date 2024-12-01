defmodule MixmasTest do
  use ExUnit.Case
  doctest Mixmas

  test "greets the world" do
    assert Mixmas.hello() == :world
  end
end
