defmodule TextClient do
  use Application

  def start(_type, _args) do
    IO.puts "Vikram is here!"
    GameSupervisor.start_link([])
  end
end
