FROM openml/evaluation-engine:v1.2.2

COPY cron /etc/cron.d/openml
COPY run-cron.sh /run-cron.sh

RUN chmod +x /etc/cron.d/openml
RUN /usr/bin/crontab /etc/cron.d/openml
