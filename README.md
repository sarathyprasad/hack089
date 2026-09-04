# Shram Setu — Cooperative Gig Services Platform
> *"Verified Skills. Fair Work. Stronger Communities."*

🏛️ **Shram Setu** is a digital public goods platform designed to connect verified, skilled workers belonging to regional **Labour Cooperative Federations / Societies** with households, institutions, and community organizations.

Unlike profit-extracting private aggregator platforms that treat workers as expendable gig laborers with high commissions and zero safety nets, **Shram Setu** implements an institutional cooperative model where:
1. Workers are **member-owners** in their registered district federations.
2. A transparent **93-2-5 model (93% direct worker take-home, 2% platform fee, 5% PF & insurance)** where contributions pool directly into **ESIC Accident Insurance, EPFO Pensions, Health Funds, and NSDC/ITI Trade Upskilling**.
3. Tariffs are standardized with **government-regulated base rates** and zero hidden surge pricing.
4. Citizen satisfaction is guaranteed through background checks and trade credential audits.

---

## 🌟 Key Highlights & Modules

### 1. 🏛️ Public Portal & Multi-Lingual Interface
- Official government design system (National Navy `#1a237e`, Saffron `#FF9933`, Green `#138808`).
- **Live Tri-Lingual Support**: English (EN), Hindi (हिंदी), and Odia (ଓଡ଼ିଆ).
- Standardized Public Services Catalog across 12 trade categories (Electrical, Plumbing, Carpentry, Painting, Cleaning, Gardening, Caregiving, Driving, Appliance Repair, Domestic, IT/CCTV, Emergency).
- Public Worker Directory with skill tags, badge credentials, and customer review summaries.

### 2. ⚡ Customer Booking & Smart Matching
- **Smart Matching Recommendation Engine**: Composite weighted scoring:
  $$\text{Score} = (\text{Skill Match} \times 0.50) + (\text{Proximity} \times 0.30) + (\text{Availability} \times 0.20)$$
- **24/7 Priority Emergency Toggle** with express routing.
- Real-time 5-step visual service lifecycle timeline (`Requested` ➔ `Matched` ➔ `Accepted` ➔ `In Progress` ➔ `Completed`).

### 3. 👷 Worker Portal & Social Security Centre
- Real-time duty availability toggle (`Available Now`, `On Job / Busy`, `Offline`).
- Job dispatch manager with instant **Accept / Decline** and **Start / Complete** workflows.
- Transparent Earnings Ledger and direct customer feedback.
- **Worker Welfare Centre**: Enrolled & available state welfare schemes (ESIC, EPFO, NSDC).

### 4. 🏢 Cooperative Federation Admin & AI Demand Forecasting
- **7-KPI Executive Summary Banner** (Workers, Verified, Pending, Active, Completed, Emergency, Payouts).
- Worker Audit Table with instant **Verify** and **Reject** state machine.
- Federated Bookings Oversight across Khordha, Cuttack, and Puri districts.
- **Smart AI Community Demand Forecasting & Mutual Aid Allocation**.

### 5. 💳 Payment & Official Tax Invoicing
- Simulated multi-channel payment gateway (UPI QR / VPA, RuPay / Debit Card, Net Banking).
- Official printable **Odisha Labour Cooperative Society Form IV Tax Invoice** with transparent fee breakdown and digital QR verification seal.

---

## 🛠️ Technology Stack

- **Backend**: Node.js & Express.js, PostgreSQL (`pg` connection pool with WAL/connection retry), JWT Authentication, bcryptjs, Helmet, CORS, Morgan.
- **Frontend**: Vite + React 18, Tailwind CSS v3, Lucide React Icons, React Router v6.
- **Data Layer**: 12 relational database tables with foreign key constraints, automated seed data for 3 cooperatives, 18 workers, 25 services, and 25 bookings.
- **Remote / Live Hosting**: Native support for **ngrok** tunneling and live cloud deployment.

---

## 🚀 Quick Start & Installation

For a step-by-step guide on pgAdmin, PostgreSQL, and ngrok, refer to **[`POSTGRES_AND_NGROK_GUIDE.md`](./POSTGRES_AND_NGROK_GUIDE.md)**.

### 1. Database Configuration
Configure [`backend/.env`](./backend/.env) with your PostgreSQL credentials:
```env
PGHOST=localhost
PGPORT=5432
PGUSER=postgres
PGPASSWORD=your_password
PGDATABASE=sahakari_shramsetu
```

### 2. Auto-Migration & Seeding
```bash
cd backend
npm run seed
```

### 3. Start Servers
```bash
# Terminal 1: Backend (Port 5000)
cd backend
npm run dev

# Terminal 2: Frontend (Port 5173)
cd frontend
npm run dev
```

### 4. Live Share via ngrok
```bash
ngrok http 5173
```

---

## 🔑 Demo Login Credentials

For testing and evaluation, 1-click login buttons are embedded directly on the Login page:

| Role | Demo Email | Password | Pre-configured Access |
|------|------------|----------|-----------------------|
| 👤 **Customer** | `customer@demo.local` | `demo123` | Bookings, Smart Matching, Payments, Invoices, Reviews |
| 👷 **Worker** | `ramesh.w@demo.local` | `demo123` | Duty Toggle, Job Dispatch, Earnings, Welfare Centre |
| 🏢 **Coop Admin** | `admin@demo.local` | `demo123` | Worker Verification, Oversight, AI Demand & Mutual Aid |

---

## 📄 License
Government Open Public Services License (GPL / Open Source Public Good).
Designed and developed for Labour Cooperative Federations.
