#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# =============================================
# CONFIGURATION
# =============================================
WEB_DIR="webapp"
APP_FILE="app.js"
APP_NAME="webapp"
LOG_DIR="logs/deploy_logs"
LOG_FILE="$LOG_DIR/deploy_$(date '+%Y%m%d_%H%M%S').log"

# =============================================
# INIT
# =============================================
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

log() { echo "$(date '+%F %T') - $1"; }
success() { log "✅ $1"; }
fail() { log "❌ $1"; exit 1; }

log ""
log "=== STARTING DEPLOYMENT ==="

# =============================================
# CHECKS & SETUP
# =============================================
if [ ! -d "$WEB_DIR" ]; then
    fail "Web project directory '$WEB_DIR' not found"
fi

cd "$WEB_DIR" || fail "Failed to access '$WEB_DIR'"

# Optional: Load .env and extract PORT
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs) || true
fi
PORT="${PORT:-3000}"

log "[+] Installing NPM dependencies..."
npm install || fail "Failed to install NPM packages"

# =============================================
# PM2 DEPLOYMENT
# =============================================
log "[+] Starting or restarting '$APP_NAME' with PM2..."
if pm2 list | grep -qw "$APP_NAME"; then
    pm2 restart "$APP_NAME"
else
    pm2 start "$APP_FILE" --name "$APP_NAME"
fi

success "Application '$APP_NAME' deployed"

# =============================================
# FINAL OUTPUT
# =============================================
log ""
log "=== DEPLOYMENT COMPLETE ==="
log "- App Name: $APP_NAME"
log "- App File: $(pwd)/$APP_FILE"
log "- URL     : http://localhost:$PORT"
log "- PM2 Status:"
pm2 status "$APP_NAME"

cd .. || exit 0
