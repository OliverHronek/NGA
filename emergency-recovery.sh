#!/bin/bash
# Emergency Server Recovery Script

echo "🚨 Emergency Server Recovery..."

# 1. Check what's running
echo "📊 Current service status:"
sudo systemctl status nginx --no-pager | head -5
sudo systemctl status apache2 --no-pager | head -5

# 2. Check ports
echo ""
echo "🔍 Port 80 usage:"
sudo netstat -tulpn | grep :80

# 3. Kill anything on port 80
echo ""
echo "🛑 Stopping services on port 80..."
sudo systemctl stop apache2 2>/dev/null || echo "Apache not running"
sudo systemctl stop nginx 2>/dev/null || echo "Nginx not running"
sudo pkill -f "nginx"
sudo pkill -f "apache"

# 4. Wait and check
sleep 2
echo ""
echo "🔍 Port 80 after cleanup:"
sudo netstat -tulpn | grep :80 || echo "Port 80 is now free"

# 5. Start Nginx fresh
echo ""
echo "🚀 Starting Nginx..."
sudo systemctl start nginx

# 6. Check status
echo ""
echo "📊 Nginx status after restart:"
sudo systemctl status nginx --no-pager

# 7. Test locally
echo ""
echo "🧪 Local tests:"
curl -I http://localhost/ 2>/dev/null && echo "✅ Port 80 responding" || echo "❌ Port 80 not responding"
curl -I http://localhost/app/ 2>/dev/null && echo "✅ Frontend accessible" || echo "❌ Frontend not accessible"
curl -I http://localhost/health 2>/dev/null && echo "✅ Health endpoint accessible" || echo "❌ Health endpoint not accessible"

# 8. Check backend
echo ""
echo "📊 Backend status:"
pm2 status

# 9. Test backend directly
echo ""
echo "🧪 Backend test:"
curl -I http://localhost:3000/health 2>/dev/null && echo "✅ Backend responding" || echo "❌ Backend not responding"

echo ""
echo "✅ Recovery attempt complete!"
echo ""
echo "🌐 Try accessing: http://nextgenerationaustria.at/app/"
