#!/system/bin/sh

DATA_DIR="/data/adb/cloudflared"

killall cloudflared 2>/dev/null

rm -rf "$DATA_DIR"
