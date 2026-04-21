FROM node:24-trixie-slim

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

# ── setup local user ─────────────────────────────────
RUN adduser coder
USER coder
WORKDIR /home/coder

# ── setup environment ─────────────────────────────────
ENV HOME=/home/coder
ENV TERM=xterm-256color
