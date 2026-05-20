#!/system/bin/sh

DATA_DIR="/data/adb/cloudflared"
LOG_DIR="$DATA_DIR/logs"
CONFIG_FILE="$DATA_DIR/config.env"

[ -f "$CONFIG_FILE" ] || exit 1
source "$CONFIG_FILE"

CF_BIN="$DATA_DIR/cloudflared"
CF_LOG="$LOG_DIR/cloudflared.log"
KEEPALIVE_PIDFILE="$DATA_DIR/keepalive.pid"

update_description() {
    if is_running "$CF_BIN"; then
        ksud module config set override.description "Cloudflare Tunnel [● Running]" 2>/dev/null
    else
        ksud module config set override.description "Cloudflare Tunnel [○ Stopped]" 2>/dev/null
    fi
}

rotate_log() {
    FILE="$1"

    if [ -f "$FILE" ]; then
        SIZE=$(stat -c%s "$FILE")

        if [ "$SIZE" -gt "$LOG_MAX_SIZE" ]; then
            mv "$FILE" "$FILE.old"
        fi
    fi
}

wait_network() {
    until ping -c 1 1.1.1.1 >/dev/null 2>&1
    do
        sleep 3
    done
}

is_running() { pgrep -f "$1" >/dev/null 2>&1; }

start_cloudflared() {
    if is_running "$CF_BIN"; then
        return
    fi

    rotate_log "$CF_LOG"

    nohup "$CF_BIN" tunnel run --protocol "${CF_PROTOCOL:-quic}" --token "$CF_TOKEN" >> "$CF_LOG" 2>&1 &
    update_description
}

stop_services() {
    killall cloudflared 2>/dev/null
    update_description
}

start_keepalive() {
    if [ -f "$KEEPALIVE_PIDFILE" ]; then
        KPID=$(cat "$KEEPALIVE_PIDFILE")
        if [ -d "/proc/$KPID" ]; then
            return
        fi
    fi

    while true; do
        sleep "${KEEPALIVE_INTERVAL:-300}"
        if ! is_running "$CF_BIN"; then
            rotate_log "$CF_LOG"
            nohup "$CF_BIN" tunnel run --protocol "${CF_PROTOCOL:-quic}" --token "$CF_TOKEN" >> "$CF_LOG" 2>&1 &
        fi
    done &
    echo $! > "$KEEPALIVE_PIDFILE"
}

stop_keepalive() {
    if [ -f "$KEEPALIVE_PIDFILE" ]; then
        kill "$(cat "$KEEPALIVE_PIDFILE")" 2>/dev/null
        rm -f "$KEEPALIVE_PIDFILE"
    fi
}

status_services() {
    echo "=== Cloudflared ==="
    pgrep -f "$CF_BIN" || echo "not running"
}
