# NOTICE
This gem is in a work in progress.  Currently very basic functinality implemented, and not working as expected yet.  TODO includes design and use docs.

# Running the test case

To run the test case locally, you will need to point to a running consul instance.  Tokens/acl support not implemented yet, so it will have to be a consul instance with open anonymous access.  Update bin/test.sh and edit CONSUL_HTTP_ADDR

You will need to have ruby and jq installed and availabe in your path.  I'll make 'bundle install' work as my next task.  Once all gems are installed, you should be able to run bin/test.sh and you will see the json diff with the previous watch data.  The idea will be to push that diff to a data sync, with the first implementation being an amqp exchange.  The work has been slow as I've been sick, so the next update might not be for a week or two.

# ConsulWatchToAmqp

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/ruby_consul_watch`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby_consul_watch'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby_consul_watch

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ruby_consul_watch.
