FROM debian:trixie-slim

ARG INSTALL_COMMAND

# Install necessary system packages common to all tools if needed
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

# default editor
ENV EDITOR=micro

# improve tui experience
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV TERM=xterm-256color
ENV COLORTERM=truecolor

ARG UPGRADE_CACHE_BUST=1

RUN useradd -m -u 2222 appuser
USER appuser

RUN bash <<EOF
${INSTALL_COMMAND}
EOF

RUN chmod -R 777 /home/appuser
