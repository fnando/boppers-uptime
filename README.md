# Boppers::Uptime

A [bopper](https://github.com/fnando/boppers) to check if your sites are online.

[![Gem](https://img.shields.io/gem/v/boppers-uptime.svg)](https://rubygems.org/gems/boppers-uptime)
[![Gem](https://img.shields.io/gem/dt/boppers-uptime.svg)](https://rubygems.org/gems/boppers-uptime)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "boppers-uptime"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install boppers-uptime

## Usage

```ruby
Boppers.configure do |config|
  config.boppers << Boppers::Uptime.new(name: "Portfolio", url: "https://portfolionow.co/")
end
```

Available options:

- `name:` The target monitoring's name. Required.
- `url`: The url that will be monitored. Required.
- `status`: The expected HTTP status (can be an array of numbers). Default to
  `200`.
- `contain`: The returned URL must include that given text (may also be a
  regular expression).
- `min_failures`: Only notify after reaching this threadshold. Defaults to `2`.
- `interval`: The polling interval. Defaults to `30` (seconds).
- `timezone:` The timezone for displaying dates. Defaults to `Etc/UTC`.
- `format`: How the time will be formatted. Defaults to `%Y-%m-%dT%H:%M:%S%:z`
  (e.g. `2017-10-18T19:31:29-02:00`).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/fnando/boppers-uptime. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Boppers project’s codebases, issue trackers, chat
rooms and mailing lists is expected to follow the
[code of conduct](https://github.com/fnando/boppers-uptime/blob/main/CODE_OF_CONDUCT.md).
