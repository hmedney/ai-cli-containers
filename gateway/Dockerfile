FROM alpine:latest

RUN apk add --no-cache openssh-server \
    && ssh-keygen -A \
    && adduser -D tunneluser \
    # Set a random password to "unlock" the account for SSH key use
    && echo "tunneluser:$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)" | chpasswd


COPY sshd_config /etc/ssh/sshd_config

# 2. SETUP PERMISSIONS
RUN mkdir -p /home/tunneluser/.ssh && chmod 700 /home/tunneluser/.ssh
COPY gateway_key.pub /home/tunneluser/.ssh/authorized_keys

RUN chown -R tunneluser:tunneluser /home/tunneluser/.ssh \
    && chmod 600 /home/tunneluser/.ssh/authorized_keys

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D", "-e"]
