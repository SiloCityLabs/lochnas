FROM alpine:latest

RUN apk add --no-cache samba-server samba-common-tools openssl bash

ADD https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.3/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /

COPY ./s6/config.sh /etc/cont-init.d/00-config
COPY ./s6/smbd.run /etc/services.d/smbd/run
COPY ./s6/nmbd.run /etc/services.d/nmbd/run

EXPOSE 137/udp 138/udp 139/tcp 445/tcp

CMD ["/init"]
