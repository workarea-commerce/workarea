#!/bin/bash
# Pass a command to run only after bundle is updated.
# This is used to allow only the web service to update bundle
# but have other services that need bundle to be updated to wait
# until the web service has finished updating before running the
# desired command to start the container's process.
# example: sh docker-wait.sh sidekiq

set -e
until bundle check > /dev/null 2>&1; do sleep 5; done
exec $@
