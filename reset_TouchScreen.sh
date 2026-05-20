#!/usr/bin/env bash
set -euo pipefail

find_touch_device() {
  for f in /sys/bus/usb/devices/*/product; do
    [ -e "$f" ] || continue
    if grep -qx "TouchScreen" "$f"; then
      dirname "$f" | xargs basename
      return 0
    fi
  done
  return 1
}

reset_dev() {
  local dev="$1"
  echo "Resetting $dev"
  echo 0 | sudo tee "/sys/bus/usb/devices/$dev/authorized" >/dev/null
  sleep 2
  echo 1 | sudo tee "/sys/bus/usb/devices/$dev/authorized" >/dev/null
}

TOUCH_DEV="$(find_touch_device || true)"

if [ -n "${TOUCH_DEV:-}" ]; then
  echo "Found TouchScreen at: $TOUCH_DEV"
  reset_dev "$TOUCH_DEV"
else
  echo "TouchScreen not found, resetting known hub path 1-1.3"
  reset_dev "1-1.3"
fi

echo
grep . /sys/bus/usb/devices/*/product 2>/dev/null || true
