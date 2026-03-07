#!/usr/bin/env bash
set -e

DOMAIN="${1:?Usage: setup-server.sh <domain>}"
PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel)")
PROJECT_DIR="/opt/projects/${PROJECT_NAME}"

echo "▶ Updating system..."
sudo apt-get update -qq && sudo apt-get upgrade -y -qq

echo "▶ Installing system packages..."
sudo apt-get install -y -qq \
    python3 python3-pip python3-venv \
    nginx certbot python3-certbot-nginx \
    redis-server \
    git curl

# Uncomment your database of choice:
# sudo apt-get install -y -qq postgresql postgresql-contrib libpq-dev
sudo apt-get install -y -qq mysql-server default-libmysqlclient-dev

# Node.js via nvm
if ! command -v nvm &> /dev/null; then
    echo "▶ Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

echo "▶ Installing Node.js LTS..."
nvm install --lts
nvm use --lts
nvm alias default lts/*

echo "▶ Installing pm2..."
npm install -g pm2
PM2_STARTUP=$(pm2 startup | tail -1)
eval "$PM2_STARTUP"

echo "▶ Setting up static & media directories..."
sudo mkdir -p /var/www/${PROJECT_NAME}/{static,media}
sudo chown -R ubuntu:ubuntu /var/www/${PROJECT_NAME}

echo "▶ Setting up Nginx..."
sudo cp "${PROJECT_DIR}/devops/nginx/nginx.conf" "/etc/nginx/sites-available/${PROJECT_NAME}"
sudo cp "${PROJECT_DIR}/devops/nginx/location.conf" "/etc/nginx/conf.d/${PROJECT_NAME}.location"
sudo sed -i "s/__DOMAIN__/${DOMAIN}/g" "/etc/nginx/sites-available/${PROJECT_NAME}"
sudo sed -i "s/__PROJECT_NAME__/${PROJECT_NAME}/g" "/etc/nginx/sites-available/${PROJECT_NAME}"
sudo sed -i "s/__PROJECT_NAME__/${PROJECT_NAME}/g" "/etc/nginx/conf.d/${PROJECT_NAME}.location"
sudo ln -sf "/etc/nginx/sites-available/${PROJECT_NAME}" "/etc/nginx/sites-enabled/"
sudo nginx -t

echo "▶ Obtaining SSL certificate..."
sudo certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m "admin@${DOMAIN}"

echo "▶ Installing systemd services..."
sudo cp "${PROJECT_DIR}/devops/systemd/${PROJECT_NAME}.service" "/etc/systemd/system/${PROJECT_NAME}.service"
sudo cp "${PROJECT_DIR}/devops/systemd/worker1.service" "/etc/systemd/system/${PROJECT_NAME}-worker1.service"
sudo cp "${PROJECT_DIR}/devops/systemd/worker2.service" "/etc/systemd/system/${PROJECT_NAME}-worker2.service"
sudo sed -i "s/__PROJECT_NAME__/${PROJECT_NAME}/g" "/etc/systemd/system/${PROJECT_NAME}.service"
sudo sed -i "s/__PROJECT_NAME__/${PROJECT_NAME}/g" "/etc/systemd/system/${PROJECT_NAME}-worker1.service"
sudo sed -i "s/__PROJECT_NAME__/${PROJECT_NAME}/g" "/etc/systemd/system/${PROJECT_NAME}-worker2.service"

sudo systemctl daemon-reload
sudo systemctl enable redis-server
sudo systemctl enable "${PROJECT_NAME}" "${PROJECT_NAME}-worker1" "${PROJECT_NAME}-worker2"

echo ""
echo "✔ Server setup complete for $DOMAIN"
echo ""
echo "  Next steps:"
echo "  1. sudo timedatectl set-timezone Asia/Seoul  ← change if needed"
echo "  2. sudo ufw allow 80/tcp && sudo ufw allow 443/tcp"
echo "  3. sudo mysql"
echo "       CREATE USER 'ubuntu'@'localhost';"
echo "       GRANT ALL PRIVILEGES ON *.* TO 'ubuntu'@'localhost';"
echo "       CREATE DATABASE \`${PROJECT_NAME}\` DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;"
echo "  4. cp .env.example .env  →  fill in your values"
echo "  5. python3 -m venv backend/venv && pip install -r backend/requirements.txt"
echo "  6. make migrate && make createsuperuser && make collectstatic"
echo "  7. sudo systemctl start ${PROJECT_NAME} ${PROJECT_NAME}-worker1 ${PROJECT_NAME}-worker2"
echo "  8. cd frontend && npm run build"
echo "  9. pm2 start .output/server/index.mjs --name ${PROJECT_NAME}-frontend"
