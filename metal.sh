#!/usr/bin/env bash
# oma.metal – styr strömmen. Spelaren körs i en egen systemd --user-enhet,
# så den lever oberoende av omarchy-shell (ingen föräldralös process) och
# kan alltid hittas/stoppas via enhetsnamnet.
#   metal.sh start|stop|toggle|status
set -euo pipefail

URL="${OMA_METAL_URL:-https://wr03-ice.stream.khz.se/wr03_mp3}"
UNIT="oma-metal"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/oma.metal"
PID_FILE="$STATE_DIR/pid"
mkdir -p "$STATE_DIR"

player_cmd() {
  if command -v mpv >/dev/null 2>&1; then
    PLAYER=(mpv --no-video --no-terminal --really-quiet --audio-client-name=oma.metal "$URL")
  elif command -v ffplay >/dev/null 2>&1; then
    PLAYER=(ffplay -nodisp -loglevel quiet "$URL")
  elif command -v mpg123 >/dev/null 2>&1; then
    PLAYER=(mpg123 -q "$URL")
  else
    echo "oma.metal: hittar ingen spelare (mpv, ffplay eller mpg123)" >&2
    exit 1
  fi
}

active() { systemctl --user is-active --quiet "$UNIT.service"; }

sync_state() {
  if active; then
    systemctl --user show -p MainPID --value "$UNIT.service" > "$PID_FILE"
    echo playing
  else
    rm -f "$PID_FILE"
    echo stopped
  fi
}

start() {
  active && { sync_state; return; }
  player_cmd
  systemctl --user reset-failed "$UNIT.service" >/dev/null 2>&1 || true
  systemd-run --user --quiet --collect --unit="$UNIT" \
    --description="oma.metal stream" \
    -p KillMode=control-group \
    "${PLAYER[@]}"
  sync_state
}

stop() {
  systemctl --user stop "$UNIT.service" >/dev/null 2>&1 || true
  sync_state
}

case "${1:-status}" in
  start) start ;;
  stop) stop ;;
  toggle) if active; then stop; else start; fi ;;
  status) sync_state ;;
  *) echo "Användning: metal.sh start|stop|toggle|status" >&2; exit 2 ;;
esac
