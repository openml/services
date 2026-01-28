#!/bin/sh

# We need to remove the default 127.0.0.1 localhost map to
# ensure the remap to the static nginx ip address is respected.
sed -i '/^127.0.0.1.*localhost/d' /etc/hosts

printenv | grep -v HOME >> /etc/environment

touch /cron.log
/usr/sbin/crond -l 4 && tail -f /cron.log
