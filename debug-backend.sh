#!/bin/bash
# Debug Backend Issues

echo "🔍 Debugging Backend..."

# 1. Check PM2 logs
echo "📋 PM2 Logs (last 20 lines):"
pm2 logs nga-backend --lines 20

echo ""
echo "🛑 Stopping backend..."
pm2 delete nga-backend

echo ""
echo "📂 Checking backend directory..."
ls -la /var/www/html/nextgenerationaustria.at/political-app-api/

echo ""
echo "📄 Checking server.js..."
head -10 /var/www/html/nextgenerationaustria.at/political-app-api/server.js

echo ""
echo "📄 Checking .env file..."
ls -la /var/www/html/nextgenerationaustria.at/political-app-api/.env*

echo ""
echo "🚀 Starting backend manually to see errors..."
cd /var/www/html/nextgenerationaustria.at/political-app-api
node server.js &
sleep 3

echo ""
echo "🔍 Check if backend started..."
curl -I http://localhost:3000/health 2>/dev/null && echo "✅ Backend responding" || echo "❌ Backend not responding"

echo ""
echo "🛑 Killing manual process..."
pkill -f "node server.js"

echo ""
echo "🚀 Starting with PM2 again..."
pm2 start server.js --name nga-backend --log logs/app.log

echo ""
echo "📊 Final PM2 status:"
pm2 status
