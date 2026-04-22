FROM node:24-trixie-slim

# ── system packages ──────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
      bash \
      ca-certificates \
      curl \
      git \
      less \
      openssh-client \
      ripgrep \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ── install opencode ─────────────────────────────────────────────
RUN npm install -g opencode-ai

# ── setup environment ─────────────────────────────────
ENV TERM=xterm-256color
