# NOTICE
This gem is in a work in progress.  

TODO:
- Finish basic functionality
- Create documentation
- Write unit tests
- Publish docker image and ruby gem

## Basic functionality
The goal is to create a docker image and a ruby gem that can be tied to a consul watch.  The basic premise is to parse the output of a [consul watch command](https://www.consul.io/docs/commands/watch.html), compare the output to the previous consul watch output, and then send the diff to a destination.  The primary destination at this time is an AMQP topic exchange. To make the gem modular and extensible, the functionality has been broken up into 3 sections; storage, watch_type, and destination.

If we want to do a diff of consul watches, we need to store the previous consul watch json.  This is because consul watches kick off new executions on every change, so we can't store the previous run in memory.  Storage is accomplished with [storage classes](https://github.com/fortman/consul_watcher/blob/master/docs/storage/storage.md).  The purpose of the storage class is to just store and retrieve previous consul watch json.  At this time, backend storage is planned for both local filesystem, and consul kv storage.

The next type of class, is the [watch_type class](https://github.com/fortman/consul_watcher/blob/master/docs/watch_type/watch_type.md).  This maps to the actual consul watch command `--type` flag.  There are two unfortunate things about the way consul watch commands work.  The first is that there is not one consul watch command that can watch for all changes.  Each different type of watch requires its own definition.  It would be nice to specify one watch that can monitor for changes in multiple consul areas.  This is not the case however.  The lack of a single definition bleeds into the next issue, each watch type has a very distinct json format.  For the watch json output, instead of having meta data that describes what type of watch the output represents, it is expected that you already know the format because you have to pass the type to the watch command.  The entire purpose of the watch_type class is to handle the unique json output for each consul watch type.  For every option to the consul watch --type flag, there is a watch_type class.  The one exception to this, is that `key` and `keyprefix` types share the same output, so there is just a `key` watch_type class to represent both.

After the watch_type class handles the data, it will create a json diff between the previous run and the current.  This json diff is the [message](https://github.com/fortman/consul_watcher/blob/master/docs/messages_overview.md) that is sent to the [destinations classes](https://github.com/fortman/consul_watcher/blob/master/docs/destination/destination.md).  The initial implementation will support two destination classes; AMQP topic exchanges, and stdout through [jq](https://stedolan.github.io/jq/).

## Quick start guide
The quickest and easiest way to get started is to follow the [docker quickstart](https://github.com/fortman/consul_watcher/blob/master/docs/docker-quickstart.md).

If you are planning to write your own extension for storage/watch_type/destination, then you can check out the [ruby quickstart](https://github.com/fortman/consul_watcher/blob/master/docs/docker-quickstart.md).

## Development
Please read the [general design documentation](https://github.com/fortman/consul_watcher/blob/master/docs/general_design.md).  More detailed architectual documenation will be created in the future.  All development [build and test commands](https://github.com/fortman/consul_watcher/blob/master/docs/rake_tasks.md) are defined as rake tasks.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fortman/consul_watcher.

PS. I swear I'm done changing the project name :)
