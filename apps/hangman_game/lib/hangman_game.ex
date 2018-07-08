defmodule HangmanGame do
  use Application

  def start(_type, _args) do
    GameSupervisor.start_link([])
    TextClient.start("", "")
  end
end
