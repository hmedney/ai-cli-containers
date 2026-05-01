FROM node:24-trixie-slim

ARG NPM_PACKAGE
ARG POST_INSTALL_SCRIPT

# ── system packages ──────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
      bash \
      ca-certificates \
      curl \
      git \
      jq \
      less \
      openssh-client \
      procps \
      fd-find \
      ripgrep \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ── npm global install in userspace (any uid:gid can run) ────────
RUN mkdir -p /usr/local/share/npm-global \
    && chmod -R 777 /usr/local/share/npm-global \
    && npm install npm@latest -g
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV npm_config_cache=/usr/local/share/npm-global/.npm-cache
ENV PATH=$PATH:/usr/local/share/npm-global/bin

USER node
RUN npm install -g ${NPM_PACKAGE}
RUN if [ -n "${POST_INSTALL_SCRIPT}" ]; then sh -c "${POST_INSTALL_SCRIPT}"; fi

ENV TERM=xterm-256color
