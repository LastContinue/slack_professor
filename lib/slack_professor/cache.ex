defmodule SlackProfessor.Cache do
  @moduledoc """
  GenServer that writes request/response pairs to ETS. Acts as a cache
  """
  use GenServer

  alias SlackProfessor.Env, as: Env

  #Public Facing

  @doc """
  Convienience for calling :gen_server.start_link for this module
  """
  def start_link do
    #we should only have one of these, so we can get away with this name
    GenServer.start_link(__MODULE__, :pokedex, name: __MODULE__)
  end

  @doc """
  Inserts key value pair into ETS
  """
  def insert({key, value}) do
    duration = Env.cache_duration()
    expiration = :os.system_time(:seconds) + duration
    GenServer.cast(__MODULE__, {:insert, key, value, expiration})
  end

  @doc """
  Inserts key value with expiration into ETS
  """
  def insert({key, value, expiration}) do
    GenServer.cast(__MODULE__, {:insert, key, value, expiration})
  end

  @doc """
  Looks up data via key in ETS
  """
  def lookup(key) do
    GenServer.call(__MODULE__, {:lookup, key})
  end

#GenServer

  def init(table_name) do
    table = :ets.new(table_name, [:named_table])
    {:ok, table}
  end

  def handle_cast({:insert, key, value, expiration}, pokedex) do
    :ets.insert(pokedex, {key, value, expiration})
    {:noreply, pokedex}
  end

  def handle_call({:lookup, key}, _from, pokedex) do
    message = case :ets.lookup(pokedex, key) do
      [{^key, message, expiration}] ->
        case :os.system_time(:seconds) > expiration  do
          false -> {:ok, message, expiration}
          true ->
            :ets.delete(pokedex, key)
            :error
        end
      [] -> :error
    end
    {:reply, message, pokedex}
  end

end
