#!/bin/bash
# Fix Port 3000 Conflict

echo "🔍 Checking port 3000..."
sudo netstat -tulpn | grep :3000
sudo lsof -i :3000

echo ""
echo "🛑 Killing processes on port 3000..."
sudo pkill -f "node.*3000"
sudo fuser -k 3000/tcp 2>/dev/null || echo "No process to kill"

echo ""
echo "⏱️ Waiting 3 seconds..."
sleep 3

echo ""
echo "🔍 Checking port 3000 again..."
sudo netstat -tulpn | grep :3000 || echo "Port 3000 is now free"

echo ""
echo "🚀 Restarting backend..."
pm2 restart nga-backend

echo ""
echo "⏱️ Waiting 5 seconds for startup..."
sleep 5

echo ""
echo "📊 PM2 Status:"
pm2 status

echo ""
echo "🧪 Testing backend:"
curl -I http://localhost:3000/health 2>/dev/null && echo "✅ Backend responding" || echo "❌ Backend not responding"

echo ""
echo "🧪 Testing via Nginx:"
curl -I http://localhost/health 2>/dev/null && echo "✅ Nginx proxy working" || echo "❌ Nginx proxy not working"

echo ""
echo "📋 Recent logs:"
pm2 logs nga-backend --lines 3
