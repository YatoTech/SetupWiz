#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# === Configuration ===
WEB_DIR="webapp"
WEB_PORT=4000
LOG_DIR="logs/webapp_logs"
LOG_FILE="$LOG_DIR/setup_webapp.log"
APP_FILE="$WEB_DIR/app.js"
PM2_APP_NAME="webapp-server"

# === Setup log ===
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

log() { echo "$(date '+%F %T') - $1"; }

log ""
log "=== CREATING WEB PROJECT STRUCTURE ==="
mkdir -p "$WEB_DIR/public" "$WEB_DIR/routes" "$WEB_DIR/views" "$WEB_DIR/controllers" "$WEB_DIR/models"

# === Create app.js ===
cat <<EOF > "$APP_FILE"
// Basic Express App Setup
const express = require('express');
const app = express();
const dotenv = require('dotenv');

dotenv.config();
const PORT = process.env.PORT || $WEB_PORT;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

app.get('/', (req, res) => {
    res.send('<h1>WebApp aktif di port ' + PORT + '</h1>');
});

app.listen(PORT, () => {
    console.log(\`🌐 WebApp running on http://localhost:\${PORT}\`);
});
EOF

log "[+] app.js created"

# === Create .env for webapp ===
cat <<EOF > "$WEB_DIR/.env"
PORT=$WEB_PORT
EOF
log "[+] .env created"

# === Placeholder files ===
touch "$WEB_DIR/routes/index.js"
touch "$WEB_DIR/controllers/homeController.js"
touch "$WEB_DIR/models/sampleModel.js"
touch "$WEB_DIR/views/index.html"
log "[+] Placeholder files created in routes/, controllers/, models/, views/"

# === Jalankan WebApp dengan PM2 ===
if ! command -v pm2 &> /dev/null; then
    echo "❌ PM2 belum terpasang. Silakan install dengan: npm install -g pm2"
    exit 1
fi

log "[i] Menjalankan WebApp dengan PM2..."
pm2 delete "$PM2_APP_NAME" &> /dev/null || true
pm2 start "app.js" --name "$PM2_APP_NAME" --cwd "$WEB_DIR" --env production
pm2 save

log "✅ WebApp berjalan di http://localhost:$WEB_PORT"
