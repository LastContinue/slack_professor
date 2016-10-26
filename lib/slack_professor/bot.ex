defmodule SlackProfessor.Bot do
  use Slack

  def handle_connect(slack, state) do
    IO.puts "Connected as \"#{slack.me.name}\""
    {:ok, state}
  end

  def handle_event(message = %{type: "message", text: text}, slack, state) do
    msg_fn = fn(output) -> send_message(output,message.channel,slack) end
    typing_fn = fn() -> indicate_typing(message.channel, slack) end
    if Regex.run ~r/<@#{slack.me.id}>:?/, text do
      {:ok, _pid} = Task.Supervisor.start_child(:reply_supervisor, fn ->
        reply_to_slack(text,msg_fn,typing_fn)
      end)
    end
    {:ok, state}
  end

  def handle_event(_,_, state), do: {:ok, state}

  defp reply_to_slack(text, msg_fn, typing_fn) do
    {command, pokemon} = parse_text(text)
    {status, message} =
      case SlackProfessor.Cache.lookup(command) do
        {:ok, message, _expiration} -> {:ok, message}
        :error ->
          msg_fn.("Looking up #{pokemon} ...")
          typing_fn.()
          fetch_with_pool(command, pokemon)
      end
    #status can also be :error. Don't cache that!
    if status == :ok do
      SlackProfessor.Cache.insert({command, message})
    end
    msg_fn.(message)
  end

  defp fetch_with_pool(command, pokemon) do
    :poolboy.transaction(
      :pokerap_pool,
      fn(pid) -> SlackProfessor.Pokerap.fetch(pid, command, pokemon) end
    )
  end

  defp parse_text(text) do
    #head should be "@<bots_name>" so can be discarded
    [_bots_name|command] = String.downcase(text)
    |> String.replace(~r/[\p{P}\p{S}]/, "")
    |> String.split(" ")

    #pokemon name should be at the end now
    pokemon = command
    |> List.last
    |> String.capitalize
    #now sure how I feel about this, but it's tidy downstream
    {command, pokemon}
  end

end
