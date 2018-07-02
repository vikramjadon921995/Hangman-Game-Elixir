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

  def guesses_allowed(engine, number_of_guesses) do
    GenServer.call(engine, {:guesses_allowed, number_of_guesses})
  end

  def state_of_engine(engine) do
    GenServer.call(engine, {:state_of_engine})
  end

  ## Server API

  def init(:ok) do
    {:ok, dictionary} = DynamicSupervisor.start_child(DictionarySupervisor, Dictionary)
    word = Dictionary.fetch_word(dictionary)
    {:ok, %{word: word, user_word: initial_user_word(word), guesses: max_guesses(), won: nil, lost: nil, matched_count: 0}}
  end

  def handle_call({:state_of_engine}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:make_a_guess, guess}, _from, state) do
    case more_guesses_allowed(state[:guesses]) do
      true ->
        case String.contains?(state[:user_word], guess |> String.trim("\n")) do
          false ->
            user_word = state[:word] |> String.graphemes |> Enum.with_index |> Enum.map(fn({_x, index}) -> reveal_characters(guess, index, state[:user_word], state[:word]) end)

            state = Map.put(state, :user_word, Enum.join(user_word, ""))
            state = Map.put(state, :guesses, state[:guesses] - 1)

            case user_word |> Enum.any?(&(&1 == "_")) do
              false ->
                state = Map.put(state, :won, true)
                {:reply, {:won, "Congratulations, you Won!"}, state}
              _ ->
                case String.contains?(state[:word], guess |> String.trim("\n")) do
                  true -> {:reply, {:good_guess, "Good Guess!"}, state}
                  _ -> {:reply, {:bad_guess, "Bad Guess!"}, state}
                end
            end
          _ ->
            {:reply, {:already_guessed, "Already guessed, please try again!"}, state}
        end
      _ ->
        state = Map.put(state, :lost, true)
        {:reply, {:lost, "Sorry, you lost!"}, state}
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

  defp max_guesses do
    @guesses
  end

  defp more_guesses_allowed(guesses) do
    case guesses > 0 do
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
