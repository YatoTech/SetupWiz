#!/bin/bash

LOG_DIR="logs"
SCRIPTS=("setup_base.sh" "setup_mongodb.sh" "setup_ssl.sh" "setup_web_structure.sh" "install_npm_packages.sh" "start_server.sh")
ENV_FILE=".env"
DEFAULT_PORT=3000

log_success() {
    echo -e "\e[32m[✓]\e[0m $1"
}

log_error() {
    echo -e "\e[31m[✗]\e[0m $1"
    exit 1
}

check_command() {
    command -v "$1" >/dev/null 2>&1 || log_error "Command '$1' not found. Please install it first."
}

run_step() {
    local step_name=$1
    local script_name=$2
    local log_file="$LOG_DIR/${script_name%.*}.log"

    echo -e "\n=== $step_name ==="
    echo "[+] Running $script_name..."

    if [ -f "$script_name" ]; then
        chmod +x "$script_name"
        ./"$script_name" > "$log_file" 2>&1
        if [ $? -eq 0 ]; then
            log_success "$step_name completed"
        else
            log_error "$step_name failed. Check log: $log_file"
        fi
    else
        log_error "$script_name not found"
    fi
}

trap "echo -e '\nScript interrupted. Exiting...'; exit 1" SIGINT SIGTERM

# Cek dependensi
check_command "node"
check_command "npm"
check_command "mongod"
check_command "pm2"

echo -e "\n=== STARTING SERVER SETUP (MODULAR) ==="

mkdir -p "$LOG_DIR"
log_success "Created log directory: $LOG_DIR"

if [ ! -f "$ENV_FILE" ]; then
    log_error "Environment file '$ENV_FILE' not found. Please create it before running setup."
fi

# Load environment variables for sub scripts if needed
export $(grep -v '^#' $ENV_FILE | xargs)

for script in "${SCRIPTS[@]}"; do
    step_name=$(echo "$script" | sed 's/\.sh//g' | tr _ ' ' | tr 'a-z' 'A-Z')
    run_step "$step_name" "$script"
done

# Ambil nilai PORT dan MONGO_URI dari .env, jika kosong set default
PORT=$(grep -w PORT "$ENV_FILE" | cut -d '=' -f2)
MONGO_URI=$(grep -w MONGO_URI "$ENV_FILE" | cut -d '=' -f2)
PORT=${PORT:-$DEFAULT_PORT}
MONGO_URI=${MONGO_URI:-"mongodb://localhost:27017"}

echo -e "\nServer components:"
echo "1. Node.js $(node -v)"
echo "2. npm $(npm -v)"
echo "3. MongoDB $(mongod --version | head -n 1)"
echo "4. PM2 $(pm2 --version)"

echo -e "\nConnection information:"
echo "- Web server: http://localhost:$PORT"
echo "- MongoDB URI: $MONGO_URI"

echo -e "\nPM2 Management Commands:"
echo "• pm2 list           # List applications"
echo "• pm2 logs           # View logs"
echo "• pm2 stop <name>    # Stop application"
echo "• pm2 restart <name> # Restart application"

log_success "Setup completed successfully!"
