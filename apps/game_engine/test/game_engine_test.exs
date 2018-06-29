defmodule GameEngineTest do
  use ExUnit.Case

  doctest GameEngine

  import Mock

  describe "make_a_guess" do
    test "no more guesses allowed" do
      with_mock GameEngine,
        [
          init: fn(:ok) -> {:ok, %{word: "java", user_word: "____", guesses: 0, won: nil, lost: nil, matched_count: 0}} end
        ]
      do
        {:ok, engine} = GameEngine.start_link([])
        message = GameEngine.make_a_guess(engine, 'a')
        assert message == "You lost!"
      end
    end
  end
end
