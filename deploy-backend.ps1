#!/usr/bin/env pwsh
# Backend-Deployment Skript für NGA

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("development", "production", "staging")]
    [string]$Environment = "production",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipBuild,
    
    [Parameter(Mandatory=$false)]
    [switch]$InstallDependencies
)

Write-Host "🚀 NGA Backend Deployment" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green
Write-Host "Environment: $Environment" -ForegroundColor Cyan

$backendPath = "backend"
$deployPath = "deploy-backend"

# Prüfen ob Backend-Verzeichnis existiert
if (-not (Test-Path $backendPath)) {
    Write-Host "❌ Backend directory not found!" -ForegroundColor Red
    exit 1
}

# 1. Deploy-Verzeichnis vorbereiten
Write-Host "📁 Preparing deployment directory..." -ForegroundColor Yellow
if (Test-Path $deployPath) {
    Remove-Item $deployPath -Recurse -Force
}
New-Item -ItemType Directory -Path $deployPath | Out-Null

# 2. Backend-Dateien kopieren
Write-Host "📋 Copying backend files..." -ForegroundColor Yellow
$filesToCopy = @(
    "package.json",
    "package-lock.json", 
    "server.js",
    "controllers",
    "routes", 
    "middleware",
    "models",
    "config",
    "utils"
)

foreach ($file in $filesToCopy) {
    $sourcePath = Join-Path $backendPath $file
    if (Test-Path $sourcePath) {
        $targetPath = Join-Path $deployPath $file
        if (Test-Path $sourcePath -PathType Container) {
            Copy-Item $sourcePath $targetPath -Recurse
        } else {
            Copy-Item $sourcePath $targetPath
        }
        Write-Host "   ✅ Copied: $file" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Missing: $file" -ForegroundColor Yellow
    }
}

# 3. Produktions-Umgebung erstellen
Write-Host "🔧 Creating production environment file..." -ForegroundColor Yellow
$envContent = @"
# Produktions-Umgebung für NGA Backend
NODE_ENV=$Environment
PORT=3000

# Datenbank-Konfiguration
DB_HOST=nextgenerationaustria.at
DB_PORT=5432
DB_NAME=ngadatabase
DB_USER=adminuser
DB_PASSWORD=NextGenPassword2024!
DB_SSL=false

# JWT-Konfiguration
JWT_SECRET=your-super-secure-jwt-secret-key-here-change-in-production
JWT_EXPIRES_IN=7d

# CORS-Konfiguration
FRONTEND_URL=https://your-domain.com

# E-Mail-Konfiguration
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=registrierung@ld2.at
EMAIL_PASS=your-email-password-here

# Logging
LOG_LEVEL=info
LOG_FILE=./logs/app.log

# Security
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
"@

$envContent | Out-File -FilePath (Join-Path $deployPath ".env") -Encoding UTF8
Write-Host "   ✅ Created .env file (IMPORTANT: Update with production values!)" -ForegroundColor Green

# 4. PM2-Konfiguration erstellen
Write-Host "🔧 Creating PM2 configuration..." -ForegroundColor Yellow
$pm2Config = @{
    name = "nga-backend"
    script = "server.js"
    instances = "max"
    exec_mode = "cluster"
    env = @{
        NODE_ENV = $Environment
        PORT = 3000
    }
    error_file = "./logs/err.log"
    out_file = "./logs/out.log"
    log_file = "./logs/combined.log"
    time = $true
    autorestart = $true
    max_memory_restart = "1G"
    watch = $false
} | ConvertTo-Json -Depth 3

$pm2Config | Out-File -FilePath (Join-Path $deployPath "ecosystem.config.json") -Encoding UTF8
Write-Host "   ✅ Created PM2 configuration" -ForegroundColor Green

# 5. Docker-Konfiguration erstellen
Write-Host "🐳 Creating Docker configuration..." -ForegroundColor Yellow
$dockerfileContent = @"
FROM node:18-alpine

# Arbeitsverzeichnis setzen
WORKDIR /app

# Package-Dateien kopieren
COPY package*.json ./

