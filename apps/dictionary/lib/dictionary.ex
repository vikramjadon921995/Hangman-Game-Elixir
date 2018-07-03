defmodule Dictionary do
  use Agent, restart: :temporary

  @words ["elixir", "ruby", "erlang", "python", "java"]

  def start_link(_optns) do
    Agent.start_link(fn -> words() end)
  end

  def words do
    body = body_of_file(File.read("#{File.cwd!}/words"))
    words_from_file = String.split(body, " ")
    case length(words_from_file) == 0 do
      true -> @words
      _ -> words_from_file
    end
  end

  def fetch_word(dictionary) do
    Agent.get(dictionary, &Enum.random(&1))
  end

  def body_of_file({:ok, body}) do
    body
  end

  def body_of_file({:error, _body}) do
    ""
  end
end
