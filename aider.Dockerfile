FROM python:3.12-slim-trixie

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

# ── install aider ────────────────────────────────────────────────
RUN pip install --no-cache-dir aider-chat

# ── setup environment ─────────────────────────────────
ENV TERM=xterm-256color
