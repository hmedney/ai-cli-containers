FROM alpine:latest

RUN apk add --no-cache squid && \
    mkdir -p /var/log/squid && \
    mkdir -p /var/run/squid && \
    chown -R squid:squid /var/log/squid && \
    chown -R squid:squid /var/run/squid

# Use the squid user for security
USER squid

# Expose the proxy port
EXPOSE 3128

# Run squid in the foreground
CMD ["squid", "-N", "-d", "1"]
