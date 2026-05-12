#!/usr/bin/env bash
# pi-entrypoint.sh – merge build‑time Pi settings into the user’s runtime settings

# Path where the Dockerfile stored the build‑time settings
BUILD_SETTINGS="/home/node/.pi/agent/settings.json"

# Path to the user’s Pi settings (matches the sandbox environment)
USER_SETTINGS="${HOME}/.pi/agent/settings.json"

# If we have build‑time settings, merge or copy them into the user’s location
if [ -f "$BUILD_SETTINGS" ]; then
  if [ -f "$USER_SETTINGS" ]; then
    echo "Merging build-time packages..."
    MERGED=$(jq -s '
      .[0] as $build |
      .[1] as $user |
      $user |
      .packages = (
        (($build.packages // []) + ($user.packages // []))
        | unique
      )
    ' "$BUILD_SETTINGS" "$USER_SETTINGS")
    mkdir -p "$(dirname "$USER_SETTINGS")"
    echo "$MERGED" > "$USER_SETTINGS"
  fi
fi

exec pi "$@"
