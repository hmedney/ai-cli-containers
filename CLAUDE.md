# CLI Sandbox

Runs AI CLI tools (claude-code, opencode, aider, goose, pi) in Docker containers with a restricted filesystem and an allowlisted HTTP proxy.

## Architecture

```
wrapper script (e.g. ./claude)
  └─ internal/launch.sh          # common container launch logic
       └─ docker compose run     # spins up the tool container
            └─ gateway service   # squid proxy on private_net
```

Each tool container has no direct internet access (`private_net` is internal). All outbound HTTP/HTTPS goes through the squid gateway at `gateway:3128`, which enforces a domain allowlist defined in `internal/gateway/squid.conf`.

## Adding a new CLI tool

1. Add a service to `internal/compose/compose.yaml` using the `*cli_tool` anchor. Pick the right Dockerfile:
   - `nodejs.Dockerfile` — npm-installed tools (pass `NPM_PACKAGE`)
   - `python.Dockerfile` — pip-installed tools (pass `PIP_PACKAGE`)
   - `debian.Dockerfile` — arbitrary install (pass `INSTALL_COMMAND`)

2. Create a wrapper script at the repo root (copy an existing one). Set:
   - `COMPOSE_SERVICE` — must match the service name in compose.yaml
   - `DATA_DIR` — host path mounted as `/home/user` inside the container (tool config/state persists here)
   - `TOOL_CMD` — the executable name inside the container
   - `COMPOSE_ENTRYPOINT` — only needed if the service requires a setup script before the tool runs (see pi)
   - `BUILTIN_ENV` — optional newline-separated `KEY=VAL` pairs baked into every run

3. Make the wrapper executable: `chmod +x <name>`

4. Build: `./<name> :build`

## Wrapper → launch.sh contract

The wrapper exports env vars and then `exec`s `internal/launch.sh`. `launch.sh` handles everything else: env loading, SSH/git mounts, the `docker compose run` call.

The entrypoint passed to the container is `${COMPOSE_ENTRYPOINT:-${TOOL_CMD}}`. User args (`$@`) are forwarded as the container command, which become `$@` inside the entrypoint.

For tools with a setup entrypoint (currently only pi), the entrypoint script is responsible for calling the tool at the end — `launch.sh` does not prepend `TOOL_CMD` to the args.

## Meta commands

All wrapper scripts support these as the first argument:

| Command | Effect |
|---|---|
| `:build` | Build the container image |
| `:rebuild` | Build with `--no-cache` |
| `:upgrade` | Force-reinstall the tool package (busts the install layer cache) |
| `:shell` | Drop into bash inside the container |
| `:watch` | Tail the squid proxy access log via `lnav` |
| `:help` | Print this list |

## User config & persistence

`DATA_DIR` (default `~/ai-tools/<tool>`) is mounted as `/home/user` inside the container. Tool config, credentials, and state live here and persist across runs.

A `${DATA_DIR}/.env` file is loaded automatically on each run — use it for API keys and per-tool env overrides.

## HTTP proxy allowlist

Edit `internal/gateway/squid.conf` to add domains. The current allowlist covers Anthropic, OpenAI, Groq, OpenRouter, and a configurable local LLM IP (`192.168.1.30`). Rebuild the gateway after changes: `docker compose -f internal/compose/compose.yaml build gateway`.

Proxy traffic can be monitored live with `./<tool> :watch`.

## pi-specific notes

`pi` has a setup entrypoint (`internal/compose/pi-entrypoint.sh`) that merges build-time package settings into the user's runtime settings before launching the tool. The merge is additive (build packages + user packages, deduplicated). The entrypoint is specified via `COMPOSE_ENTRYPOINT` in the `pi` wrapper.
