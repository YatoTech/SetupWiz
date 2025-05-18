#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# === Konfigurasi ===
APP_NAME="node-server"
ENTRY_FILE="server.js"
LOG_DIR="logs"
LOG_FILE="$LOG_DIR/start_server.log"

# === Persiapan Direktori Log ===
mkdir -p "$LOG_DIR"

# === Logging ke Terminal + File ===
exec > >(tee -a "$LOG_FILE") 2>&1

# === Fungsi Logging ===
log() {
    echo "$(date '+%F %T') - $1"
}

log ""
log "=== MEMULAI SERVER: $APP_NAME ==="

# === Cek & Hapus Proses Korup / Tidak Aktif ===
log "[INFO] Mengecek proses '$APP_NAME' yang tidak aktif atau korup..."
CORRUPT_IDS=$(pm2 jlist | jq -r ".[] | select(.name==\"$APP_NAME\" and .pm2_env.status != \"online\") | .pm_id")
if [[ -n "$CORRUPT_IDS" ]]; then
    for ID in $CORRUPT_IDS; do
        log "[INFO] Menghapus proses '$APP_NAME' dengan ID $ID (status tidak valid)..."
        pm2 delete "$ID" || true
    done
fi

# === Cek Apakah Proses Valid Sudah Ada ===
EXISTING_ENTRY=$(pm2 jlist | jq -r ".[] | select(.name==\"$APP_NAME\")")

if [[ -n "$EXISTING_ENTRY" ]]; then
    APP_STATUS=$(echo "$EXISTING_ENTRY" | jq -r ".pm2_env.status")
    if [[ "$APP_STATUS" == "online" ]]; then
        log "[INFO] Proses '$APP_NAME' terdeteksi dengan status 'online'. Melakukan restart..."
        if ! pm2 restart "$APP_NAME"; then
            log "[WARNING] Restart gagal. Menghapus dan menjalankan ulang proses..."
            pm2 delete "$APP_NAME" || true
            pm2 start "$ENTRY_FILE" --name "$APP_NAME" --watch
        fi
    else
        log "[INFO] Proses '$APP_NAME' ditemukan, tapi statusnya '$APP_STATUS'. Menghapus dan menjalankan ulang..."
        pm2 delete "$APP_NAME" || true
        pm2 start "$ENTRY_FILE" --name "$APP_NAME" --watch
    fi
else
    log "[INFO] Proses '$APP_NAME' belum terdaftar. Menjalankan untuk pertama kali..."
    pm2 start "$ENTRY_FILE" --name "$APP_NAME" --watch
fi

# === Tunggu Proses untuk Benar-Benar Berjalan ===
sleep 5

# === Validasi Status Akhir ===
FINAL_STATUS=$(pm2 jlist | jq -r ".[] | select(.name==\"$APP_NAME\") | .pm2_env.status")

if [[ "$FINAL_STATUS" == "online" ]]; then
    log "[✓] Server '$APP_NAME' berhasil dijalankan atau direstart."
else
    log "[✗] Gagal menjalankan server '$APP_NAME'."
    exit 1
fi

# === Simpan Konfigurasi PM2 ===
pm2 save
pm2 startup &>/dev/null || true

log ""
log "Server '$APP_NAME' sekarang berjalan!"
log ""
log "=== PERINTAH PENGGUNAAN PM2 ==="
log "• pm2 list               - Melihat daftar proses"
log "• pm2 logs               - Melihat log aplikasi"
log "• pm2 stop <id/nama>     - Menghentikan proses"
log "• pm2 restart <id/nama>  - Merestart proses"
log "• pm2 delete <id/nama>   - Menghapus proses"
log ""

exit 0
