🧙‍♂️ SetupWiz
SetupWiz adalah skrip shell ajaib yang mengubah server Linux biasa (atau GitHub Codespace) menjadi lingkungan kerja siap pakai. Cocok untuk developer yang ingin menghemat waktu setup server atau provisioning VPS secara cepat, aman, dan konsisten.

✨ Fitur Utama
⚡ Setup sekali jalan — Jalankan 1 baris dan server langsung siap pakai

🛠️ Instalasi alat penting: Git, Node.js, Nginx, MongoDB, PM2, dll.

🔐 Setup SSL lokal (mkcert), firewall, dan keamanan dasar

🧰 Buat struktur folder untuk proyek Express.js

☁️ Cocok untuk Codespace, VPS, atau server lokal

🔄 Mudah dikustomisasi sesuai stack atau teknologi kamu

📁 Struktur Direktori
/workspaces/SetupWiz
│
├── Dockerfile # File Docker untuk container Node.js
├── README.md # Dokumentasi proyek
├── config.js # Konfigurasi global (opsional)
├── deploy.sh # Script deploy aplikasi web (dengan PM2)
├── package.json # Dependency proyek
├── server.js # Entry utama server (PM2 & Docker)
├── start_server.sh # Jalankan server menggunakan PM2
│
├── setup.sh # Script utama setup server
├── setup_base.sh # Install tools dasar: Git, curl, NPM, dll
├── setup_mongodb.sh # Install dan setup MongoDB
├── setup_ssl.sh # Install mkcert & setup SSL lokal
├── setup_web_structure.sh # Buat struktur Express.js otomatis
│
└── webapp/ # Proyek Express.js hasil setup
  ├── app.js # File utama Express
  ├── controllers/
  ├── models/
  ├── routes/
  ├── views/
  └── public/

🚀 Cara Penggunaan
✅ 1. Clone Repo
bash
git clone https://github.com/yatotech/setupwiz.git
cd setupwiz

✅ 2. Jadikan Skrip Eksekusi
bash
chmod +x setup.sh

✅ 3. Jalankan Setup Utama
bash
./setup.sh
Setup ini akan secara otomatis:

Install tools dasar (curl, node, npm, dsb)

Setup MongoDB dan user default

Setup SSL lokal dengan mkcert

Buat folder dan file webapp/

Install dependency webapp

Jalankan server menggunakan PM2

🔧 File Penting yang Dibutuhkan
Pastikan file berikut tersedia:

setup.sh, setup_base.sh, setup_mongodb.sh, setup_ssl.sh, setup_web_structure.sh

server.js, package.json

start_server.sh, deploy.sh

(Opsional) .env, .gitignore, config.js, Dockerfile

🧪 Telah Diuji Pada
✅ Ubuntu 20.04 / 22.04

✅ Debian 11+

✅ GitHub Codespaces

✅ DigitalOcean / Linode / Vultr VPS

🧩 Kustomisasi Stack
Buka file setup.sh dan tambahkan tools yang kamu butuhkan, misalnya:

bash
# Install Docker
sudo apt install docker.io -y
Kamu juga bisa menambahkan:

Laravel / Composer

Docker Compose

CI/CD pipeline

Reverse Proxy + Certbot

Logging & monitoring

🛡️ Peringatan Keamanan
⚠️ Script ini melakukan perubahan sistem.
Harap review kode terlebih dahulu sebelum digunakan, terutama di server produksi.
Gunakan dengan tanggung jawab sendiri.

📜 Lisensi
MIT License © 2025 YatoTech