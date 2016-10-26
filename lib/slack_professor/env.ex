defmodule SlackProfessor.Env do
  @moduledoc """
  Place to retrieve values set in config.
  """

  @doc """
  Returns value for response timeout set in config. Value is in miliseconds

  Is set by `config :slack_professor, timeout:`
  """
  def timeout do
    Application.get_env(:slack_professor, :timeout, 30_000)
  end

  @doc """
  Returns value for ETS cache duration set in config. Value is in seconds

  Is set by `config :slack_professor, cache_duration:`
  """
  def cache_duration do
    Application.get_env(:slack_professor, :cache_duration, 86400)
  end

  @doc """
  Returns value for Poolboy pool size

  Is set by `config :slack_professor, :pool_size:`
  """
  def pool_size do
     Application.get_env(:slack_professor, :pool_size, 5)
  end
  @doc """
  Returns value for Poolboy overflow

  Is set by `config :slack_professor, :pool_overflow:`
  """
  def pool_overflow do
    Application.get_env(:slack_professor, :pool_overflow, 1)
  end

end
