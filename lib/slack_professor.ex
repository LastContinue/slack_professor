defmodule SlackProfessor do
  use Application

  alias SlackProfessor.Env, as: Env

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    poolboy_config = [
          {:name, {:local, :pokerap_pool}},
          {:worker_module, SlackProfessor.Pokerap},
          {:size, Env.pool_size},
          {:max_overflow, Env.pool_overflow}
        ]

    # Define workers and child supervisors to be supervised
    children = [
      :poolboy.child_spec(:pokerap_pool, poolboy_config, []),
      worker(SlackProfessor.Cache, []),
      supervisor(Task.Supervisor, [[name: :reply_supervisor]]),
    ]

    opts = [strategy: :one_for_one, name: SlackProfessor.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_bot(token) do
    Slack.Bot.start_link(SlackProfessor.Bot, [], token)
  end
end
