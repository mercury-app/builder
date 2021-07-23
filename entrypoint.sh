#!/bin/sh

echo $(whoami)
chown mercury:mercury /var/run/docker.sock
# run as mercury
su - mercury -c "supervisord"