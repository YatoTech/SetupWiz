#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# === Setup log directory ===
LOG_DIR="logs/ssl_logs"
LOG_FILE="$LOG_DIR/setup_ssl.log"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

log() { echo "$(date '+%F %T') - $1"; }

log ""
log "=== SSL SETUP ==="
log "[+] Installing mkcert..."

sudo apt-get update
sudo apt-get install -y libnss3-tools

wget -q https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64 -O mkcert
chmod +x mkcert
sudo mv mkcert /usr/local/bin/

log "[+] Running mkcert install..."
mkcert -install
log "[+] Generating certificates for localhost..."
mkcert localhost

if [ $? -eq 0 ]; then
    log "[✓] SSL certificates successfully created for localhost"
    
    # === Optional: Move to certs directory ===
    CERT_DIR="certs"
    mkdir -p "$CERT_DIR"
    if [[ -f "localhost.pem" && -f "localhost-key.pem" ]]; then
        mv localhost.pem localhost-key.pem "$CERT_DIR/"
        log "[+] Certificates moved to $CERT_DIR/"
    else
        log "[!] Certificates not found for moving"
    fi
else
    log "[✗] SSL setup failed"
    exit 1
fi
