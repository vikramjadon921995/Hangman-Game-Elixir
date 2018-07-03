defmodule GameEngineTest do
  use ExUnit.Case, async: false

  doctest GameEngine

  setup do
    state = %{word: "elixir", user_word: "______", guesses: 5, won: nil, lost: nil, matched_count: 0}
    %{state: state}
  end

  describe "make_a_guess" do
    test "no chances remaining", %{state: state} do
      state = Map.put(state, :guesses, 0)
      {:reply, {round_result, message}, result_state} = GameEngine.handle_call({:make_a_guess, "i"}, self(), state)
      assert round_result == :lost
      assert message == "Sorry, you lost!"
      assert result_state[:lost] == true
    end

    test "already guessed letter", %{state: state} do
      state = Map.put(state, :user_word, "__i_i_")
      {:reply, {round_result, message}, result_state} = GameEngine.handle_call({:make_a_guess, "i"}, self(), state)
      assert round_result == :already_guessed
      assert message == "Already guessed, please try again!"
      assert result_state[:guesses] == state[:guesses]
    end

    test "User won", %{state: state} do
      state = Map.put(state, :user_word, "elixir")
      {:reply, {round_result, message}, result_state} = GameEngine.handle_call({:make_a_guess, "a"}, self(), state)
      assert round_result == :won
      assert message == "Congratulations, you Won!"
      assert result_state[:won] == true
    end

    test "Good Guess", %{state: state} do
      assert state[:user_word] == "______"
      {:reply, {round_result, message}, result_state} = GameEngine.handle_call({:make_a_guess, "i"}, self(), state)
      assert round_result == :good_guess
      assert message == "Good Guess!"
      assert result_state[:user_word] == "__i_i_"
      assert result_state[:guesses] == state[:guesses]
    end

    test "Bad Guess", %{state: state} do
      assert state[:user_word] == "______"
      {:reply, {round_result, message}, result_state} = GameEngine.handle_call({:make_a_guess, "a"}, self(), state)
      assert round_result == :bad_guess
      assert message == "Bad Guess!"
      assert result_state[:user_word] == state[:user_word]
      assert result_state[:guesses] == state[:guesses] - 1
    end
  end

  describe "state_of_engine" do
    test "returns state of the engine", %{state: state} do
      {:reply, result_state, modified_state} = GameEngine.handle_call({:state_of_engine}, self(), state)
      assert result_state == state
      assert modified_state == state
    end
  end
end
