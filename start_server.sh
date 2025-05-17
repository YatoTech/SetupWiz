#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# === Konfigurasi ===
LOG_DIR="logs"
LOG_FILE="$LOG_DIR/start_server.log"
APP_NAME="node-server"
ENTRY_FILE="server.js"

# === Setup log directory ===
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

log() { echo "$(date '+%F %T') - $1"; }

log ""
log "=== STARTING SERVER ==="

# Cek apakah proses sudah berjalan
if pm2 describe "$APP_NAME" > /dev/null 2>&1; then
    log "[INFO] Proses '$APP_NAME' ditemukan. Melakukan restart..."
    pm2 restart "$APP_NAME"
else
    log "[INFO] Proses '$APP_NAME' tidak ditemukan. Melakukan start..."
    pm2 start "$ENTRY_FILE" --name "$APP_NAME" --watch
fi

# Validasi
if [ $? -eq 0 ]; then
    log "[✓] Server berhasil dijalankan atau direstart."
else
    log "[✗] Gagal menjalankan server dengan PM2."
    exit 1
fi

# Simpan status & jalankan startup
pm2 save
pm2 startup > /dev/null 2>&1

log ""
log "Server berjalan! Gunakan perintah berikut untuk manajemen:"
log "1. pm2 list               - Melihat daftar proses"
log "2. pm2 logs               - Melihat log"
log "3. pm2 stop <id/name>     - Menghentikan proses"
log "4. pm2 restart <id/name>  - Restart proses"
