#!/bin/bash
set -e

# ── UID/GID remapping ────────────────────────────────────────────
# Create a user inside the container that matches the host caller's
# UID/GID so that files written to mounted volumes have correct
# ownership.  The wrapper script passes these as env vars.
HOST_UID="${HOST_UID:-1000}"
HOST_GID="${HOST_GID:-1000}"
USERNAME="coder"

# Create group if it doesn't exist with the host GID
if ! getent group "${HOST_GID}" >/dev/null 2>&1; then
  groupadd -g "${HOST_GID}" "${USERNAME}"
fi
GROUP_NAME=$(getent group "${HOST_GID}" | cut -d: -f1)

# Create user if it doesn't exist with the host UID
if ! getent passwd "${HOST_UID}" >/dev/null 2>&1; then
  useradd -m -u "${HOST_UID}" -g "${HOST_GID}" -s /bin/bash "${USERNAME}"
fi
USER_NAME=$(getent passwd "${HOST_UID}" | cut -d: -f1)

# Ensure home directory exists and is owned correctly
USER_HOME=$(getent passwd "${HOST_UID}" | cut -d: -f6)
mkdir -p "${USER_HOME}"
chown "${HOST_UID}:${HOST_GID}" "${USER_HOME}"

# ── Firewall (optional, requires --cap-add=NET_ADMIN) ───────────
if [ "${ENABLE_FIREWALL:-0}" = "1" ]; then
  echo ":: Initializing firewall..."
  /usr/local/bin/init-firewall.sh
  echo ":: Firewall active."
fi

# ── Drop to unprivileged user and exec claude ────────────────────
exec gosu "${HOST_UID}:${HOST_GID}" "$@"
