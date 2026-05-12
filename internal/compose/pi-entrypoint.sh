#!/usr/bin/env bash
# pi-entrypoint.sh – merge build‑time Pi settings into the user’s runtime settings

# Path where the Dockerfile stored the build‑time settings
BUILD_SETTINGS="/usr/local/share/pi/build-settings.json"
# Path to the user’s Pi settings (matches the sandbox environment)
USER_SETTINGS="${HOME}/.pi/agent/settings.json"

# If we have build‑time settings, merge or copy them into the user’s location
if [ -f "$BUILD_SETTINGS" ]; then
  if [ -f "$USER_SETTINGS" ]; then
    # Merge: keep user values for everything else, union the extensions array (simple strings)
    MERGED=$(jq -s '
      .[0] as $build |
      .[1] as $user |
      $user |
      .extensions = (
        (($build.extensions // []) + ($user.extensions // []))
        | unique
      )
    ' "$BUILD_SETTINGS" "$USER_SETTINGS")
    mkdir -p "$(dirname "$USER_SETTINGS")"
    echo "$MERGED" > "$USER_SETTINGS"
  else
    mkdir -p "$(dirname "$USER_SETTINGS")"
    cp "$BUILD_SETTINGS" "$USER_SETTINGS"
  fi
fi

# Execute the original command passed to the container (launch.sh builds the args)
exec "$@"
