# 🧙‍♂️ SetupWiz

**SetupWiz** is a magical shell script that instantly turns any Linux-based server (or GitHub Codespace) into a ready-to-code environment. Whether you're setting up a dev box or provisioning a new VPS, SetupWiz saves your time, eliminates repetitive work, and standardizes your configurations.

---

## ✨ Features

- ⚡ **One-liner setup** — Just run and let the magic begin
- 🛠️ Installs essential tools: `Git`, `Nginx`, `Node.js`, `PHP`, `MySQL`, etc.
- 🔐 Configures SSH keys, firewall rules, and basic security
- 🧰 Sets up common dev directories and permissions
- ☁️ Works on **Codespaces**, **VPS**, or **local Linux**
- 💡 Easily customizable for your stack

---

## 📦 What's Inside?

| Tool        | Purpose                      |
|-------------|------------------------------|
| `git`       | Version control              |
| `nginx`     | Web server                   |
| `php`       | Backend scripting            |
| `mysql`     | Database                     |
| `nodejs`    | JS runtime for fullstack dev |
| `ufw`       | Basic firewall configuration |
| `fail2ban`  | Brute-force protection       |
| `oh-my-zsh` | Beautiful terminal setup     |

> ⚙️ More packages can be added based on your needs.

---

## 🚀 Quick Start

### ✅ 1. Clone the Repo
bash
git clone https://github.com/yourusername/setupwiz.git
cd setupwiz

✅ 2. Make Script Executable
bash
chmod +x setup.sh

✅ 3. Run the Magic 🧙
bash
./setup.sh
🪄 That's it! Your environment is being prepared like a pro.

🧪 Tested On
✅ Ubuntu 20.04 / 22.04
✅ Debian 11+
✅ GitHub Codespaces (Ubuntu image)
✅ DigitalOcean / Linode / Vultr VPS

🧩 Customize Your Stack
Open the setup.sh file and edit the sections to suit your project needs:
# Example: install Docker
sudo apt install docker.io -y
You can also add:

Laravel / Composer
PM2 / Docker Compose
SSL certificates & NGINX configuration
CI/CD tools or deployment hooks

🛡️ Security Disclaimer
⚠️ This script makes changes to your system.
Please review the code before running it, especially in production environments.
Use at your own risk and responsibility.

📜 License
MIT License © 2025 YatoTech

