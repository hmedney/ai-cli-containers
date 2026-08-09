# syntax=docker/dockerfile:1
FROM node:24-trixie-slim

ARG INSTALL_COMMAND

# ── system packages ──────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    micro \
    git \
    jq \
    less \
    bzip2 \
    procps \
    fd-find \
    ripgrep \
    libgomp1 \
    locales \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ── npm global install in userspace (any uid:gid can run) ────────
RUN mkdir -p /usr/local/share/npm-global \
    && chmod -R 777 /usr/local/share/npm-global \
    && npm install npm@latest -g
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV npm_config_cache=/usr/local/share/npm-global/.npm-cache
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# default editor
ENV EDITOR=micro

# improve tui experience
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV TERM=xterm-256color
ENV COLORTERM=truecolor

ARG UPGRADE_CACHE_BUST=1
USER node

RUN npm config set allow-remote all

RUN bash <<EOF
${INSTALL_COMMAND}
EOF