# Dependencies installieren
RUN npm ci --only=production

# App-Code kopieren
COPY . .

# Logs-Verzeichnis erstellen
RUN mkdir -p logs

# Port freigeben
EXPOSE 3000

# Health Check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# User für Sicherheit
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs

# App starten
CMD ["node", "server.js"]
"@

$dockerfileContent | Out-File -FilePath (Join-Path $deployPath "Dockerfile") -Encoding UTF8

$dockerComposeContent = @"
version: '3.8'

services:
  nga-backend:
    build: .
    ports:
      - "3000:3000"
    env_file:
      - .env
    volumes:
      - ./logs:/app/logs
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - nga-backend
    restart: unless-stopped
"@

$dockerComposeContent | Out-File -FilePath (Join-Path $deployPath "docker-compose.yml") -Encoding UTF8
Write-Host "   ✅ Created Docker configuration" -ForegroundColor Green

# 6. Nginx-Konfiguration erstellen
Write-Host "🌐 Creating Nginx configuration..." -ForegroundColor Yellow
$nginxConfig = @"
events {
    worker_connections 1024;
}

http {
    upstream nga_backend {
        server nga-backend:3000;
    }

    server {
        listen 80;
        server_name your-domain.com;
        
        # Redirect HTTP to HTTPS
        return 301 https://`$server_name`$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name your-domain.com;

        # SSL-Konfiguration
        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;

        # Rate Limiting
        limit_req_zone `$binary_remote_addr zone=api:10m rate=10r/s;

        location / {
            limit_req zone=api burst=20 nodelay;
            
            proxy_pass http://nga_backend;
            proxy_http_version 1.1;
            proxy_set_header Upgrade `$http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host `$host;
            proxy_set_header X-Real-IP `$remote_addr;
            proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto `$scheme;
            proxy_cache_bypass `$http_upgrade;
            
            # Timeouts
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }

        # Health Check
        location /health {
            proxy_pass http://nga_backend/health;
            access_log off;
        }
    }
}
"@

$nginxConfig | Out-File -FilePath (Join-Path $deployPath "nginx.conf") -Encoding UTF8
Write-Host "   ✅ Created Nginx configuration" -ForegroundColor Green

# 7. Deployment-Skripte erstellen
Write-Host "📜 Creating deployment scripts..." -ForegroundColor Yellow

# Systemd Service
$systemdService = @"
[Unit]
Description=NGA Backend API Server
Documentation=https://github.com/OliverHronek/NGA
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/nga-backend
ExecStart=/usr/bin/node server.js
Restart=on-failure
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=nga-backend
Environment=NODE_ENV=$Environment

[Install]
WantedBy=multi-user.target
"@

$systemdService | Out-File -FilePath (Join-Path $deployPath "nga-backend.service") -Encoding UTF8

# Install-Skript
$installScript = @"
#!/bin/bash
# Installation script for NGA Backend

echo "🚀 Installing NGA Backend..."

# 1. Update system
sudo apt update && sudo apt upgrade -y

# 2. Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 3. Install PM2
sudo npm install -g pm2

# 4. Create application directory
sudo mkdir -p /var/www/nga-backend
sudo chown -R `$USER:`$USER /var/www/nga-backend

