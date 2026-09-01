# 🚀 PostgreSQL, pgAdmin & ngrok Live Hosting Guide
> **Shram Setu — Cooperative Gig Services Platform**

---

## 📌 Prerequisites Check
Make sure you have:
1. **Node.js** installed (`node -v`)
2. **PostgreSQL** & **pgAdmin 4** installed (Default port: `5432`)
3. **ngrok** installed (`ngrok version` or [download from ngrok.com](https://ngrok.com))

---

## 🛠️ Step 1: Configure PostgreSQL Credentials

Open [`backend/.env`](file:///f:/prototype/prototype/backend/.env) and set your PostgreSQL password:

```env
PGHOST=localhost
PGPORT=5432
PGUSER=postgres
PGPASSWORD=your_actual_postgres_password
PGDATABASE=sahakari_shramsetu
```

*(If you installed PostgreSQL with the default password `postgres` or `admin`, set `PGPASSWORD=postgres` or whatever password you chose during installation).*

---

## 🐘 Step 2: Database Initialization & Seeding (Auto-Setup)

You don't need to manually create tables in pgAdmin. Our migration script creates the database `sahakari_shramsetu`, all 12 tables, indexes, and full demo data automatically.

Run this command in the backend folder:

```bash
cd backend
npm run seed
```

### ✅ Expected Output:
```
🔨 Target database "sahakari_shramsetu" not found. Creating it now...
✅ Database "sahakari_shramsetu" created successfully.
✅ PostgreSQL migration complete — all 12 tables and indexes verified.
🧹 Clearing existing tables...
🌱 Populating demo data...
🌱 PostgreSQL Database Seed Complete!

   Records created:
   cooperatives: 3
   users: 25
   workers: 18
   skills: 25
   services: 15
   bookings: 25
   payments: 18
   reviews: 17
   certifications: 14
   worker_welfare: 12
```

---

## 🖥️ Step 3: View & Manage in pgAdmin 4

1. Open **pgAdmin 4**.
2. Expand **Servers** ➔ **PostgreSQL 15 / 16** (Enter your master password).
3. Under **Databases**, you will see **`sahakari_shramsetu`**.
4. Expand **`sahakari_shramsetu`** ➔ **Schemas** ➔ **public** ➔ **Tables**.
5. Right-click on any table (e.g., `bookings`, `workers`, `users`) and choose **View/Edit Data** ➔ **All Rows**.

---

## 💻 Step 4: Run Application Locally

### Terminal 1 (Backend Server):
```bash
cd backend
npm run dev
# Starts Express REST API on http://localhost:5000
```

### Terminal 2 (Frontend Server):
```bash
cd frontend
npm run dev
# Starts Vite React UI on http://localhost:5173
```

Open your browser at **`http://localhost:5173`**.

---

## 🌐 Step 5: Make it Live on the Internet via ngrok

With ngrok, you can share your working website with anyone on mobile, client devices, or external stakeholders.

### Method A: Single-Tunnel Fast Share (Recommended)
Since Vite proxies `/api` to the backend on port 5000, you only need to tunnel the frontend:

```bash
ngrok http 5173
```

ngrok will output a public HTTPS URL:
```
Forwarding                    https://a1b2-c3d4.ngrok-free.app -> http://localhost:5173
```
Anyone opening `https://a1b2-c3d4.ngrok-free.app` will be able to use the full website, make bookings, register workers, and view invoices!

---

### Method B: Separate Frontend & Backend Tunnels
If you prefer exposing both servers on separate tunnels:

**1. Tunnel Backend (Port 5000):**
```bash
ngrok http 5000
# Example: https://backend-api.ngrok-free.app
```

**2. Update `frontend/.env`:**
```env
VITE_API_URL=https://backend-api.ngrok-free.app/api
```

**3. Tunnel Frontend (Port 5173):**
```bash
ngrok http 5173
# Example: https://frontend-portal.ngrok-free.app
```

---

## 🔑 Pre-Configured Demo Credentials

The login page contains 1-click quick-login buttons, or use these credentials:

| Role | Email | Password | Access & Features |
|---|---|---|---|
| 👤 **Customer** | `customer@demo.local` | `demo123` | Bookings, Smart Matching Wizard, UPI Payments, Form IV Invoices, Reviews |
| 👷 **Worker** | `ramesh.w@demo.local` | `demo123` | Duty Toggle, Job Dispatch Inbox, Earnings, Social Security Welfare Centre |
| 🏢 **Coop Admin** | `admin@demo.local` | `demo123` | Worker Verification Audit, Multi-District Oversight, AI Demand Forecasting |

---

## 🔍 Diagnostic & Health Endpoints

- **API Health:** [`http://localhost:5000/api/health`](http://localhost:5000/api/health)
- **Database Stats & Row Counts:** [`http://localhost:5000/api/db/stats`](http://localhost:5000/api/db/stats)
