#!/bin/bash

printenv | grep -v HOME >> /etc/environment

touch /home/unprivileged-user/cron.log
chown -R unprivileged-user:unprivileged-user /home/unprivileged-user
/usr/sbin/cron -l 4 && tail -f /home/unprivileged-user/cron.log