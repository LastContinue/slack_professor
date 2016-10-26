# Slack Professor

Slack Bot Application that uses [Pokerap]("https://github.com/LastContinue/Pokerap") to consume [Pokeapi](http://pokeapi.co)

This is an implementation of [Elixir-Slack](https://github.com/BlakeWilliams/Elixir-Slack) that
queries the [http://pokeapi.co/](http://pokeapi.co/) API using [Pokerap]("https://github.com/LastContinue/Pokerap") . To be a responsible citizen, it uses
Poolboy and an ETS cache to keep from hammering the API too hard (they will limit you).

## Installation

~~If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:~~

  1. Add `slack_professor` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:slack_professor, git: "https://github.com/LastContinue/SlackProfessor"}]
    end
    ```

  2. Ensure `slack_professor` is started before your application:

    ```elixir
    def application do
      [applications: [:slack_professor]]
    end
    ```

## Usage
First, you need a Slack Api Token for a bot. You can create this by logging into Slack as an admin, then
going to `apps > custom integrations` and there should be a dialog to make a bot. (Or just Google it, probably more detailed)

Using this token, you can create a bot simply by

    iex(1)> SlackProfessor.Bot.start_link("your_api_token")
    Connected as "<BotName>"

That's it! Your bot should now show up in Slack, and you can invite it to channels, etc.

You can even make multiple bots! This is a good idea if you have multiple Slack orgs because
the bots will share the same connection pool and ETS cache (assuming they are ran in the same process/program)!

#### Side Notes:
You'll notice that this application doesn't actually _create_ the bots, it only contains
the overhead (supervisors, ETS, gen_servers, etc) to support bots. You'll need to create another
application to actually create them (or a long running IEX)

I played around with a few different ways to attempt to combine setting up all of the code
behind the bots, and then creating bots, but it never really felt "right".

Then it hit me: "Maybe this is the 'true' object oriented nature of BEAM?".

If you consider this application as a "class" and another application to start the bots as
the "object", it makes more sense. If you disagree, open an issue or file a PR. I want to learn!

## Interacting With Your bots

So you have a bot, great, now what can it do?

Lets say you have a bot named `ProfessorOak`

`@ProfessorOak tell me about Pikachu` and _viola_ facts about Pikachu!

|Commands| Description |
|--------|-------------|
|"tell me about X"| Gets a random [flavor text](http://pokeapi.co/docsv2/#common-models) for Pokemon (language can be set, see ENV/Configs section)|
|"evolution X"| Gets a very simple evolution chain for a Pokemon|
|"show me X"| Gets two sprites for a Pokemon|
|"what type is X"| Tells the type of a Pokemon|

That's it for now, but there's a bunch more to add (PR's welcomed!)

## ENV/Configs

You can customize some aspects of your bots depending on your needs. All settings have defaults, so they are
**optional**

Please read up on Poolboy
before messing with those settings (I barely understand them)

|  Env  | Desc | Format | Default|
|-------|------|--------|--------|
|`:slack_professor, :timeout`| Timeout for Bot to complete task. Don't set it lower than Pokerap timeout settings| integer (in milliseconds)| 30000 |
| `:slack_professor, :pool_size`| How many Poolboy workers you have (be cool with this)| integer | 5 |
| `:slack_professor, :pool_overflow`| Overflow setting for Poolboy | integer | 1 |
| `:slack_professor, :cache_duration`| How long ETS with cache | integer (in seconds)| 86400 (24 hours) |

Additionally, because this uses [Pokerap](https://github.com/LastContinue/Pokerap), you can set ENV settings from that library as well, See
[https://github.com/LastContinue/Pokerap#env-settings](https://github.com/LastContinue/Pokerap#env-settings)
for full list (I highly recommend setting `:pokerap, :timeout` and `:pokerap, :recv_timeout`)

## What's Next?
* Customized grammar around the responses (this is stubbed, but not finished)
* More interactions!
* Better formatting for interactions
* Testing!
* Smarter Caching (maybe...this is a thorny issue)
