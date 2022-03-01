FROM alpine:latest

RUN apk add --no-cache samba-server samba-common-tools openssl bash curl

COPY ./s6/gets6.sh /tmp/gets6.sh
RUN /tmp/gets6.sh

COPY ./s6/config.sh /etc/cont-init.d/00-config
COPY ./s6/smbd.run /etc/services.d/smbd/run
COPY ./s6/nmbd.run /etc/services.d/nmbd/run

EXPOSE 137/udp 138/udp 139/tcp 445/tcp

CMD ["/init"]