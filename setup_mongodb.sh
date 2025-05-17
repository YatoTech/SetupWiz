#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# === Load from .env if exists ===
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# === Configuration ===
BASE_DIR=$(pwd)/mongodb
DATA_DIR="$BASE_DIR/data/db"
LOG_DIR="$BASE_DIR/mongodb_logs"
CONFIG_FILE="$BASE_DIR/mongodb_config.conf"
MONGO_LOG="$LOG_DIR/mongodb.log"
LOG_FILE="$LOG_DIR/setup_mongodb.log"
pidFile="$BASE_DIR/mongod.pid"

PORT=${MONGO_PORT:-27017}
BIND_IP=${MONGO_HOST:-127.0.0.1}
ADMIN_USER=${MONGO_ROOT_USER:-admin}
ADMIN_PASS=${MONGO_ROOT_PASS:-adminpass}
APP_DB=${MONGO_APP_DB:-appdb}
APP_USER=${MONGO_APP_USER:-appuser}
APP_PASS=${MONGO_APP_PASS:-appsecret}

# === Setup log directory and capture all output ===
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

log() { echo "$(date '+%F %T') - $1"; }

clean_existing_mongo() {
  log "Cleaning up previous MongoDB setup..."
  if [ -f "$pidFile" ]; then
    pid=$(cat "$pidFile")
    if ps -p "$pid" &>/dev/null; then
      log "Killing existing mongod process ($pid)..."
      kill "$pid"
      sleep 2
    fi
    rm -f "$pidFile"
  fi

  if [ -d "$DATA_DIR" ]; then
    log "Deleting data directory..."
    rm -rf "$DATA_DIR"
  fi
}

install_mongodb() {
  if ! command -v mongosh &>/dev/null || ! command -v mongod &>/dev/null; then
    log "Installing MongoDB..."
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu \
    $(lsb_release -cs)/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

    sudo apt-get update
    sudo apt-get install -y mongodb-org
  else
    log "MongoDB already installed."
  fi
}

write_config() {
  log "Writing mongod configuration..."
  mkdir -p "$DATA_DIR"

  cat > "$BASE_DIR/mongod.conf" <<EOF
systemLog:
  destination: file
  path: "$MONGO_LOG"
  logAppend: true

storage:
  dbPath: "$DATA_DIR"

net:
  port: $PORT
  bindIp: $BIND_IP

processManagement:
  pidFilePath: "$pidFile"

security:
  authorization: enabled
EOF
}

start_mongodb() {
  log "Starting MongoDB with config: $BASE_DIR/mongod.conf"
  mongod --config "$BASE_DIR/mongod.conf" --fork

  for i in {1..5}; do
    if mongosh --quiet --eval "db.adminCommand({ ping: 1 })"; then
      log "MongoDB is now running"
      return 0
    fi
    log "Waiting for MongoDB to respond... ($i/5)"
    sleep 2
  done

  log "MongoDB failed to start. Last log lines:"
  tail -20 "$MONGO_LOG"
  exit 1
}

create_users() {
  log "Creating admin user..."
  mongosh admin --eval "
    db.createUser({
      user: '$ADMIN_USER',
      pwd: '$ADMIN_PASS',
      roles: [ { role: 'root', db: 'admin' } ]
    })
  "

  log "Restarting MongoDB with auth enabled..."
  if [ -f "$pidFile" ]; then
    kill $(cat "$pidFile")
    sleep 2
    rm -f "$pidFile"
  fi
  mongod --config "$BASE_DIR/mongod.conf" --fork

  log "Creating application user..."
  mongosh admin -u "$ADMIN_USER" -p "$ADMIN_PASS" --authenticationDatabase admin --eval "
    db = db.getSiblingDB('$APP_DB');
    db.createUser({
      user: '$APP_USER',
      pwd: '$APP_PASS',
      roles: [ { role: 'readWrite', db: '$APP_DB' } ]
    })
  "
}

save_config() {
  log "Saving configuration summary..."
  cat > "$CONFIG_FILE" <<EOF
PORT=$PORT
BIND_IP=$BIND_IP
DATA_DIR=$DATA_DIR
LOG_FILE=$MONGO_LOG
ADMIN_USER=$ADMIN_USER
ADMIN_PASS=$ADMIN_PASS
APP_DB=$APP_DB
APP_USER=$APP_USER
APP_PASS=$APP_PASS
MONGO_URI=mongodb://$APP_USER:$APP_PASS@$BIND_IP:$PORT/$APP_DB?authSource=admin
EOF
  chmod 600 "$CONFIG_FILE"
}

main() {
  log "==== Starting MongoDB Setup ===="
  clean_existing_mongo
  install_mongodb
  write_config
  start_mongodb
  create_users
  save_config

  log "✅ MongoDB setup complete."
  echo ""
  echo "MongoDB berjalan di port $PORT"
  echo "📁 Log MongoDB: $MONGO_LOG"
  echo "📄 Konfigurasi: $CONFIG_FILE"
  echo "🔗 URI koneksi:"
  echo "mongodb://$APP_USER:*****@$BIND_IP:$PORT/$APP_DB?authSource=admin"
}

main
