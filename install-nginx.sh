#!/bin/bash
# Install and configure Nginx

echo "📦 Installing Nginx..."

# 1. Install Nginx
sudo apt update
sudo apt install -y nginx

# 2. Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# 3. Create the site configuration
echo "🌐 Creating site configuration..."
sudo tee /etc/nginx/sites-available/nextgenerationaustria.at > /dev/null << 'EOF'
server {
    listen 80;
    server_name nextgenerationaustria.at www.nextgenerationaustria.at;
    root /var/www/html/nextgenerationaustria.at;
    index index.html;

    # Frontend (Flutter App)
    location /app/ {
        alias /var/www/html/nextgenerationaustria.at/app/;
        try_files $uri $uri/ /app/index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|wasm)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }

    # API Backend
    location /api/ {
        proxy_pass http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Health check endpoint
    location /health {
        proxy_pass http://localhost:3000/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Default redirect to app
    location = / {
        return 301 /app/;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
}
EOF

# 4. Enable the site
sudo ln -sf /etc/nginx/sites-available/nextgenerationaustria.at /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# 5. Test configuration
echo "🔍 Testing Nginx configuration..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Nginx configuration is valid"
    sudo systemctl reload nginx
    echo "🔄 Nginx reloaded"
else
    echo "❌ Nginx configuration has errors"
    exit 1
fi

# 6. Check status
echo "📊 Nginx status:"
sudo systemctl status nginx --no-pager

echo ""
echo "✅ Nginx setup complete!"
echo ""
echo "🌐 Website should now be available at:"
echo "   http://nextgenerationaustria.at/app/"
echo ""
echo "🔍 Test endpoints:"
echo "   curl http://nextgenerationaustria.at/health"
echo "   curl http://nextgenerationaustria.at/api/health"
echo ""
echo "📊 Check services:"
echo "   pm2 status"
echo "   sudo systemctl status nginx"
