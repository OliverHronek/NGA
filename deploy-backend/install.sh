#!/bin/bash
# NGA Backend Installation Script

echo "Installing NGA Backend..."

# 1. Update system
sudo apt update && sudo apt upgrade -y

# 2. Install Node.js 18 and build tools
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs build-essential python3-dev make g++

# 3. Install PM2 process manager
sudo npm install -g pm2

# 4. Create application directory
#sudo mkdir -p /var/www/html/nextgenerationaustria.at/political-app-api
sudo chown -R oliver:oliver /var/www/html/nextgenerationaustria.at/political-app-api

# 5. Copy files (assuming you've already uploaded them)
echo "Copying files to /var/www/html/nextgenerationaustria.at/political-app-api..."
cp -r /tmp/deploy-backend/* /var/www/html/nextgenerationaustria.at/political-app-api/ 2>/dev/null || echo "Files should be uploaded to current directory first"
cd /var/www/html/nextgenerationaustria.at/political-app-api

# 6. Install dependencies
echo "Installing Node.js dependencies..."
npm install

# 7. Create logs directory
mkdir -p logs

# 8. Set up environment
echo "Setting up environment..."
cp .env.production .env
echo "IMPORTANT: Edit .env file with your production values!"

# 9. Start with PM2
echo "Starting application with PM2..."
pm2 start ecosystem.config.json
pm2 save
pm2 startup

echo "Installation complete!"
echo ""
echo "Next steps:"
echo "1. Edit .env file with production values: nano .env"
echo "2. Configure your domain and SSL"
echo "3. Set up Nginx reverse proxy"
echo "4. Test API: curl http://nextgenerationaustria.at/app:3000/health"
echo ""
echo "PM2 commands:"
echo "  pm2 status          - Check status"
echo "  pm2 logs nga-backend - View logs"
echo "  pm2 restart nga-backend - Restart app"
