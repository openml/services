FROM logstash:9.3.3

USER root

# install MySQL Connector/J
RUN curl -Lo "connector-j.rpm" "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-9.7.0-1.el9.noarch.rpm" \
    && rpm --install --nosignature --verbose "connector-j.rpm" \
    && rm "connector-j.rpm"

USER logstash


ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
