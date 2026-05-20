#!/system/bin/sh

MODDIR=${0%/*}
source "$MODDIR/scripts/common.sh"

wait_network

start_cloudflared
start_keepalive
