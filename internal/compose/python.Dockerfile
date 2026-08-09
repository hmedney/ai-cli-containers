FROM python:3.12-slim-trixie

ARG PIP_PACKAGE=""
ARG BINARY_INSTALLER_URL=""
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

# ── Python venv in userspace (any uid:gid can run) ───────────────
# PYTHONPYCACHEPREFIX redirects .pyc writes to /tmp so arbitrary uids
# don't need write access to the venv's site-packages tree.
ENV PYTHON_VENV=/usr/local/share/python-venv
ENV PYTHONPYCACHEPREFIX=/tmp/pycache
RUN python3 -m venv $PYTHON_VENV \
    && chmod -R 755 $PYTHON_VENV
ENV PATH=$PYTHON_VENV/bin:$PATH

# default editor
ENV EDITOR=micro

# improve tui experience
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV TERM=xterm-256color
ENV COLORTERM=truecolor

# ── install tool ─────────────────────────────────────────────────
ARG UPGRADE_CACHE_BUST=1

RUN bash <<EOF
${INSTALL_COMMAND}
EOF
