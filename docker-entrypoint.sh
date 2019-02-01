#!/bin/sh

[ "x${CONSUL_HTTP_ADDR}" == "x" ] && export CONSUL_HTTP_ADDR="http://169.254.2.4:8500"
[ "x${WATCH_SCRIPT}" == "x" ] && export WATCH_SCRIPT="/usr/bin/jq"

echo "CLI_ARGS: ${@}"
echo "WATCH_ARGS: ${WATCH_ARGS}"
echo "WATCH_SCRIPT: ${WATCH_SCRIPT}"
echo "CONSUL_HTTP_ADDR: ${CONSUL_HTTP_ADDR}"
echo "RUN_ONCE: ${RUN_ONCE}"
if [[ ${#} != 0 ]]; then
  exec $@
elif [[ "x${WATCH_ARGS}" != "x" && "x${RUN_ONCE}" == "x" ]]; then
  echo "consul watch ${WATCH_ARGS} ${WATCH_SCRIPT}"
  exec consul watch ${WATCH_ARGS} ${WATCH_SCRIPT}
elif [[ "x${WATCH_ARGS}" != "x" && "x${RUN_ONCE}" != "x" ]]; then
  echo "consul watch ${WATCH_ARGS} | ${WATCH_SCRIPT}"
  exec consul watch ${WATCH_ARGS} | ${WATCH_SCRIPT}
else
  echo "Don't know what to do, WATCH_ARGS not defined and no arguments passed in"
  exit 1
fi
