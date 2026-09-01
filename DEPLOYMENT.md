# Production Deployment Guide — Shram Setu

This document outlines the deployment instructions for hosting **Shram Setu** on state government infrastructure (NIC / State Data Centre / Cloud VM).

---

## 1. Environment Configuration

### Backend `.env` Variables
```ini
NODE_ENV=production
PORT=5000
DATABASE_PATH=./database.sqlite
JWT_SECRET=your_super_secure_production_secret_key_change_in_prod
CORS_ORIGIN=https://shramsetu.odisha.gov.in
ADMIN_SECRET_KEY=state_coop_admin_secure_key
```

### Frontend `.env.production`
```ini
VITE_API_URL=/api
```

---

## 2. Production Build Steps

### A. Build Frontend
```bash
cd frontend
npm install --production=false
npm run build
# Output files generated in frontend/dist
```

### B. Setup Backend with PM2 Process Manager
```bash
cd backend
npm install --production
npm install -g pm2

# Run migration and verify database
npm run migrate

# Start backend cluster with PM2
pm2 start src/index.js --name "shramsetu-api" -i 2 --max-memory-restart 500M
pm2 save
pm2 startup
```

---

## 3. Nginx Reverse Proxy & Static Asset Serving

```nginx
server {
    listen 80;
    server_name shramsetu.odisha.gov.in;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name shramsetu.odisha.gov.in;

    ssl_certificate /etc/ssl/certs/shramsetu.crt;
    ssl_certificate_key /etc/ssl/private/shramsetu.key;
    ssl_protocols TLSv1.2 TLSv1.3;

    # Frontend Single Page App
    root /var/www/sahakari-shramsetu/frontend/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Backend API Proxy
    location /api/ {
        proxy_pass http://127.0.0.1:5000/api/;
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

---

## 4. Database Maintenance & WAL Mode Backup

SQLite runs in **Write-Ahead Logging (WAL)** mode for concurrent high-throughput reads and writes.

### Automated Nightly Backup Cron:
```bash
# Run online safe backup without locking reads
sqlite3 /var/www/sahakari-shramsetu/backend/database.sqlite ".backup '/var/backups/sqlite/shramsetu_$(date +\%Y\%m\%d).sqlite'"
```
