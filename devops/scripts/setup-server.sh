#!/usr/bin/env bash
set -e

DOMAIN="${1:?Usage: setup-server.sh <domain>}"
PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel)")
PROJECT_DIR="/var/www/${PROJECT_NAME}"

echo "▶ Updating system..."
sudo apt-get update -qq && sudo apt-get upgrade -y -qq

echo "▶ Installing system packages..."
sudo apt-get install -y -qq \
    python3 python3-pip python3-venv \
    nginx certbot python3-certbot-nginx \
    redis-server \
    git curl

# PostgreSQL
sudo apt-get install -y -qq postgresql postgresql-contrib libpq-dev
# MySQL (uncomment if using MySQL instead)
# sudo apt-get install -y -qq mysql-server default-libmysqlclient-dev

# Node.js LTS
if ! command -v node &> /dev/null; then
    echo "▶ Installing Node.js LTS..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

echo "▶ Setting up project directory..."
sudo mkdir -p "$PROJECT_DIR"
sudo chown "$USER":www-data "$PROJECT_DIR"

echo "▶ Setting up Nginx..."
sudo cp "${PROJECT_DIR}/devops/nginx/nginx.conf" "/etc/nginx/sites-available/${PROJECT_NAME}"
sudo sed -i "s/__DOMAIN__/${DOMAIN}/g" "/etc/nginx/sites-available/${PROJECT_NAME}"
sudo sed -i "s/__PROJECT_NAME__/${PROJECT_NAME}/g" "/etc/nginx/sites-available/${PROJECT_NAME}"
sudo ln -sf "/etc/nginx/sites-available/${PROJECT_NAME}" "/etc/nginx/sites-enabled/"
sudo nginx -t

echo "▶ Obtaining SSL certificate..."
sudo certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m "admin@${DOMAIN}"

echo "▶ Installing systemd services..."
# Rename project service file
sudo cp "${PROJECT_DIR}/devops/systemd/__PROJECT_NAME__.service" "/etc/systemd/system/${PROJECT_NAME}.service"
sudo sed -i "s/__PROJECT_NAME__/${PROJECT_NAME}/g" "/etc/systemd/system/${PROJECT_NAME}.service"
sudo cp "${PROJECT_DIR}/devops/systemd/worker1.service" /etc/systemd/system/worker1.service
sudo cp "${PROJECT_DIR}/devops/systemd/worker2.service" /etc/systemd/system/worker2.service
sudo sed -i "s/__PROJECT_NAME__/${PROJECT_NAME}/g" /etc/systemd/system/worker1.service
sudo sed -i "s/__PROJECT_NAME__/${PROJECT_NAME}/g" /etc/systemd/system/worker2.service

sudo systemctl daemon-reload
sudo systemctl enable redis-server
sudo systemctl enable "${PROJECT_NAME}" worker1 worker2
sudo systemctl start "${PROJECT_NAME}" worker1 worker2

echo "✔ Server setup complete for $DOMAIN"