# 5. Copy files
cp -r ./* /var/www/nga-backend/
cd /var/www/nga-backend

# 6. Install dependencies
npm ci --only=production

# 7. Create logs directory
mkdir -p logs

# 8. Start with PM2
pm2 start ecosystem.config.json
pm2 save
pm2 startup

echo "✅ Installation complete!"
echo "📝 Don't forget to:"
echo "   1. Update .env with production values"
echo "   2. Configure your domain in Nginx"
echo "   3. Install SSL certificates"
echo "   4. Test the API endpoints"
"@

$installScript | Out-File -FilePath (Join-Path $deployPath "install.sh") -Encoding UTF8
Write-Host "   ✅ Created installation scripts" -ForegroundColor Green

# 8. README erstellen
$readmeContent = @"
# NGA Backend Deployment

## 📦 Deployment-Paket

Dieses Verzeichnis enthält alle Dateien für das Backend-Deployment.

### 🗂️ Enthaltene Dateien

- **server.js** - Haupt-Server-Datei
- **package.json** - Dependencies
- **.env** - Umgebungsvariablen (⚠️ WICHTIG: Produktionswerte eintragen!)
- **ecosystem.config.json** - PM2-Konfiguration
- **Dockerfile & docker-compose.yml** - Docker-Setup
- **nginx.conf** - Nginx-Reverse-Proxy
- **install.sh** - Automatisches Installations-Skript
- **nga-backend.service** - Systemd-Service

## 🚀 Deployment-Optionen

### Option 1: PM2 (Empfohlen)
```bash
# 1. Dateien auf Server kopieren
scp -r deploy-backend/* user@server:/var/www/nga-backend/

# 2. Auf Server einloggen
ssh user@server

# 3. Installation ausführen
cd /var/www/nga-backend
chmod +x install.sh
./install.sh
```

### Option 2: Docker
```bash
# 1. Dateien auf Server kopieren
scp -r deploy-backend/* user@server:/opt/nga-backend/

# 2. Docker starten
cd /opt/nga-backend
docker-compose up -d
```

### Option 3: Systemd Service
```bash
# 1. Dateien kopieren
sudo cp -r deploy-backend/* /var/www/nga-backend/

# 2. Service installieren
sudo cp nga-backend.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable nga-backend
sudo systemctl start nga-backend
```

## ⚙️ Konfiguration

### 1. Umgebungsvariablen (.env)
```bash
# WICHTIG: Produktionswerte eintragen!
nano .env
```

### 2. Domain konfigurieren
```bash
# Nginx-Konfiguration anpassen
nano nginx.conf
# Domain "your-domain.com" ersetzen
```

### 3. SSL-Zertifikate
```bash
# Let's Encrypt installieren
sudo apt install certbot
sudo certbot certonly --standalone -d your-domain.com
```

## 🔍 Monitoring

### PM2 Status
```bash
pm2 status
pm2 logs nga-backend
pm2 monit
```

### Docker Status
```bash
docker-compose ps
docker-compose logs nga-backend
```

### Service Status
```bash
sudo systemctl status nga-backend
sudo journalctl -u nga-backend -f
```

## 🔧 Wartung

### Updates
```bash
# Code aktualisieren
git pull
pm2 restart nga-backend

# Dependencies aktualisieren
npm update
pm2 restart nga-backend
```

### Backup
```bash
# Datenbank-Backup
pg_dump -h nextgenerationaustria.at -U adminuser ngadatabase > backup.sql
```

## 🆘 Troubleshooting

### Häufige Probleme
1. **Port 3000 bereits belegt**: `sudo lsof -i :3000`
2. **Datenbank-Verbindung**: Firewall/Netzwerk prüfen
3. **Permission Errors**: `sudo chown -R www-data:www-data /var/www/nga-backend`

### Logs prüfen
```bash
# PM2 Logs
pm2 logs nga-backend

# System Logs
sudo journalctl -u nga-backend

# App Logs
tail -f logs/app.log
```
"@

$readmeContent | Out-File -FilePath (Join-Path $deployPath "README.md") -Encoding UTF8

# 9. Zusammenfassung
Write-Host ""
Write-Host "✅ Backend deployment package created successfully!" -ForegroundColor Green
Write-Host "📁 Location: $deployPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Created files:" -ForegroundColor Yellow
Get-ChildItem $deployPath | ForEach-Object { 
    Write-Host "   - $($_.Name)" -ForegroundColor White 
}
Write-Host ""
Write-Host "⚠️  IMPORTANT:" -ForegroundColor Red
Write-Host "   1. Update .env with production database credentials" -ForegroundColor White
Write-Host "   2. Replace 'your-domain.com' in nginx.conf" -ForegroundColor White
Write-Host "   3. Install SSL certificates" -ForegroundColor White
Write-Host "   4. Test all API endpoints after deployment" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Ready for deployment!" -ForegroundColor Green
