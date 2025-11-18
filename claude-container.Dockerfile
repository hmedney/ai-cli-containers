FROM node:24.11.1-alpine3.22

# install utils
RUN apk add --no-cache \
  bash \
  curl \
  jq \
  micro \
  wget

# install claude code
RUN npm install -g @anthropic-ai/claude-code

# create os user
RUN adduser -D claude
USER claude
WORKDIR /home/claude

# set home dir for claude
ENV HOME=/home/claude

# enable rich terminal
ENV TERM=xterm-256color
