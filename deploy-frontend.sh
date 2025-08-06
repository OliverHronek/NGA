#!/bin/bash
# Deploy Flutter Web App to Server

echo "🚀 Deploying Flutter Frontend..."

# 1. Create frontend directory
echo "📁 Creating frontend directory..."
sudo mkdir -p /var/www/html/nextgenerationaustria.at/app
sudo chown -R oliver:oliver /var/www/html/nextgenerationaustria.at/app

# 2. Copy Flutter build files (assuming uploaded to /tmp/flutter-build)
echo "📋 Copying Flutter files..."
cp -r /tmp/flutter-build/* /var/www/html/nextgenerationaustria.at/app/ 2>/dev/null || echo "Flutter build files should be uploaded to /tmp/flutter-build first"

# 3. Set proper permissions
echo "🔐 Setting permissions..."
sudo chown -R www-data:www-data /var/www/html/nextgenerationaustria.at/app
sudo chmod -R 755 /var/www/html/nextgenerationaustria.at/app

echo "✅ Frontend deployment complete!"
echo ""
echo "📊 Directory structure:"
ls -la /var/www/html/nextgenerationaustria.at/app/
echo ""
echo "🌐 Frontend should be available at: http://nextgenerationaustria.at/app/"
