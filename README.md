# Myna Ruby/EventMachine Client

This is a Ruby client for the v1 [Myna](http://mynaweb.com) API, using EventMachine for asychronous goodness. Tested in Ruby 1.9.2

## Installation

`gem install myna_eventmachine`

## Usage

You can get a suggestion from Myna without authorizing:

```ruby
Myna.run.get # Start EventMachine if it isn't already running
expt = Myna.experiment('45923780-80ed-47c6-aa46-15e2ae7a0e8c')
suggestion = expt.suggest.get
# suggestion has two attributes: choice and token
# suggestion.choice is a string, the choice made by Myna
# suggestion.token is a string, the token you send back to Myna when you reward
puts("Choice is #{suggestion.choice}")
expt.reward(suggestion.token, 1.0).get
```

To create an experiment, add and delete variants, and so on, you must authorize first:

```ruby
myna = Myna.authorize('email', 'password')
# Create an experiment
expt = myna.create('My funky new experiment').get
expt.create_variant('My new variant')
expt.create_variant('My other new variant')
```

For more detail, see [the wiki](https://github.com/myna/ruby-eventmachine-client/wiki)

## Development Notes

The easiest way to install the dependencies is to install [Bundler](http://gembundler.com/) and then run `bundle install`

Rake commands:

- `test` to run the tests.
- `build` to build a Gem
- `install` to install the Gem locally
- `release` to push the Gem to RubyGems. The version number comes from `lib/myna/version.rb`


## TODO

- Some RDoc or equivalent might be useful
