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
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ── install claude code globally ─────────────────────────────────
RUN npm install -g @anthropic-ai/claude-code

# ── setup environment ─────────────────────────────────
ENV TERM=xterm-256color
