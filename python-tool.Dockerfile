FROM python:3.12-slim-trixie

ARG PIP_PACKAGE=""
ARG BINARY_INSTALLER_URL=""

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

# ── Python venv in userspace (any uid:gid can run) ───────────────
# PYTHONPYCACHEPREFIX redirects .pyc writes to /tmp so arbitrary uids
# don't need write access to the venv's site-packages tree.
ENV PYTHON_VENV=/usr/local/share/python-venv
ENV PYTHONPYCACHEPREFIX=/tmp/pycache
RUN python3 -m venv $PYTHON_VENV \
    && chmod -R 755 $PYTHON_VENV
ENV PATH=$PYTHON_VENV/bin:$PATH

# ── install tool ─────────────────────────────────────────────────
RUN if [ -n "$PIP_PACKAGE" ]; then \
      pip install --no-cache-dir "$PIP_PACKAGE"; \
    elif [ -n "$BINARY_INSTALLER_URL" ]; then \
      curl -fsSL "$BINARY_INSTALLER_URL" | GOOSE_INSTALL_DIR=/usr/local/bin bash; \
    fi

ENV TERM=xterm-256color
