FROM alpine:3.24.1

RUN apk add --no-cache squid goaccess lnav micro jq && \
    mkdir -p /var/log/squid && \
    mkdir -p /var/run/squid && \
    chown -R squid:squid /var/log/squid && \
    chown -R squid:squid /var/run/squid

# Use the squid user for security
USER squid

# Expose the proxy port
EXPOSE 3128

ENV TERM=xterm-256color

# Run squid in the foreground
CMD ["squid", "-N", "-d", "1"]
