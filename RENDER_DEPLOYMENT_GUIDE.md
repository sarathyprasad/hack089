# 🚀 Render & Managed PostgreSQL Deployment Guide

This guide explains how to deploy **Shram Setu** to [Render.com](https://render.com) with a **Managed PostgreSQL Database** and live auto-deployments.

---

## 🌟 Option A: 1-Click Blueprint Deployment (Recommended)

Render uses the included `render.yaml` file to automatically provision both the **Managed PostgreSQL database** and the **Web Service** in a single click.

### Step 1: Push Project to GitHub
Initialize and push this project directory to your GitHub repository:
```bash
git init
git add .
git commit -m "Deploy Shram Setu to Render"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
git push -u origin main
```

### Step 2: Deploy on Render
1. Log in to [Render Dashboard](https://dashboard.render.com/).
2. Click the **"New +"** button in the top navigation and select **"Blueprint"**.
3. Connect your GitHub repository.
4. Render will detect `render.yaml` and show:
   * **Database**: `shram-setu-db` (PostgreSQL)
   * **Web Service**: `shram-setu-app` (Node.js)
5. Click **"Apply"**.
6. Render will automatically:
   * Provision the PostgreSQL database.
   * Build the frontend React app into `dist`.
   * Install backend dependencies.
   * Run database migrations and seed demo data (`npm run seed`).
   * Start the live web application on `https://shram-setu-app.onrender.com`.

---

## 🛠️ Option B: Manual Setup on Render Dashboard

If you prefer to configure each component manually:

### Step 1: Create Managed PostgreSQL Database
1. In Render Dashboard, click **"New +"** ➔ **"PostgreSQL"**.
2. Fill in details:
   * **Name**: `shram-setu-db`
   * **Database**: `shram_setu`
   * **User**: `shram_user`
   * **Region**: *Singapore* (or nearest to you)
   * **Plan**: *Free*
3. Click **"Create Database"**.
4. Once created, copy the **Internal Database URL** (e.g. `postgres://shram_user:password@dpg-xxxx-a:5432/shram_setu`).

---

### Step 2: Create Web Service
1. In Render Dashboard, click **"New +"** ➔ **"Web Service"**.
2. Connect your GitHub repository.
3. Configure the service:
   * **Name**: `shram-setu-app`
   * **Region**: Same region as your database (*Singapore*)
   * **Branch**: `main`
   * **Runtime**: `Node`
   * **Build Command**: `npm run build`
   * **Start Command**: `npm run seed && npm start`
4. Add **Environment Variables**:

| Variable Key | Value | Notes |
| :--- | :--- | :--- |
| `NODE_ENV` | `production` | Enables production optimizations |
| `DATABASE_URL` | *Paste your Render Internal Database URL* | Connects backend to managed PostgreSQL |
| `JWT_SECRET` | *Click "Generate"* or type a secret key | Signs authentication tokens |
| `CORS_ALLOW_ALL` | `true` | Allows web requests |
| `PORT` | `10000` | Port used by Render |

5. Click **"Create Web Service"**.

---

## 🔍 Verification & Health Check

Once deployment completes, open your Render app URL (e.g. `https://shram-setu-app.onrender.com`):

1. **Frontend App**: Visit `https://shram-setu-app.onrender.com`
2. **API Health Check**: Visit `https://shram-setu-app.onrender.com/api/health`
   ```json
   {
     "status": "ok",
     "message": "Shram Setu API is running on PostgreSQL",
     "database": "PostgreSQL",
     "environment": "production"
   }
   ```
3. **Database Stats**: Visit `https://shram-setu-app.onrender.com/api/db/stats` to verify seeded tables and worker profiles.

---

## 🔑 Demo Credentials on Live App

* **Citizen Portal**: `ananya@example.com` / `password123`
* **Artisan Portal**: `ramesh@example.com` / `password123` (Master Electrician)
* **Federation Admin Desk**: `admin@sevasetu.gov.in` / `admin123`
