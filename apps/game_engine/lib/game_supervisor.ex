defmodule GameSupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      {DynamicSupervisor, name: DictionarySupervisor, strategy: :one_for_one},
      {GameEngine, name: GameEngine}
    ]
    Supervisor.init(children, strategy: :one_for_all)
  end
end
