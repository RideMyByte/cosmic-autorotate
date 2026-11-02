#!/usr/bin/env bash
# Removes cosmic-autorotate for the current user (keeps the config file).
set -uo pipefail

UNIT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"

systemctl --user disable --now cosmic-autorotate.service 2>/dev/null
rm -f "$UNIT_DIR/cosmic-autorotate.service" "$HOME/.local/bin/cosmic-autorotate"
systemctl --user daemon-reload

echo "Removed. Your config (~/.config/cosmic-autorotate.conf) was kept."
echo "The display keeps its current rotation; reset it in Settings > Displays if needed."
