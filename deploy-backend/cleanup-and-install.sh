#!/bin/bash
# APT Lock Cleanup und Node.js Installation

echo "🔧 Cleaning up APT locks..."

# 1. Alle apt-Prozesse beenden
echo "🛑 Stopping apt processes..."
sudo killall apt apt-get 2>/dev/null || echo "No apt processes running"

# 2. Spezifische Prozesse beenden
sudo kill -9 6976 2>/dev/null || echo "Process 6976 not found"

# 3. Lock-Dateien entfernen
echo "🗑️ Removing lock files..."
sudo rm -f /var/lib/apt/lists/lock
sudo rm -f /var/cache/apt/archives/lock
sudo rm -f /var/lib/dpkg/lock*

# 4. dpkg reparieren
echo "🔧 Configuring dpkg..."
sudo dpkg --configure -a

# 5. System aktualisieren
echo "📦 Updating package lists..."
sudo apt update

# 6. Snap Node.js entfernen
echo "🗑️ Removing snap Node.js..."
sudo snap remove node --purge 2>/dev/null || echo "No snap node found"
sudo snap remove npm --purge 2>/dev/null || echo "No snap npm found"

# 7. Alte Node.js APT-Versionen entfernen
echo "🗑️ Removing old Node.js..."
sudo apt-get remove -y nodejs npm 2>/dev/null || echo "No old nodejs found"
sudo apt-get autoremove -y

# 8. Node.js 18 Repository hinzufügen
echo "📦 Adding Node.js 18 repository..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -

# 9. Node.js installieren
echo "📦 Installing Node.js 18..."
sudo apt-get install -y nodejs

# 10. Versionen prüfen
echo "📋 Checking versions..."
node --version
npm --version

# 11. PM2 installieren
echo "🚀 Installing PM2..."
sudo npm install -g pm2

echo "✅ Setup completed!"
echo ""
echo "📊 Final versions:"
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "PM2: $(pm2 --version)"
