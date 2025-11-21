#!/bin/sh

printenv | grep -v HOME >> /etc/environment

touch /cron.log
/usr/sbin/crond -l 4 && tail -f /cron.log