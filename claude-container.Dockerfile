FROM node:24-alpine

RUN apk update && \
    apk upgrade && \
    apk add bash curl jq wget && \
    apk cache clean

RUN npm install -g npm@latest && \
    npm install -g @anthropic-ai/claude-code && \
    npm cache clean --force
