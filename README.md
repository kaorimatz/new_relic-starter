# NewRelic::Starter

[![Gem](https://img.shields.io/gem/v/new_relic-starter.svg?style=flat-square)](https://rubygems.org/gems/new_relic-starter)
[![Travis](https://img.shields.io/travis/kaorimatz/new_relic-starter.svg?style=flat-square)](https://travis-ci.org/kaorimatz/new_relic-starter)

A library that provides a way to start the New Relic agent in a running process.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'new_relic-starter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install new_relic-starter

## Usage

### Rack

The gem provides a Rack middleware which provides an endpoint to start the New Relic agent.

```ruby
# config.ru
require 'new_relic/starter/rack'
use NewRelic::Starter::Rack
```

By default, the middleware uses the path `/_new_relic/start`:

```
$ curl -s http://localhost:8080/_new_relic/start
Started the New Relic agent.
```

You can specify the path of the endpoint using the `path` option:

```ruby
# config.ru
require 'new_relic/starter/rack'
use NewRelic::Starter::Rack, path: '/foo'
```

If your Rack web server is a pre-forking web server and doesn't load the Rack application before forking, you will need to create a global latch before forking:

```ruby
$latch = NewRelic::Starter::Latch.new

# config.ru
require 'new_relic/starter/rack'
use NewRelic::Starter::Rack, latch: $latch
```

Or you will need to create a latch backed by a file:

```ruby
# config.ru
require 'new_relic/starter/rack'
use NewRelic::Starter::Rack, latch: NewRelic::Starter::Latch.new("/path/to/latch")
```

When a latch is backed by a file, you can also have the middleware start the New Relic agent by writing a single byte 1 to the file:

```sh
$ echo -n -e '\x1' > /path/to/latch
```

### Rails

You can configure Rails to add the Rack middleware to the middleware stack with the default options by requiring `new_relic/starter/rails.rb`:

```ruby
# Gemfile
gem 'new_relic-starter', require: 'new_relic/starter/rails'
```

If you want to specify options, you can manually configure the middleware:

```ruby
# config/initializers/new_relic_starter.rb
Rails.application.config.middleware.use NewRelic::Starter::Rack, path: '/foo'
```

### Resque

If your Resque worker forks before processing a job, you can add a hook to start the New Relic agent before forking:

```ruby
starter = NewRelic::Starter.new(NewRelic::Starter::Latch.new("/path/to/latch"))
Resque.before_fork do
  starter.start(dispatcher: :resque, start_channel_listener: true)
end
```

Then you can have the starter start the New Relic agent by writing a single byte 1 to the file backing the latch:

```sh
$ echo -n -e '\x1' > /path/to/latch
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kaorimatz/new_relic-starter.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

The idea of starting the New Relic agent using the Rack middleware is borrowed from [partiarelic](https://github.com/wata-gh/partiarelic).
