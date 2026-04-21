FROM node:22-bookworm-slim

# ── system packages ──────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
      bash \
      ca-certificates \
      curl \
      git \
      jq \
      less \
      openssh-client \
      ripgrep \
      sudo \
      iptables \
      iproute2 \
      dnsutils \
      ipset \
      gosu \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ── install claude code globally ─────────────────────────────────
RUN npm install -g @anthropic-ai/claude-code

# ── entrypoint handles UID remapping + firewall ──────────────────
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
# COPY init-firewall.sh /usr/local/bin/init-firewall.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
# RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/init-firewall.sh

ENV TERM=xterm-256color

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
