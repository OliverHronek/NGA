# NGA Backend Deployment Guide

## 🚀 Quick Deployment

### Method 1: Ubuntu/Debian Server (Recommended)

1. **Upload files to server:**
   ```bash
   scp -r deploy-backend/* user@your-server.com:/home/user/nga-backend/
   ```

2. **Connect to server and install:**
   ```bash
   ssh user@your-server.com
   cd nga-backend
   chmod +x install.sh
   ./install.sh
   ```

3. **Configure environment:**
   ```bash
   nano .env
   # Update all values with your production settings
   ```

4. **Start the application:**
   ```bash
   pm2 restart nga-backend
   ```

### Method 2: Manual Installation

1. **Install Node.js 18:**
   ```bash
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt-get install -y nodejs
   ```

2. **Install PM2:**
   ```bash
   sudo npm install -g pm2
   ```

3. **Set up application:**
   ```bash
   mkdir -p /var/www/nga-backend
   cd /var/www/nga-backend
   # Upload your files here
   npm ci --only=production
   ```

4. **Configure and start:**
   ```bash
   cp .env.production .env
   # Edit .env with your values
   pm2 start ecosystem.config.json
   ```

## 🔧 Configuration

### Environment Variables (.env)
```env
NODE_ENV=production
PORT=3000
DB_HOST=your-database-host
DB_USER=your-db-user
DB_PASSWORD=your-db-password
FRONTEND_URL=https://your-frontend-domain.com
JWT_SECRET=your-super-secure-secret
EMAIL_USER=your-email
EMAIL_PASS=your-email-password
```

### Nginx Reverse Proxy
```nginx
server {
    listen 80;
    server_name your-api-domain.com;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## 📊 Monitoring

### PM2 Commands
```bash
pm2 status           # Check application status
pm2 logs nga-backend # View logs
pm2 restart nga-backend # Restart application
pm2 stop nga-backend # Stop application
pm2 delete nga-backend # Remove from PM2
```

### Health Check
```bash
curl http://localhost:3000/health
```

## 🔒 Security

1. **Firewall:**
   ```bash
   sudo ufw allow 22    # SSH
   sudo ufw allow 80    # HTTP
   sudo ufw allow 443   # HTTPS
   sudo ufw enable
   ```

2. **SSL Certificate (Let's Encrypt):**
   ```bash
   sudo apt install certbot nginx
   sudo certbot --nginx -d your-api-domain.com
   ```

## 🔄 Updates

```bash
# Stop application
pm2 stop nga-backend

# Update code
git pull  # or upload new files

# Install dependencies
npm ci --only=production

# Restart application
pm2 restart nga-backend
```

## 🆘 Troubleshooting

### Common Issues

1. **Port already in use:**
   ```bash
   sudo lsof -i :3000
   sudo kill -9 <PID>
   ```

2. **Permission errors:**
   ```bash
   sudo chown -R $USER:$USER /var/www/nga-backend
   ```

3. **Database connection issues:**
   - Check firewall settings
   - Verify database credentials
   - Test connection: `telnet your-db-host 5432`

### Logs
```bash
# Application logs
pm2 logs nga-backend

# System logs
sudo journalctl -f

# Nginx logs
sudo tail -f /var/log/nginx/error.log
```

## 📁 File Structure
```
deploy-backend/
├── server.js                 # Main server file
├── package.json              # Dependencies
├── .env.production           # Environment template
├── ecosystem.config.json     # PM2 configuration
├── install.sh               # Installation script
├── controllers/             # API controllers
├── routes/                  # API routes
├── middleware/              # Express middleware
├── models/                  # Data models
├── config/                  # Configuration files
└── utils/                   # Utility functions
```
