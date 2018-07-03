defmodule GameEngine do
  use GenServer

  @guesses 5

  ## Client API

  def guesses, do: @guesses

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def make_a_guess(engine, guess) do
    GenServer.call(engine, {:make_a_guess, guess})
  end

  def state_of_engine(engine) do
    GenServer.call(engine, {:state_of_engine})
  end

  ## Server API

  def init(:ok) do
    {:ok, dictionary} = DynamicSupervisor.start_child(DictionarySupervisor, Dictionary)
    word = Dictionary.fetch_word(dictionary)
    word = String.downcase(word)
    {:ok, %{word: word, user_word: initial_user_word(word), guesses: max_guesses(), won: nil, lost: nil, matched_count: 0}}
  end

  def handle_call({:state_of_engine}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:make_a_guess, guess}, _from, state) do
    chances_remaining(more_guesses_allowed(state[:guesses]), guess, state)
  end

  defp chances_remaining(true, guess, state) do
    already_guessed = String.contains?(state[:user_word], guess |> String.trim("\n"))
    already_guessed_letter(already_guessed, guess, state)
  end

  defp chances_remaining(false, _guess, state) do
    state = Map.put(state, :lost, true)
    {:reply, {:lost, "Sorry, you lost!"}, state}
  end

  defp already_guessed_letter(true, _guess, state) do
    {:reply, {:already_guessed, "Already guessed, please try again!"}, state}
  end

  defp already_guessed_letter(false, guess, state) do
    user_word = extract_user_word(state, guess)
    state = Map.put(state, :user_word, Enum.join(user_word, ""))
    user_won(Enum.any?(user_word, &(&1 == "_")), state, guess)
  end

  defp user_won(true, state, guess) do
    case String.contains?(state[:word], guess |> String.trim("\n")) do
      true -> {:reply, {:good_guess, "Good Guess!"}, state}
      _ ->
        state = Map.put(state, :guesses, state[:guesses] - 1)
        {:reply, {:bad_guess, "Bad Guess!"}, state}
    end
  end

  defp user_won(false, state, _guess) do
    state = Map.put(state, :won, true)
    {:reply, {:won, "Congratulations, you Won!"}, state}
  end

  defp extract_user_word(state, guess) do
    state[:word] |> String.codepoints |> Enum.with_index |> Enum.map(fn({_x, index}) -> reveal_characters(guess |> String.trim("\n"), index, state[:user_word], state[:word]) end)
  end

  defp initial_user_word(word) do
    String.length(word) |> (&String.duplicate("_", &1)).()
  end

  defp max_guesses do
    @guesses
  end

  defp more_guesses_allowed(guesses) do
    case guesses > 1 do
      true ->
        true
      _ ->
        false
    end
  end

  defp reveal_characters(char, index, str, original_str) do
    if String.at(str, index) == "_" do
      case String.at(original_str, index) == char do
      	true -> char
      	_ -> "_"
      end
    else
      String.at(str, index)
    end
  end
end
