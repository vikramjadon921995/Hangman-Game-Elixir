defmodule GameEngine do
  use GenServer

  @guesses 7

  ## Client API

  def guesses, do: @guesses

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def make_a_guess(engine, guess) do
    GenServer.call(engine, {:make_a_guess, guess})
  end

  def get_user_word(engine) do
    GenServer.call(engine, {:get_user_word})
  end

  ## Server API

  def init(:ok) do
    {:ok, dictionary} = DynamicSupervisor.start_child(DictionarySupervisor, Dictionary)
    word = Dictionary.fetch_word(dictionary)
    {:ok, %{word: word, user_word: initial_user_word(word), guesses: @guesses, won: nil, lost: nil, matched_count: 0}}
  end

  def handle_call({:make_a_guess, guess}, _from, state) do
  end

  def handle_call({:get_user_word}, _from, state) do
    {:reply, state[:user_word], state}
  end

  defp initial_user_word(word) do
    String.length(word) |> (&String.duplicate("_", &1)).()
  end
end
