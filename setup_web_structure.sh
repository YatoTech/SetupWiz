#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# === Configuration ===
WEB_DIR="webapp"
DEFAULT_PORT=3000
LOG_DIR="logs/webapp_logs"
LOG_FILE="$LOG_DIR/setup_webapp.log"

# === Setup log ===
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

log() { echo "$(date '+%F %T') - $1"; }

log ""
log "=== CREATING WEB PROJECT STRUCTURE ==="
mkdir -p "$WEB_DIR/public" "$WEB_DIR/routes" "$WEB_DIR/views" "$WEB_DIR/controllers" "$WEB_DIR/models"

# === Create app.js ===
cat <<EOF > "$WEB_DIR/app.js"
// Basic Express App Setup
const express = require('express');
const app = express();
const dotenv = require('dotenv');

dotenv.config();
const PORT = process.env.PORT || $DEFAULT_PORT;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

app.get('/', (req, res) => {
    res.send('Hello from WebApp!');
});

app.listen(PORT, () => {
    console.log(\`Server running on http://localhost:\${PORT}\`);
});
EOF

log "[+] app.js created"

# === Create default .env ===
cat <<EOF > "$WEB_DIR/.env"
PORT=$DEFAULT_PORT
EOF
log "[+] .env created"

# === Create placeholder files ===
touch "$WEB_DIR/routes/index.js"
touch "$WEB_DIR/controllers/homeController.js"
touch "$WEB_DIR/models/sampleModel.js"
touch "$WEB_DIR/views/index.html"

log "[+] Placeholder files created in routes/, controllers/, models/, views/"

log "✅ Web project structure created in '$WEB_DIR'"
