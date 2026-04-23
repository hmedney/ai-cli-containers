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

COPY gateway/gateway_key /home/node/id_rsa
RUN chown node:node /home/node/id_rsa && chmod 600 /home/node/id_rsa

COPY gateway/cli_entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN mkdir -p /usr/local/share/npm-global \
    && chmod -R 777 /usr/local/share/npm-global
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV npm_config_cache=/usr/local/share/npm-global/.npm-cache
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# ── install claude code globally ─────────────────────────────────
USER node
RUN npm install -g @anthropic-ai/claude-code

# ── setup environment ─────────────────────────────────
ENV TERM=xterm-256color

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
