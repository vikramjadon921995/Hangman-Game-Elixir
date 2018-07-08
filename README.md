# Hangman

This Hangman game is made in elixir.

It is an umbrella application with 4 sub applications.
  1. HangmanGame (Application Entry Point)
  2. TextClient
  3. GameEngine
  4. Dictionary

The processes of each of these are started for every player

Process for dictionary is created only once and every user uses the same process of dictionary
