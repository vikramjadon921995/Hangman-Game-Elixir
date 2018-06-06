defmodule DictionaryTest do
  use ExUnit.Case
  doctest Dictionary

  test "fetches a word from the dictionary" do
    {:ok, dictionary} = Dictionary.start_link([])
    words = Dictionary.words
    word = Dictionary.fetch_word(dictionary)
    assert Enum.member?(words, word) == true
  end
end
