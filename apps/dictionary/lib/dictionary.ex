defmodule Dictionary do
  use Agent, restart: :temporary

  @words ["elixir", "ruby", "erlang", "python", "java"]

  def words, do: @words

  def start_link(_optns) do
    Agent.start_link(fn -> @words end)
  end

  def fetch_word(dictionary) do
    Agent.get(dictionary, &Enum.random(&1))
  end
end
