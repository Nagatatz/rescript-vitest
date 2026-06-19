#!/bin/sh
# Notification hook: cross-platform desktop notification.
# macOS: osascript, Linux: notify-send (if available), fallback: silent.
# Exit 0 always (informational only).

TITLE="Claude Code"
MSG="Claude needs your attention"

case "$(uname -s)" in
  Darwin)
    osascript -e "display notification \"$MSG\" with title \"$TITLE\" sound name \"Sosumi\"" 2>/dev/null
    ;;
  Linux)
    if command -v notify-send >/dev/null 2>&1; then
      notify-send "$TITLE" "$MSG" 2>/dev/null
    fi
    ;;
esac

exit 0
