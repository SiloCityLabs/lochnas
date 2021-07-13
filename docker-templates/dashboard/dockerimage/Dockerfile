# build stage
FROM alpine:latest

WORKDIR /app

ENV USER www-data
ENV GROUP www-data
ENV GID 33
ENV UID 33
ENV PORT 9191

RUN addgroup -S ${GROUP} -g ${GID} && adduser -D -S -u ${UID} ${USER} ${GROUP} && \
    apk add -U --no-cache su-exec

COPY --chown=${USER}:${GROUP} /app/dist /www/
COPY --chown=${USER}:${GROUP} /app/dist/assets /www/default-assets
COPY entrypoint.sh /entrypoint.sh

EXPOSE ${PORT}
VOLUME /www/assets
ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
