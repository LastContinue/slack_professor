defmodule SlackProfessor.Text do

  def timeout() do
    get_text(:timeout, "My database is slow right now, try again later")
  end

  def missing() do
    get_text(:missing, "I'm not sure that's an actual Pokemon...")
  end

  def unknown_issue() do
    get_text(:unknown_issue, "My database thought that was a Pokemon, the results are buggy...try something else")
  end

  def unable_to_parse() do
    get_text(:unable_to_parse, "I'm not sure what you mean...")
  end

  def looks_like() do
    get_text(:looks_like, "looks like")
  end

  def get_text(key, default) do
    env = Application.get_env(:slack_professor, :messages)[key]
    if env, do: env, else: default
  end

end
