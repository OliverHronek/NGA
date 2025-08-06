#!/bin/bash
# Fix Nginx port conflict

echo "🔍 Checking what's using port 80..."
sudo netstat -tulpn | grep :80

echo ""
echo "🛑 Stopping Apache (if running)..."
sudo systemctl stop apache2 2>/dev/null || echo "Apache not running"
sudo systemctl disable apache2 2>/dev/null || echo "Apache not installed"

echo ""
echo "🔍 Checking port 80 again..."
sudo netstat -tulpn | grep :80

echo ""
echo "🚀 Starting Nginx..."
sudo systemctl start nginx

echo ""
echo "📊 Nginx status:"
sudo systemctl status nginx --no-pager

echo ""
echo "🔍 Port 80 status now:"
sudo netstat -tulpn | grep :80

echo ""
echo "✅ Testing endpoints:"
echo "Frontend: curl -I http://nextgenerationaustria.at/app/"
echo "API: curl -I http://nextgenerationaustria.at/health"

curl -I http://localhost/app/ 2>/dev/null || echo "❌ Frontend not accessible"
curl -I http://localhost/health 2>/dev/null || echo "❌ Health endpoint not accessible"
