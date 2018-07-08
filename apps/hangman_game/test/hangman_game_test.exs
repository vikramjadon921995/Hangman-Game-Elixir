defmodule HangmanGameTest do
  use ExUnit.Case
  doctest HangmanGame

  test "greets the world" do
    assert HangmanGame.hello() == :world
  end
end
