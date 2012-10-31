# Trinidad Sidekiq Extension

Run Sidekiq workers within the Trinidad process.

Inspiration: https://github.com/carlhoerberg/trinidad_threaded_resque_extension

## Installation

Add this line to your application's Gemfile:

    gem 'trinidad_sidekiq_extension', require: false

And then execute:

    $ bundle

Then configure it via config/trinidad.rb:

```ruby
require 'bundler/setup'
Trinidad.configure do |config|
  config.jruby_min_runtimes = 1
  config.jruby_max_runtimes = 1
  ...
  config.web_apps = {
    default = {
      rackup: 'config.ru'
      extensions = {
        sidekiq: {
          arguments: '-c 10 -r ./config/sidekiq'
        }
      }
    }
  }
end
```

## Usage

Start trinidad and enjoy the low memory usage while having high concurrency.

Note that becasue JRuby can't fork you want to have well behaved workers, watch out for memory leakage. Naturally your workers have to be thread safe.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

