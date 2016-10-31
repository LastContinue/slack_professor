defmodule SlackProfessor.Pokerap do
  @moduledoc """
    GenServer that makes calls to Pokeapi via Pokerap.

    Is used as a worker for Poolboy
  """
  use GenServer
  alias Pokerap.Ez, as: Api
  alias SlackProfessor.Env, as: Env
  alias SlackProfessor.Text, as: Text

  #Public Facing

  @doc """
  Convienience for calling :gen_server.start_link for this module
  """
  def start_link(opts) do
    :gen_server.start_link(__MODULE__,opts, [])
  end

  @doc """
  Initiates :gen_server.call to get API data
  """
  def fetch(pid, command, pokemon) do
    :gen_server.call(pid, {:fetch, command, pokemon}, Env.timeout())
  end

  #GenServer

  def init(opts) do
    {:ok, opts}
  end

  def handle_call({:fetch, command, pokemon}, _from, state) do
    {status, message} = parse_command(command, pokemon)
    {:reply, {status, message}, state}
  end

  #Private

  #Parses command passed in from users
  defp parse_command(command, pokemon) do
    case command do
      ["show"|_] ->
        show_me(pokemon)
      ["tell"|_] ->
        tell_me(pokemon)
      ["what","type"|_] ->
        type_me(pokemon)
      ["evolution"|_] ->
        evolution(pokemon)
      _ -> {:error, Text.unable_to_parse()}
    end
  end

  #Makes API call to get Pokemon's evolution
  defp evolution(pokemon) do
    format_fn = fn evolution ->
      "_#{pokemon}'s_ evolution chain is something like ...\n"<>Enum.join(evolution, " -> ")
    end
    format_results(Api.evolution(pokemon), format_fn)
  end

  #Makes API call to get Pokemon sprites
  defp show_me(pokemon) do
    format_fn = fn images ->
      "_#{pokemon}_ looks like ...\n"<>
      "#{images["front_default"]} #{images["back_default"]}"
    end
    format_results(Api.images(pokemon), format_fn)
  end

  #Makes API call to get flavor text
  defp tell_me(pokemon) do
    format_fn = fn flavors ->
      {pokedex, flavor_text} = Enum.random(flavors)
      "Let's see what I can find about _#{pokemon}_ ...\n"<>
      "From *Pokemon #{String.capitalize(pokedex)}* :\n \"#{String.replace(flavor_text, "\n", " ")}\""
    end
    format_results(Api.flavor_text(pokemon), format_fn)
  end

  #Makes API call to get type(s) of Pokemon
  defp type_me(pokemon) do
    format_fn = fn types ->
      "_#{pokemon}_ is type(s) of...\n #{Enum.join(types, ", ")}"
    end
    format_results(Api.types(pokemon), format_fn)
  end

  defp format_results(results, format_fn) do
    case results do
      {:ok, result} ->
        {:ok, format_fn.(result)}
      {:error, 404} ->
        {:ok, Text.missing()}
      {:error, :timeout} ->
        {:error, Text.timeout()}
      _ ->
        {:error, Text.unknown_issue()}
    end
  end

end
