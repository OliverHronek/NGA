#!/bin/bash
# Fix bcrypt installation on server

echo "🔧 Fixing bcrypt installation..."

cd /var/www/html/nextgenerationaustria.at/political-app-api

# 1. Install build tools
echo "📦 Installing build tools..."
sudo apt-get update
sudo apt-get install -y build-essential python3-dev make g++

# 2. Clean install
echo "🗑️ Cleaning old installation..."
rm -rf node_modules package-lock.json

# 3. Install dependencies
echo "📦 Installing dependencies..."
npm install

# 4. Explicitly install bcrypt if still failing
echo "🔐 Installing bcrypt..."
npm install bcrypt --build-from-source

# 5. Stop existing process
echo "🛑 Stopping existing process..."
pm2 delete nga-backend 2>/dev/null || echo "No existing process"

# 6. Start fresh
echo "🚀 Starting application..."
pm2 start server.js --name nga-backend --log logs/app.log
pm2 save

echo "✅ Fix completed!"
echo ""
echo "📊 Status:"
pm2 status
echo ""
echo "📋 Test API:"
echo "curl http://localhost:3000/health"
