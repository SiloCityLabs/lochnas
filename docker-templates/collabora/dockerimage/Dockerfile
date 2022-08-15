FROM collabora/code

user root
RUN apt-get update && apt-get install -y wget

# Switch back to lool user
USER 104

CMD ["/start-collabora-online.sh"]
