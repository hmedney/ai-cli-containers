FROM debian:trixie-slim

ARG INSTALL_COMMAND=""

# Install necessary system packages common to all tools if needed
RUN apt-get update && apt-get install -y --no-install-recommends \
      bash \
      ca-certificates \
      curl \
      git \
      less \
      openssh-client \
      bzip2 \
      ripgrep \
      libgomp1 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN bash -c "${INSTALL_COMMAND}"
ENV TERM=xterm-256color
