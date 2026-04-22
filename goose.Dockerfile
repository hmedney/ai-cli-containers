FROM debian:trixie-slim

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

# ── install goose ────────────────────────────────────────────────
RUN curl -fsSL https://github.com/block/goose/releases/latest/download/download.sh \
      | GOOSE_INSTALL_DIR=/usr/local/bin bash

# ── setup environment ─────────────────────────────────
ENV TERM=xterm-256color
