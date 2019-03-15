# Docker quickstart

The easiest way to get started with consul_watcher is with the docker image.  The docker entry point will run a consul watch and then pipe the output to the ruby consul_watcher program.  The behavior is mostly driven by passing environmental variables into docker.  Environmental variables, command line parameters and a configuration file are being tested to determine which is best way to configure consul_watch.  There is a docker compose file to test things out locally  The following steps should have you working with a local cluster fairly quick.  A rake task will be created to automate these steps at some point.

From the root of the git repository execute the following<br/>
:> docker-compose --file test/docker-compose.yml up --no-start<br/>
:> docker-compose --file test/docker-compose.yml start consul rabbitmq<br/>
Wait a bit of time for those services to start.  30 seconds should suffice.<br/>
Login to rabbitmq locally [http://localhost:15672]. Use guest/guest as password.  <br/>
Create a queue and bind it to the amq.topic exchange.  Use routing key `consul_watcher.key.#` for the bind.<br/>
:> docker-compose --file test/docker-compose.yml start consul-watcher<br/>
Login to consul locally [http://localhost:8500].  You should be able to start creating, updating and deleting entries in the kv store.  You should start to see messages in the queue<br/>

# environmental variables used by docker image
| environment variable | description                                                         | example value                                                                                               |
| -------------------- | ------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| WATCH_ARGS           | arguments passed into the consul watch command                      | --type keyprefix --prefix /                                                                                 |
| WATCH_SCRIPT         | the output of the consul watch is piped to this command             | /usr/bin/consul_watcher --config-file /etc/consul_watch/config.json --storage-name testing --watch-type key |
| RUN_ONCE             | determins if the consul watch runs once, or multiple times          | true|false                                                                                                  |
| CONSUL_HTTP_ADDR     | used by consul, any consul environmental variables can be specified | http://localhost:8500                                                                                       |

## consul_watcher command line arguments
| command line argument | description | example value |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------- |
| --config-file (file)  | reference to the configuration file, need to mount in as volume to docker                                                                  | /etc/consul_watch/config.json           |  
| --watch-type (type)   | must match the --watch-type value passed to consul, keyprefix is should just be specified as key                                           | key/services/nodes/service/checks/event | 
| --storage-name (name) | just a unqiue name for this watch.  if you are storing multiple watches to the same backend, you should make each watch have a unique name | test-watch                              |

## Configuration file

