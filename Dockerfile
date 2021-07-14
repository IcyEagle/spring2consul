FROM curlimages/curl:7.77.0

COPY migrate.sh /opt/migrate.sh

ENTRYPOINT ["sh", "/opt/migrate.sh"]