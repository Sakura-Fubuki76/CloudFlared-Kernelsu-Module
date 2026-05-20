#!/system/bin/sh

MODDIR=${0%/*}
source "$MODDIR/scripts/common.sh"

if is_running "$CF_BIN"; then
    echo "Stopping Cloudflared..."
    stop_keepalive
    stop_services
else
    echo "Starting Cloudflared..."
    wait_network
    start_cloudflared
    start_keepalive
fi
status_services
