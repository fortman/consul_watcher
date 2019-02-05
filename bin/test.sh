#!/bin/bash

RUN_ONCE="true" WATCH_ARGS="--type service --service consul" WATCH_SCRIPT="./exe/ruby_consul_watch --config-file test/example-config.json --watch-name testing" ./docker-entrypoint.sh
