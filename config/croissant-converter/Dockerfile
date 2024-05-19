from openml/croissant-converter

COPY cron /etc/cron.d/openml
COPY run-cron.sh /run-cron.sh
COPY generate_croissants.sh /generate_croissants.sh

USER root
RUN apt update && apt upgrade -y
RUN apt -y install cron
RUN chmod +x /etc/cron.d/openml

RUN crontab -u unprivileged-user /etc/cron.d/openml