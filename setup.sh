#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# === Konfigurasi Awal ===
LOG_DIR="logs"
SCRIPTS=("setup_base.sh" "setup_mongodb.sh" "setup_ssl.sh" "setup_web_structure.sh" "install_npm_packages.sh" "start_server.sh")
ENV_FILE=".env"
DEFAULT_PORT=3000

# === Fungsi Logging ===
log_success() {
    echo -e "\e[32m[✓]\e[0m $1"
}

log_error() {
    echo -e "\e[31m[✗]\e[0m $1"
    exit 1
}

log_info() {
    echo -e "\e[34m[i]\e[0m $1"
}

# === Validasi Dependensi ===
check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        log_error "Command '$1' not found. Please install it first."
    fi
}

# === Fungsi Eksekusi Modular ===
run_step() {
    local step_name="$1"
    local script_name="$2"
    local log_file="$LOG_DIR/${script_name%.*}.log"

    echo -e "\n=== $step_name ==="
    log_info "Running $script_name..."

    if [ ! -f "$script_name" ]; then
        log_error "Script '$script_name' not found!"
    fi

    # Pastikan script executable
    if [ ! -x "$script_name" ]; then
        chmod +x "$script_name"
    fi

    # Eksekusi script dan redirect stdout+stderr ke log_file
    if ./"$script_name" > "$log_file" 2>&1; then
        log_success "$step_name completed"
    else
        log_error "$step_name failed. Check log file: $log_file"
    fi
}

# === Trap Keyboard Interrupt ===
trap "echo -e '\nScript interrupted. Exiting...'; exit 1" SIGINT SIGTERM

# === Mulai Proses ===
echo -e "\n=== STARTING SERVER SETUP (MODULAR) ==="

# Buat direktori log jika belum ada
mkdir -p "$LOG_DIR"
log_success "Created log directory: $LOG_DIR"

# Cek file .env
if [ ! -f "$ENV_FILE" ]; then
    log_error "Environment file '$ENV_FILE' not found. Please create it before running setup."
fi

# Fungsi load environment dengan mengabaikan komentar dan baris kosong
load_env() {
    set -a
    # Hanya ambil baris yang bukan komentar dan bukan kosong
    grep -E '^[^#[:space:]]' "$ENV_FILE" | while IFS= read -r line || [ -n "$line" ]; do
        # Validasi format KEY=VALUE sebelum export
        if [[ "$line" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; then
            export "$line"
        fi
    done
    set +a
}
load_env
log_success "Environment variables loaded from $ENV_FILE"

# Validasi dependensi yang dibutuhkan
for cmd in node npm mongod pm2 jq; do
    check_command "$cmd"
done

# Jalankan setiap script setup secara berurutan
for script in "${SCRIPTS[@]}"; do
    # Format step name: hapus ekstensi, ganti _ jadi spasi, kapitalisasi tiap kata
    step_name=$(echo "$script" | sed 's/\.sh$//' | tr '_' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')
    run_step "$step_name" "$script"
done

# Ambil nilai dari environment atau default jika tidak tersedia
PORT="${PORT:-$DEFAULT_PORT}"
MONGO_URI="${MONGO_URI:-mongodb://localhost:27017}"

# === Ringkasan Setup ===
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
