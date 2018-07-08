defmodule TextClient do
  use Application

  def start(_type, _args) do
    #GameSupervisor.start_link([])
    start_game()
    {:ok, self()}
  end

  defp start_game() do
    IO.puts ""
    IO.puts "Welcome to hangman game!"
    {:ok, engine} = DynamicSupervisor.start_child(GameEngineSupervisor, GameEngine)
    #{:ok, engine} = GameEngine.start_link([])
    play(engine)
  end

  defp play(engine) do
    state = GameEngine.state_of_engine(engine)
    IO.puts ""
    IO.puts "Word: #{state[:word]}"
    IO.puts "#{state[:guesses]} guesses remaining."
    IO.puts "UserWord: #{state[:user_word]}"
    guess = IO.gets "Make a guess : "
    guess = String.downcase(guess)
    {round_result, message} = GameEngine.make_a_guess(engine, guess)
    IO.puts "Message: #{message}"
    unless round_result == :won || round_result == :lost do
      play(engine)
    end
  end
end
