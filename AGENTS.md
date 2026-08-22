# AGENTS.md

AI CLI Sandbox — launches AI CLI tools (claude, codex, gemini, cline, opencode, omp, aider, dsh, goose, pi, prime-agent, jcode) in Docker containers with **restricted filesystem** and **air-gapped network**. All HTTP must go through an internal Squid proxy with an allow-list.

## How it works (the mental model)

- Each root-level script named after a tool (e.g. `claude`) is a 2-line wrapper. `COMPOSE_SERVICE=$(basename "$0")` is set, then it calls `internal/launch.sh "$@"`.
- To use: `ln -s $PWD/claude ~/bin` then run `claude` from any project dir. It opens the tool in a container whose working dir is the current project.
- `launch.sh` (`internal/launch.sh`) is the shared launcher. It resolves paths, **blocks running from `$HOME`** (you must be in a project dir), mounts cwd + a per-tool home dir, optionally mounts ssh-agent + `.gitconfig`, then runs `docker compose run`.
- `compose.yaml` (`internal/compose/compose.yaml`) defines all services. A shared `&cli_tool` anchor + `*build`/`*build_args`/`*environment` aliases mean each tool only overrides `INSTALL_COMMAND` and `entrypoint`.
- **Network model:** `gateway` (Squid) bridges `public_net` + `private_net`. CLI tools sit on `private_net` only (`internal: true` = air-gapped) and reach the internet solely via `http(s)_proxy: http://gateway:3128`. `gateway` is stopped with `docker compose stop gateway` after each session.
- `common.Dockerfile` (`internal/compose/common.Dockerfile`) is the image base: `python:3.12-slim-trixie`, creates a user **matching the host uid/gid** (so mounted files keep ownership), installs common dev tools + `uv` + nodejs via nvm, then runs `INSTALL_COMMAND`.

## Adding or editing a CLI tool

1. In `compose.yaml`, add a service that `<<: *cli_tool`, override `build.args` (`context`/`dockerfile` inherited; only change args if needed) with `INSTALL_COMMAND`, and override `entrypoint`.
2. For npm tools, `INSTALL_COMMAND` is like `npm install -g @openai/codex`. For installer-script tools, it's a `curl ... | bash` pipeline.
3. If a tool needs host port exposure (e.g. `dsh`), add a `ports:` mapping.
4. If the tool's domain isn't allow-listed for the proxy, add an `acl allowed_domains dstdomain .example.com` line to `internal/gateway/squid.conf` — otherwise the tool can't reach its API.

## Meta commands (via `launch.sh`)

`:build`, `:build-verbose`, `:rebuild`, `:upgrade` (re-runs just the install layer with a cache-busting `UPGRADE_CACHE_BUST` arg), `:shell` (bash into the image), `:exec` (bash into the running instance if exactly one is up; otherwise refuses), `:watch` (tails `lnav` on the Squid access log). Anything else is passed through to the tool.

## Conventions / gotchas learned

- The `gateway` container is **not** a service profile tool and always runs; don't treat it like the others.
- Tools run under `--user ${UID}:${GID}` so files they write match your host user.
- `OPENCODE_OFFLINE`/`OPENCODE_AIRGAPPED=1` are set only for `opencode`.
- **Known issues (do not "fix" unless asked):**
  - `goose` service has **no `entrypoint`** — it will fail to run until one is set.
  - `dsh` `INSTALL_COMMAND` has a typo: `npm install-scripts approve --all` (should be `npm install approve --all`).

## Testing changes

- Build a single tool: `<tool> :build` (or `docker compose --file internal/compose/compose.yaml build <service>`).
- Rebuild without cache: `<tool> :rebuild`.
- Validate the compose file after edits: `docker compose --file internal/compose/compose.yaml config`.
- Real smoke test: `ln -s $PWD/<tool> ~/bin` then run it from a test project dir.

## Repo facts

- Git repo. Current branch: `main`. Tool wrappers live at the repo root; compose + gateway in `internal/`.
- Docs: `docs/feat-pi-merge-settings.md`.
