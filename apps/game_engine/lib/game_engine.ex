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

  def guesses_allowed(engine) do
    GenServer.call(engine, {:guesses_allowed, guesses})
  end

  ## Server API

  def init(:ok) do
    {:ok, dictionary} = DynamicSupervisor.start_child(DictionarySupervisor, Dictionary)
    word = Dictionary.fetch_word(dictionary)
    {:ok, %{word: word, user_word: initial_user_word(word), guesses: @guesses, won: nil, lost: nil, matched_count: 0}}
  end

  def handle_call({:make_a_guess, guess}, _from, state) do
    case more_guesses_allowed(guesses) do
      true ->
        case String.contains?(state[:user_word], guess) do
          false ->
            user_word = state[:word] |> String.graphemes |> Enum.with_index |> Enum.map(fn({x, index}) -> reveal_characters(x, index, state[:user_word]) end)  
            state = Map.put(state, :user_word, user_word)
            state = Map.put(state, :guesses, state[:guesses] - 1)
            case user_word |> Enum.any?(&(&1 == "_")) do
              false ->
                state = Map.put(state, :won, true)
                {:reply, "You Won!", state}
              _ ->
                case String.contains?(state[:word], guess) do
                  true -> {:reply, "Good Guess!", state}
                  _ -> {:reply, "Bad Guess!", state}
                end
            end    
          _ ->
            {:reply, "Already guessed, please try again!", state}
        end
      _ ->
        state = Map.put(state, :lost, true)
        {:reply, "You lost!", state}
    end
  end

  def handle_call({:get_user_word}, _from, state) do
    {:reply, state[:user_word], state}
  end

  def handle_call({:guesses_allowed, guesses}, _from, state) do
    {:reply, more_guesses_allowed(guesses), state}
  end

  defp initial_user_word(word) do
    String.length(word) |> (&String.duplicate("_", &1)).()
  end

  defp more_guesses_allowed(guesses) do
    case guesses > 0 do
      true ->
        true
      _ ->
        false
    end
  end

  defp reveal_characters(char, index, str) do
    if String.at(str, index) == "_" do
      case char == "a" do
      	true -> "a"
      	_ -> "_"
      end
    else
      String.at(str, index)
    end
  end
end
