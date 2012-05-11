# Myna Ruby/EventMachine Client

This is a Ruby client for the v1 [Myna](http://mynaweb.com) API, using EventMachine for asychronous goodness. Tested in Ruby 1.9.2

## Installation

`gem install myna_eventmachine`

## Core Concepts

There are three issues we want to solve with this client:

1. We want requests to Myna to be processed in the background, so we don't block your application while talking to Myna. Myna is fast but network latency can easily add a few hundred ms.
2. We don't want to use a thread-per-request model, as this will tie up too many resources on busy sites
3. We don't want you to have to write callback-spaghetti code.

The first two issues mandate we use an asynchronous system, namely [EventMachine](http://eventmachine.rubyforge.org/). To solve the final issue the API uses
[futures](http://en.wikipedia.org/wiki/Futures_and_promises). Instead of asking you to give us a callback, we return a `Future`. A future is a value that will be ready in the future. This is, it's a proxy for a value that we'll compute when the request to Myna has returned. We can make a request, and later on when we need the value call the `get` method  on the futre. This method will block if the request hasn't returned yet. If the request has returned, we'll get the value straight away. This way we can ensure we block for as little time as possible.

Here's an example. Say we want to get a suggestion from Myna:

```ruby
require 'myna'

future = Myna::Experiment('<uuid>').suggest()
```

The future will give us the suggestion, when it's ready. At some later point we'll want that suggestion:

```ruby
future.get
```

If that value isn't ready, we'll block waiting for it. Otherwise, we'll carry on without pausing.

That's all there is to using futures!

## API

The API is divided into two parts: a simple API for doing suggestions and rewards, and a more complex part for calling the API endpoints that require authentication. If you don't already use EventMachine you should also be aware of `run` and `stop`.

### Running and Stopping

If you don't already use EventMachine you need to start it.

#### Myna.run

If you don't currently use EventMachine, you must start it before the Myna API will work. To do this call `Myna.run`. It returns a future which will be ready when EventMachine is running. It is safe to call this if EventMachine is already running.

##### Example

```ruby
Myna.run.get # Wait till Myna is ready
```

#### Myna.stop

Stops EventMachine. Returns nothing. Calling this is entirely optional.

### Suggestions and Rewards

If you just want to make suggestions and rewards the following API will do.

#### Experiment#new(uuid)

Constructs an `Experiment` given a string UUID.

#### Experiment#suggest

Asks for a suggestion. Returns a future of a suggestion. A suggestion has two attributes:

- `choice`, a string representing the choice Myna suggests
- `token`, a string representing the token you must pass to `reward`

#### Experiment#reward(token, [amount])

Rewards a suggestion. Token is a string, and the optional amount is a number between 0 and 1.

#### Example

```ruby
expt = Myna::Experiment.new('45923780-80ed-47c6-aa46-15e2ae7a0e8c')
suggestion = expt.suggest.get
puts("Choice is #{suggestion.choice}")
expt.reward(suggestion.token, 1.0)
```

## Development Notes

The easiest way to install the dependencies is to install [Bundler](http://gembundler.com/) and then run `bundle install`

Rake commands:

- `test` to run the tests.
- `build` to build a Gem
- `install` to install the Gem locally
- `release` to push the Gem to RubyGems


## TODO

- Futures need to handle failures, and need to rigourously trap exceptions and propagate them.
- Some RDoc or equivalent might be useful
