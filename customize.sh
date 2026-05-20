#!/system/bin/sh

DATA_DIR="/data/adb/cloudflared"

ui_print "- Creating directories"
mkdir -p "$DATA_DIR"
mkdir -p "$DATA_DIR/logs"

ui_print "- Installing binaries"
cp "$MODPATH/files/cloudflared" "$DATA_DIR/cloudflared"

chmod 755 "$DATA_DIR/cloudflared"

CONFIG_FILE="$DATA_DIR/config.env"

if [ ! -f "$CONFIG_FILE" ]; then
cat > "$CONFIG_FILE" <<EOF
# Cloudflare Tunnel Token
CF_TOKEN=replace_me

# Protocol: quic (default, lower latency) or http2 (fallback when UDP blocked)
CF_PROTOCOL=quic
# CF_PROTOCOL=http2

# Keep-alive check interval in seconds (default: 300 = 5 min)
KEEPALIVE_INTERVAL=300

# Logging
LOG_MAX_SIZE=10485760

EOF
fi

ui_print "- Installation complete"
