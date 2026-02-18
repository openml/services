#!/bin/sh

# We need to remove the default 127.0.0.1 localhost map to
# ensure the remap to the static nginx ip address is respected.
# Updating /etc/hosts in place isn't always allowed ("Resource Busy"),
# directly overwriting it instead seems to bypass that protection.
cp /etc/hosts /etc/hosts.new
sed -i '/^127.0.0.1.*localhost/d' /etc/hosts.new
sed -i -E 's/^(::1\t)localhost (.*)$/\1\2/g' /etc/hosts.new
cat /etc/hosts.new > /etc/hosts
rm /etc/hosts.new

printenv | grep -v HOME >> /etc/environment

touch /cron.log
/usr/sbin/crond -l 4 && tail -f /cron.log
