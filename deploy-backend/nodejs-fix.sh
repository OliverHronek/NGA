#!/bin/bash
# Komplette Node.js Neuinstallation für NGA Backend

echo "🔧 Fixing Node.js installation..."

# 1. Alte Snap-Versionen komplett entfernen
echo "🗑️ Removing old snap Node.js..."
sudo snap remove node --purge 2>/dev/null || echo "No snap node found"
sudo snap remove npm --purge 2>/dev/null || echo "No snap npm found"
sudo snap remove nodejs --purge 2>/dev/null || echo "No snap nodejs found"

# 2. Alte APT-Versionen entfernen
echo "🗑️ Removing old apt Node.js..."
sudo apt-get remove -y nodejs npm
sudo apt-get autoremove -y

# 3. Alte Repository-Keys entfernen
sudo rm -f /etc/apt/sources.list.d/nodesource.list
sudo rm -f /usr/share/keyrings/nodesource.gpg

# 4. System aktualisieren
echo "📦 Updating system..."
sudo apt update

# 5. Neue Node.js 18 installieren
echo "📦 Installing Node.js 18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 6. Versionen prüfen
echo "📋 Checking versions..."
node --version
npm --version

# 7. PM2 installieren
echo "🚀 Installing PM2..."
sudo npm install -g pm2

# 8. Zum App-Verzeichnis
cd /home/oliver/www/political-app-api || cd /var/www/html/nextgenerationaustria.at/political-app-api

# 9. Dependencies installieren
echo "📦 Installing app dependencies..."
rm -rf node_modules package-lock.json
npm install

echo "✅ Node.js fix completed!"
echo ""
echo "📊 Final check:"
node --version
npm --version
pm2 --version
