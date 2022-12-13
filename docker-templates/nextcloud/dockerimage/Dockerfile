FROM nextcloud:latest

RUN apt-get update && apt-get install -y \
    supervisor \
    ghostscript \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir /var/log/supervisord /var/run/supervisord

RUN echo '0 5 * * * php -f /var/www/html/occ preview:pre-generate' >> /var/spool/cron/crontabs/www-data

COPY supervisord.conf /
COPY policy.xml /etc/ImageMagick-6/policy.xml

ENV NEXTCLOUD_UPDATE=1

CMD ["/usr/bin/supervisord", "-c", "/supervisord.conf"]
