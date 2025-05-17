<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8" />
<title>SetupWiz - Dokumentasi</title>
<style>
  body { font-family: Arial, sans-serif; max-width: 800px; margin: auto; padding: 20px; line-height: 1.6; }
  h1, h2 { color: #2c3e50; }
  pre { background: #f4f4f4; padding: 10px; overflow-x: auto; }
  code { background: #eee; padding: 2px 4px; border-radius: 3px; }
  ul { margin-top: 0; }
  hr { margin: 30px 0; }
</style>
</head>
<body>

<h1>🧙‍♂️ SetupWiz</h1>
<p>SetupWiz adalah skrip shell ajaib yang mengubah server Linux biasa (atau GitHub Codespace) menjadi lingkungan kerja siap pakai. Cocok untuk developer yang ingin menghemat waktu setup server atau provisioning VPS secara cepat, aman, dan konsisten.</p>

<h2>✨ Fitur Utama</h2>
<ul>
  <li>⚡ Setup sekali jalan — Jalankan 1 baris dan server langsung siap pakai</li>
  <li>🛠️ Instalasi alat penting: Git, Node.js, Nginx, MongoDB, PM2, dll.</li>
  <li>🔐 Setup SSL lokal (mkcert), firewall, dan keamanan dasar</li>
  <li>🧰 Buat struktur folder untuk proyek Express.js</li>
  <li>☁️ Cocok untuk Codespace, VPS, atau server lokal</li>
  <li>🔄 Mudah dikustomisasi sesuai stack atau teknologi kamu</li>
</ul>

<h2>📁 Struktur Direktori</h2>
<pre>
/workspaces/SetupWiz
│
├── Dockerfile                # File Docker untuk container Node.js
├── README.md                 # Dokumentasi proyek
├── config.js                 # Konfigurasi global (opsional)
├── deploy.sh                 # Script deploy aplikasi web (dengan PM2)
├── package.json              # Dependency proyek
├── server.js                 # Entry utama server (PM2 & Docker)
├── start_server.sh           # Jalankan server menggunakan PM2
│
├── setup.sh                  # Script utama setup server
├── setup_base.sh             # Install tools dasar: Git, curl, NPM, dll
├── setup_mongodb.sh          # Install dan setup MongoDB
├── setup_ssl.sh              # Install mkcert & setup SSL lokal
├── setup_web_structure.sh    # Buat struktur Express.js otomatis
│
└── webapp/                   # Proyek Express.js hasil setup
   ├── app.js                # File utama Express
   ├── controllers/
   ├── models/
   ├── routes/
   ├── views/
   └── public/
</pre>

<h2>🚀 Cara Penggunaan</h2>
<p><strong>Clone Repo</strong></p>
<pre><code>git clone https://github.com/yatotech/setupwiz.git
cd setupwiz
</code></pre>

<p><strong>Jadikan Skrip Eksekusi</strong></p>
<pre><code>chmod +x setup.sh
</code></pre>

<p><strong>Jalankan Setup Utama</strong></p>
<pre><code>./setup.sh
</code></pre>

<p><strong>Setup ini akan secara otomatis:</strong></p>
<ul>
  <li>Install tools dasar (curl, node, npm, dsb)</li>
  <li>Setup MongoDB dan user default</li>
  <li>Setup SSL lokal dengan mkcert</li>
  <li>Buat folder dan file webapp/</li>
  <li>Install dependency webapp</li>
  <li>Jalankan server menggunakan PM2</li>
</ul>

<h2>🔧 File Penting yang Dibutuhkan</h2>
<p>Pastikan file berikut tersedia di folder:</p>
<ul>
  <li>setup.sh, setup_base.sh, setup_mongodb.sh, setup_ssl.sh, setup_web_structure.sh</li>
  <li>server.js, package.json</li>
  <li>start_server.sh, deploy.sh</li>
  <li>(Opsional) .env, .gitignore, config.js, Dockerfile</li>
</ul>

<h2>🧪 Telah Diuji Pada</h2>
<ul>
  <li>Ubuntu 20.04 / 22.04</li>
  <li>Debian 11+</li>
  <li>GitHub Codespaces</li>
  <li>DigitalOcean / Linode / Vultr VPS</li>
</ul>

<h2>🧩 Kustomisasi Stack</h2>
<p>Buka file <code>setup.sh</code> dan tambahkan tools yang kamu butuhkan, misalnya:</p>
<pre><code># Install Docker
sudo apt install docker.io -y
</code></pre>
<p>Kamu juga bisa menambahkan:</p>
<ul>
  <li>Laravel / Composer</li>
  <li>Docker Compose</li>
  <li>CI/CD pipeline</li>
  <li>Reverse Proxy + Certbot</li>
  <li>Logging &amp; monitoring</li>
</ul>

<h2>🛡️ Peringatan Keamanan</h2>
<p>⚠️ Script ini melakukan perubahan sistem.<br/>
Harap review kode terlebih dahulu sebelum digunakan, terutama di server produksi.<br/>
Gunakan dengan tanggung jawab sendiri.</p>

<h2>📜 Lisensi</h2>
<p>MIT License © 2025 YatoTech</p>

</body>
</html>
