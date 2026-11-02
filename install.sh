#!/usr/bin/env bash
# Installs cosmic-autorotate for the current user.
set -euo pipefail

cd "$(dirname "$0")"

BIN="$HOME/.local/bin"
UNIT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
CONF="${XDG_CONFIG_HOME:-$HOME/.config}/cosmic-autorotate.conf"
NEED_REBOOT=0

if ! command -v cosmic-randr >/dev/null 2>&1; then
    echo "cosmic-randr not found - this only works on the COSMIC desktop." >&2
    exit 1
fi

if ! command -v monitor-sensor >/dev/null 2>&1; then
    if command -v apt >/dev/null 2>&1; then
        echo "Installing iio-sensor-proxy (needs sudo)..."
        sudo apt install -y iio-sensor-proxy
        NEED_REBOOT=1
    else
        echo "Please install iio-sensor-proxy with your package manager first." >&2
        exit 1
    fi
fi

install -Dm755 cosmic-autorotate "$BIN/cosmic-autorotate"
install -Dm644 cosmic-autorotate.service "$UNIT_DIR/cosmic-autorotate.service"
[ -f "$CONF" ] || install -Dm644 cosmic-autorotate.conf.example "$CONF"

systemctl --user daemon-reload
systemctl --user enable --now cosmic-autorotate.service

echo
echo "Installed. Settings: $CONF"
echo "Status:  systemctl --user status cosmic-autorotate"
if [ "$NEED_REBOOT" = 1 ]; then
    echo
    echo "iio-sensor-proxy was just installed: please REBOOT once so the sensor is detected."
fi
