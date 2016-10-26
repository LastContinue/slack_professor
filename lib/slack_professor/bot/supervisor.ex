defmodule SlackProfessor.Bot.Supervisor do
  use Supervisor

  @name SlackProfessor.Bot.Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    children = [
      worker(SlackProfessor.Bot, [])
    ]
    supervise(children, [strategy: :simple_one_for_one])
  end

  def start_bot(key) do
    Supervisor.start_child(@name, [key])
  end

  def stop_bot(pid) do
    Supervisor.terminate_child(@name, pid)
  end

end
