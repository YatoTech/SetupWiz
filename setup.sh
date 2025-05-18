#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# === Konfigurasi Awal ===
LOG_DIR="logs"
ENV_FILE=".env"
DEFAULT_PORT=3000

# === Daftar Modular Script (base dulu) ===
SCRIPTS=(
  "setup_base.sh"
  "setup_mongodb.sh"
  "setup_ssl.sh"
  "setup_web_structure.sh"
  "install_npm_packages.sh"
  "start_server.sh"
)

# === Fungsi Logging ===
log_success() { echo -e "\e[32m[✓]\e[0m $1"; }
log_error()   { echo -e "\e[31m[✗]\e[0m $1"; exit 1; }
log_info()    { echo -e "\e[34m[i]\e[0m $1"; }

# === Pastikan Perintah Penting Ada ===
ensure_command() {
  local cmd="$1"
  case "$cmd" in
    node|npm)
      if ! command -v node >/dev/null 2>&1; then
        log_info "Installing Node.js & npm..."
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
        log_success "Node.js and npm installed"
      fi
      ;;
    pm2)
      if ! command -v pm2 >/dev/null 2>&1; then
        log_info "Installing PM2 globally..."
        sudo npm install -g pm2
        log_success "PM2 installed"
      fi
      ;;
    jq)
      if ! command -v jq >/dev/null 2>&1; then
        log_info "Installing jq..."
        sudo apt-get update
        sudo apt-get install -y jq
        log_success "jq installed"
      fi
      ;;
  esac
}

# === Jalankan Script Modular ===
run_step() {
  local step_name="$1"
  local script_name="$2"
  local log_file="$LOG_DIR/${script_name%.*}.log"

  echo -e "\n=== $step_name ==="
  log_info "Running $script_name..."

  if [ ! -f "$script_name" ]; then
    log_error "Script '$script_name' not found!"
  fi

  if [ ! -x "$script_name" ]; then
    chmod +x "$script_name"
  fi

  if ./"$script_name" > "$log_file" 2>&1; then
    log_success "$step_name completed"
  else
    log_error "$step_name failed. Check log: $log_file"
  fi
}

# === Tangkap CTRL+C ===
trap "echo -e '\n[!] Script interrupted. Exiting...'; exit 1" SIGINT SIGTERM

# === MULAI SETUP ===
echo -e "\n=== STARTING SERVER SETUP ==="
mkdir -p "$LOG_DIR"
log_success "Created log directory: $LOG_DIR"

# === Load .env ===
if [ ! -f "$ENV_FILE" ]; then
  log_error "Environment file '$ENV_FILE' not found. Please create it."
fi

load_env() {
  set -a
  grep -E '^[^#[:space:]]' "$ENV_FILE" | while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; then
      export "$line"
    fi
  done
  set +a
}
load_env
log_success "Environment variables loaded from $ENV_FILE"

# === Install Dependensi Utama ===
for cmd in node npm pm2 jq; do
  ensure_command "$cmd"
done

# === Eksekusi Modular Scripts (urut) ===
for script in "${SCRIPTS[@]}"; do
  step_name=$(echo "$script" | sed 's/\.sh$//' | tr '_' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')
  run_step "$step_name" "$script"
done

# === Ringkasan ===
PORT="${PORT:-$DEFAULT_PORT}"
MONGO_URI="${MONGO_URI:-mongodb://localhost:27017}"

echo -e "\n=== SUMMARY ==="
echo "✔ Node.js version     : $(node -v)"
echo "✔ npm version         : $(npm -v)"
echo "✔ MongoDB version     : $(mongod --version | head -n 1)"
echo "✔ PM2 version         : $(pm2 -v)"

echo -e "\n=== CONNECTION INFO ==="
echo "🌐 Web Server     : http://localhost:$PORT"
echo "🛢  MongoDB URI    : $MONGO_URI"

echo -e "\n=== PM2 COMMANDS ==="
echo "• pm2 list             # List all processes"
echo "• pm2 logs             # View application logs"
echo "• pm2 stop <name>      # Stop application"
echo "• pm2 restart <name>   # Restart application"
echo "• pm2 delete <name>    # Delete application"
echo "• pm2 monit            # Monitor processes"

log_success "Setup completed successfully!"
