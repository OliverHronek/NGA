#!/bin/bash
# Quick Fix Script für NGA Backend auf dem Server

echo "🔧 NGA Backend Quick Fix..."

# 1. Node.js Version prüfen
echo "📋 Current Node.js version:"
node --version
npm --version

# 2. Alte Node.js Version entfernen (falls snap installiert)
echo "🗑️ Removing old Node.js versions..."
sudo snap remove node --purge 2>/dev/null || echo "No snap node found"

# 3. Neue Node.js 18 installieren
echo "📦 Installing Node.js 18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 4. PM2 installieren
echo "🚀 Installing PM2..."
sudo npm install -g pm2

# 5. Zum App-Verzeichnis wechseln
cd /home/oliver/www/political-app-api || {
    echo "❌ Directory not found! Checking alternative locations..."
    cd /var/www/html/nextgenerationaustria.at/political-app-api || {
        echo "❌ App directory not found!"
        exit 1
    }
}

echo "📁 Working in: $(pwd)"

# 6. Dependencies neu installieren
echo "📦 Installing dependencies..."
rm -rf node_modules package-lock.json
npm install

# 7. Environment-Datei prüfen
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cp .env.production .env 2>/dev/null || {
        echo "Creating basic .env..."
        cat > .env << EOF
NODE_ENV=production
PORT=3000
DB_HOST=nextgenerationaustria.at
DB_PORT=5432
DB_NAME=ngadatabase
DB_USER=adminuser
DB_PASSWORD=NextGenPassword2024!
DB_SSL=false
JWT_SECRET=your-jwt-secret-change-me
FRONTEND_URL=https://nextgenerationaustria.at
EOF
    }
fi

# 8. Logs-Verzeichnis erstellen
mkdir -p logs

# 9. PM2 stoppen falls läuft
echo "🛑 Stopping existing processes..."
pm2 delete nga-backend 2>/dev/null || echo "No existing process"

# 10. Direkt mit Node.js testen
echo "🧪 Testing direct Node.js start..."
timeout 5s node server.js || echo "Direct start test completed"

# 11. Mit PM2 starten
echo "🚀 Starting with PM2..."
pm2 start server.js --name nga-backend --log logs/app.log
pm2 save

echo "✅ Quick fix completed!"
echo ""
echo "📊 Status check:"
pm2 status
echo ""
echo "📋 Next steps:"
echo "1. Check logs: pm2 logs nga-backend"
echo "2. Test API: curl http://localhost:3000/health"
echo "3. Check process: pm2 monit"
