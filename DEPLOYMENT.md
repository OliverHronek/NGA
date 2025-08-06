# NGA Web App - Deployment Guide

## 🚀 Deployment Summary

Die NGA Web App wurde erfolgreich für die Produktion gebaut!

### 📁 Build-Verzeichnis
- **Quelle:** `build\web\`
- **Größe:** ~19 MB (komprimiert deutlich kleiner)
- **Datum:** 06.08.2025 09:22

### 📋 Enthaltene Features
- ✅ Google Analytics (G-PL7YXS3PRP)
- ✅ Responsive Design
- ✅ PWA-Support (Progressive Web App)
- ✅ Security Headers
- ✅ Optimierte Assets (Tree-shaking aktiviert)

## 🌐 Deployment-Schritte

### 1. Dateien hochladen
Lade alle Dateien aus dem `build\web\` Verzeichnis auf deinen Webserver hoch:

```
build\web\
├── index.html              (Haupt-HTML-Datei)
├── main.dart.js            (Haupt-App-Code, ~3MB)
├── flutter_bootstrap.js    (Flutter Bootstrap)
├── flutter_service_worker.js (Service Worker für PWA)
├── manifest.json           (PWA Manifest)
├── favicon.png             (Favicon)
├── assets\                 (App-Assets)
├── canvaskit\              (Flutter Web Engine)
└── icons\                  (App-Icons)
```

### 2. Webserver-Konfiguration

#### Apache (.htaccess)
```apache
# Alle Routen auf index.html weiterleiten (für SPA)
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /
    RewriteRule ^index\.html$ - [L]
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule . /index.html [L]
</IfModule>

# Gzip-Komprimierung aktivieren
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/css text/javascript application/javascript application/json
</IfModule>

# Cache-Headers setzen
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
    ExpiresByType image/png "access plus 1 month"
    ExpiresByType image/jpg "access plus 1 month"
    ExpiresByType image/jpeg "access plus 1 month"
    ExpiresByType image/gif "access plus 1 month"
    ExpiresByType image/svg+xml "access plus 1 month"
</IfModule>
```

#### Nginx
```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /path/to/build/web;
    index index.html;

    # Alle Routen auf index.html weiterleiten
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Gzip-Komprimierung
    gzip on;
    gzip_types text/css application/javascript application/json image/svg+xml;
    
    # Cache-Headers
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1M;
        add_header Cache-Control "public, immutable";
    }
}
```

### 3. Produktions-Einstellungen

#### Backend-URL aktualisieren
Stelle sicher, dass die App auf die richtige Backend-URL zeigt:
- **Entwicklung:** `http://localhost:3000`
- **Produktion:** `https://your-api-domain.com`

#### HTTPS aktivieren
- ✅ SSL-Zertifikat installieren
- ✅ HTTP zu HTTPS weiterleiten
- ✅ HSTS-Header setzen

### 4. Performance-Optimierungen

#### Service Worker
Die App enthält bereits einen Service Worker für:
- Offline-Funktionalität
- Caching von Assets
- PWA-Features

#### Asset-Optimierung
- Font-Assets wurden automatisch optimiert (99%+ Reduktion)
- Tree-shaking reduzierte Icon-Fonts erheblich
- Alle Assets sind für Produktion optimiert

## 🔧 Backend-Deployment

### Voraussetzungen
- Node.js Server (Port 3000)
- PostgreSQL Datenbank
- Umgebungsvariablen konfiguriert

### Backend-Dateien
```
backend\
├── server.js
├── package.json
├── .env (Produktions-Umgebung)
├── controllers\
├── routes\
├── middleware\
└── config\
```

## ✅ Deployment-Checkliste

- [ ] Flutter Web App gebaut (`build\web\`)
- [ ] Dateien auf Webserver hochgeladen
- [ ] Webserver-Konfiguration für SPA-Routing
- [ ] HTTPS aktiviert
- [ ] Backend-Server läuft
- [ ] Datenbank-Verbindung funktioniert
- [ ] Environment-Variablen für Produktion gesetzt
- [ ] Google Analytics funktioniert
- [ ] PWA-Features getestet

## 🚨 Wichtige Hinweise

1. **Backend-URL:** Aktualisiere die API-URL in der Produktion
2. **CORS:** Stelle sicher, dass der Backend-Server die richtige Domain erlaubt
3. **Datenbank:** Verwende Produktions-Datenbank-Credentials
4. **Monitoring:** Überwache Logs und Performance nach dem Deployment

## 📞 Support

Bei Problemen während des Deployments:
1. Überprüfe Browser-Konsole auf Fehler
2. Prüfe Webserver-Logs
3. Teste Backend-API-Endpoints direkt
4. Verifiziere Netzwerk-Requests in den Browser-Entwicklertools

---
**Deployment erfolgreich erstellt am:** 06.08.2025 09:22  
**Build-Größe:** 19 MB (unkomprimiert)  
**Flutter Version:** Aktuell  
**Features:** Google Analytics, PWA, Responsive Design
