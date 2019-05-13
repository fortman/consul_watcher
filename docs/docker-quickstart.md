# Docker quickstart

The easiest way to get started with consul_watcher is with the docker image.  The docker entry point will run a consul watch and then pipe the output to the ruby consul_watcher program.  The behavior is mostly driven by passing environmental variables into docker.  Environmental variables, command line parameters and a configuration file are being tested to determine which is best way to configure consul_watch.  There is a docker compose file to test things out locally  The following steps should have you working with a local cluster fairly quick.  A rake task will be created to automate these steps at some point.

You can build and run the stack locally with the following steps:

From the root of the git repository execute these rake tasks<br/>
:> `rake`<br/>
:> `rake up`<br/>

You will have a locally running consul and rabbitmq instance.  Rabbitmq will already have a queue bound to the appropriate exchange.  The terminal where you ran `rake up` will show any key/value changes you make in consul.

After the docker containers have started, you can login to consul locally http://localhost:8500.  You should be able to start creating, updating and deleting entries in the kv store.  Go back to rabbitmq and you should be seeing messages flowing through the queue as you make updates in consul.<br/>

# environmental variables used by docker image
| environment variable | description                                                         | example value                                                                                               |
| -------------------- | ------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| WATCH_ARGS           | arguments passed into the consul watch command                      | --type keyprefix --prefix /                                                                                 |
| WATCH_SCRIPT         | the output of the consul watch is piped to this command             | /usr/bin/consul_watcher --config-file /etc/consul_watch/config.json --storage-name testing --watch-type key |
| RUN_ONCE             | determins if the consul watch runs once, or multiple times          | set to any string to enable `run once` mode.  Unset/empty string means run continuously                     |
| CONSUL_HTTP_ADDR     | used by consul, any consul environmental variables can be specified | http://localhost:8500                                                                                       |

## consul_watcher command line arguments
| command line argument | description | example value |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------- |
| --config-file (file)  | reference to the configuration file, need to mount in as volume to docker                                                                  | /etc/consul_watch/config.json           |  
| --watch-type (type)   | must match the --watch-type value passed to consul, keyprefix is should just be specified as key                                           | key/services/nodes/service/checks/event | 
| --storage-name (name) | just a unqiue name for this watch.  if you are storing multiple watches to the same backend, you should make each watch have a unique name | test-watch                              |

## Configuration file

