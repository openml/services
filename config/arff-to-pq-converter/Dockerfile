FROM openml/arff-to-pq-to-minio:1.0.20241011

COPY cron /etc/cron.d/openml
COPY run-cron.sh /run-cron.sh

USER root
RUN apt update && apt upgrade -y
RUN apt -y install cron
RUN chmod +x /etc/cron.d/openml

RUN crontab -u unprivileged-user /etc/cron.d/openml