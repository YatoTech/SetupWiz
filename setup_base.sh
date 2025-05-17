#!/bin/bash

# setup_base.sh - Setup dasar server

# Fungsi untuk menampilkan pesan dengan warna
function colored_echo() {
    local color=$1
    local message=$2
    case $color in
        "red")     echo -e "\033[31m$message\033[0m" ;;
        "green")   echo -e "\033[32m$message\033[0m" ;;
        "yellow")  echo -e "\033[33m$message\033[0m" ;;
        "blue")    echo -e "\033[34m$message\033[0m" ;;
        *)         echo "$message" ;;
    esac
}

# Fungsi untuk memeriksa apakah perintah berhasil
function check_success() {
    if [ $? -eq 0 ]; then
        colored_echo "green" "[SUKSES] $1"
    else
        colored_echo "red" "[GAGAL] $1"
        exit 1
    fi
}

# 1. Update sistem
colored_echo "blue" "\n1. Memperbarui sistem..."
sudo apt-get update -y && sudo apt-get upgrade -y
check_success "Update sistem"

# 2. Install Node.js
colored_echo "blue" "\n2. Menginstal Node.js dan npm..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
check_success "Instalasi Node.js dan npm"

# 3. Install PM2
colored_echo "blue" "\n3. Menginstal PM2..."
sudo npm install -g pm2
check_success "Instalasi PM2"

# 4. Setup environment variables
colored_echo "blue" "\n4. Setup environment variables..."
if [ ! -f .env ]; then
  cat > .env <<EOL
PORT=3000
NODE_ENV=development
EOL
  colored_echo "green" "File .env telah dibuat"
else
  colored_echo "yellow" "File .env sudah ada, tidak dibuat baru"
fi

# 5. Install dependensi
colored_echo "blue" "\n5. Menginstal dependensi proyek..."
npm install
check_success "Instalasi dependensi"

colored_echo "green" "\nSetup dasar selesai!"