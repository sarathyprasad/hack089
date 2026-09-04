# 🧪 Shram Setu — Comprehensive Feature Test Cases & Verification Guide

This document provides end-to-end test cases and verification instructions for **Sahakari Shram Setu** (Cooperative Gig Services Platform). It includes credentials, automated test commands, and step-by-step test cases for each platform feature.

---

## 🚀 1. Quick Test Setup & Environments

### Target URLs
| Environment | Frontend URL | Backend API URL |
| :--- | :--- | :--- |
| **Local Development** | `http://localhost:5173/` | `http://localhost:5000/api` |
| **Live ngrok Tunnel** | `https://strudel-spinster-curator.ngrok-free.dev` | Same (proxied via `/api`) |
| **Render Cloud Deployment** | `https://shram-setu-app.onrender.com/` | `https://shram-setu-app.onrender.com/api` |

### Pre-configured Demo Accounts
| Role | Email | Password | Pre-configured Profile |
| :--- | :--- | :--- | :--- |
| **👤 Citizen / Customer** | `customer@demo.local` | `demo123` | Ananya Patel (Patia, Bhubaneswar) |
| **👷 Worker (Artisan)** | `ramesh.w@demo.local` | `demo123` | Ramesh Kumar (Master Electrician • ITI Certified) |
| **🏢 Cooperative Admin** | `admin@demo.local` | `demo123` | Arun Kumar Pattnaik (Federation Secretary) |

---

## ⚡ 2. Automated Feature Test Runner

You can verify all 16 core backend endpoints, database connectivity, and business logic in **under 3 seconds** using the automated test suite.

### Run Automated Tests
```bash
# Run against local server (http://localhost:5000/api)
node test_features.js

# Or test directly against your live Render deployment:
TEST_API_URL="https://your-app.onrender.com/api" node test_features.js
```

### Verified Automated Test Output:
```
======================================================
   SHRAM SETU — AUTOMATED FEATURE VERIFICATION SUITE   
======================================================
1. Core API & Database Connectivity
  ✔ [TC-01] API Health Check (PostgreSQL connected)
  ✔ [TC-02] Database Stats & Tables Count (Users: 66, Workers: 38, Services: 47)
2. Dual-Perspective Reviews & Testimonials
  ✔ [TC-03] Featured Reviews Endpoint (GET /reviews/featured) (8 Customer Reviews, 6 Worker Stories, Avg: 4.9★)
3. Standardized Trade Services Catalog
  ✔ [TC-04] Services Catalog Listing (GET /services) (47 Granular Services Available)
4. Verified Cooperative Workers Directory
  ✔ [TC-05] Workers Directory (GET /workers) (20 Verified Artisans Loaded)
5. Multi-Role Authentication Flow
  ✔ [TC-06] Customer Demo Login (customer@demo.local) (Name: Ananya Patel, Role: CUSTOMER)
  ✔ [TC-07] Worker Demo Login (ramesh.w@demo.local) (Name: Ramesh Kumar, Trade: Electrician)
  ✔ [TC-08] Admin Demo Login (admin@demo.local) (Role: COOPERATIVE_ADMIN)
6. Session Validation & Profile Inspection
  ✔ [TC-09] Customer Profile Check (GET /auth/me) (Verified District: Khordha)
7. Bookings & Real-Time GPS Tracking Data
  ✔ [TC-10] Citizen Bookings Retrieval (GET /bookings) (Bookings Retrieved)
  ✔ [TC-11] Sample Booking GPS Coordinates Check (Lat: 20.354, Lng: 85.817)
8. Regulated Fixed Rate Card & Parts Catalog
  ✔ [TC-12] Locked Parts Catalog (GET /governance/parts-catalog) (25 Standardized Replacement Parts)
9. Cooperative Society Lifecycle Tracking
  ✔ [TC-13] Registered Societies Listing (GET /societies) (3 Labour Cooperative Societies)
10. Federation Institutional Tenders & Bids
  ✔ [TC-14] Institutional Tenders Retrieval (GET /federation/tenders) (Smart City & Railway Tenders Available)
11. Worker Welfare & Social Security Center
  ✔ [TC-15] Worker Welfare Status (GET /worker-portal/welfare) (Enrolled Policies, Coop: Federation)
12. Smart AI Features & Allocation
  ✔ [TC-16] Smart Demand Forecast (GET /smart-features/forecast) (Seasonal Forecasts & Directives Active)
======================================================
🎉 ALL 16 CORE FEATURE TEST CASES PASSED SUCCESSFULLY!
```

---

## 📋 3. Step-by-Step Manual Test Cases Matrix

### Suite 1: Home Page & Public Discovery
| Test ID | Feature | Test Steps | Expected Result |
| :--- | :--- | :--- | :--- |
| **TC-PUB-01** | Unified Search & Voice Recognition | 1. Go to Home (`/`).<br>2. Select district **Khordha**.<br>3. Type `AC repair` or tap 🎙️ Mic.<br>4. Click **Find Service**. | Redirects to `/book-service` filtered by query and district. |
| **TC-PUB-02** | 12 Standardized Trade Services | 1. Scroll to **Standardized Trade Services**.<br>2. Click tabs: `🔥 Popular`, `⚡ Electrical`, `🚰 Plumbing`, `🚨 Emergency`. | Service cards filter dynamically with regulated base tariffs (`₹249`, `₹349`, etc.). |
| **TC-PUB-03** | **Dual-Perspective Community Reviews** | 1. Scroll to **Community Reviews** section.<br>2. Click **All Reviews** (shows combined 14 reviews).<br>3. Click **Customer Reviews** (shows verified resident bookings, star subscores, worker replies).<br>4. Click **Worker Reviews** (shows artisan earnings testimonials, 93-2-5 payout stories, ESIC benefits).<br>5. Click 🔊 **Volume** icon on any card. | Reviews filter smoothly; text-to-speech reads the review aloud. |
| **TC-PUB-04** | Fixed Rate Card & AC Overhaul Process | 1. Scroll below service cards.<br>2. Click **View Itemized Rate Card**.<br>3. Click **Explore 5-Step AC Process**. | Opens `/rate-card` and `/services/1` showing Foam-Jet SOP steps. |
| **TC-PUB-05** | Toll-Free Helpline & Kiosk Directory | 1. Scroll to **Assisted Phone Booking** banner.<br>2. Click `Call 1800-345-7788`.<br>3. Click **Kiosk Directory**. | Triggers dialer / opens `/help` directory with Gram Panchayat CSC kiosk contacts. |

---

### Suite 2: Citizen Booking Flow & Smart Matching
| Test ID | Feature | Test Steps | Expected Result |
| :--- | :--- | :--- | :--- |
| **TC-BKG-01** | Smart Matching Wizard | 1. Login as Customer (`customer@demo.local` / `demo123`).<br>2. Go to `/book-service`.<br>3. Step 1: Pick category `Electrical` ➔ `Ceiling Fan Repair`.<br>4. Step 2: Confirm address (Patia, Bhubaneswar).<br>5. Step 3: Select Date & Time Slot. | Step 4 displays ranked verified cooperative artisans scored by proximity, rating, and badge. |
| **TC-BKG-02** | 93-2-5 Escrow Tariff Transparency | 1. Review tariff breakdown in Step 4 before booking. | Itemized view displays: 93% Living Wage to Worker, 2% Platform Maintenance, 5% PF & Social Security fund. |
| **TC-BKG-03** | Booking Placement & Code Generation | 1. Click **Confirm Booking**. | Creates booking with unique tracking code (e.g. `BKG-2026-0005`), sets status `REQUESTED`, generates Arrival & Completion OTPs. |
| **TC-BKG-04** | 24/7 Emergency Dispatch | 1. Toggle **24/7 Emergency Dispatch** on booking form. | Activates rapid response banner with 60-minute dispatch SLA. |

---

### Suite 3: Real-Time GPS Tracking & Google Maps Engine
| Test ID | Feature | Test Steps | Expected Result |
| :--- | :--- | :--- | :--- |
| **TC-MAP-01** | **Google Maps Route View** | 1. Go to `/my-bookings` or `/bookings/1`.<br>2. Inspect **Live Cooperative Dispatch & Route Map**. | **Google Maps Engine** embeds cleanly with **zero iframe blocking errors** on both local and Render domains. |
| **TC-MAP-02** | Map Navigation Modes | 1. Click **🚗 Route**: Shows artisan-to-customer driving route.<br>2. Click **📍 Destination**: Centers on customer premises.<br>3. Click **📡 Nearby**: Pins surrounding cooperative artisans. | Google Maps re-centers and updates according to selected view mode. |
| **TC-MAP-03** | Zoom & Recenter Controls | 1. Click 🔍 `+` (Zoom In) and `−` (Zoom Out).<br>2. Click 🔄 Recenter. | Map dynamically adjusts zoom level via Google Maps parameters. |
| **TC-MAP-04** | Real-Time Telemetry Dashboard | 1. Check floating telemetry bar at the bottom of the map. | Displays: `Google GPS: Live`, `Transit Distance: 3.9 km`, `Speed: 28 km/h`, `ETA: ~13 Mins`. |
| **TC-MAP-05** | Native Google Maps App Deep Link | 1. Click the amber **Google Maps App** button in map header. | Opens native Google Maps in a new tab (`https://www.google.com/maps/dir/...`) with pre-filled GPS coordinates for driving directions. |

---

### Suite 4: On-Site Execution, Parts & Invoicing
| Test ID | Feature | Test Steps | Expected Result |
| :--- | :--- | :--- | :--- |
| **TC-EXE-01** | Arrival OTP Handshake | 1. Open active booking detail page.<br>2. Worker enters Customer's 4-digit **Arrival OTP**.<br>3. Click **Verify Arrival**. | Status updates from `ACCEPTED` ➔ `IN_PROGRESS`. Worker arrival timestamp recorded. |
| **TC-EXE-02** | Locked Spare Parts Addition | 1. On active job, click **Add Replacement Parts**.<br>2. Select part from catalog (e.g., *Orient 2.5uF Fan Capacitor - ₹110*).<br>3. Click **Add to Work Order**. | Adds item with regulated price and 6-month statutory warranty; updates invoice total. |
| **TC-EXE-03** | Completion OTP Handshake | 1. Worker clicks **Request Completion**.<br>2. Enter customer's 4-digit **Completion OTP**.<br>3. Upload before/after photo proof. | Status updates to `COMPLETED`. 30-Day Guarantee activates. |
| **TC-EXE-04** | 93-2-5 Payment Simulation | 1. Customer clicks **Pay Now**.<br>2. Select UPI (GPay/PhonePe) or Net Banking.<br>3. Click **Confirm Payment**. | Payment status updates to `SUCCESS`. Payout distributed to Worker Wallet (93%) and Cooperative Fund (5%). |
| **TC-EXE-05** | Form IV Government Tax Invoice | 1. On completed booking, click **View Tax Invoice**.<br>2. Check GSTIN, Cooperative Federation Registration No, HSN code, and 93-2-5 breakdown.<br>3. Click **Print / Save PDF**. | Renders formatted Form IV statutory tax invoice printable in 1 click. |

---

### Suite 5: Quality Assurance & 30-Day Guarantee
| Test ID | Feature | Test Steps | Expected Result |
| :--- | :--- | :--- | :--- |
| **TC-QA-01** | Citizen Review & Quality Subscores | 1. On completed booking, click **Rate Service**.<br>2. Select 5 stars.<br>3. Choose quick tags (`Punctual & Prompt`, `Master Workmanship`).<br>4. Enter comment and submit. | Review saved in PostgreSQL; updates worker's average rating on directory and Home reviews. |
| **TC-QA-02** | 30-Day Free Warranty Claim | 1. Open a booking completed within 30 days.<br>2. Check **30-Day Guarantee Armed** badge.<br>3. Click **Claim Re-Repair**. | Dispatches senior master artisan at ₹0 labor charge under guarantee SLA. |
| **TC-QA-03** | Appliance Lineage History | 1. Click **Appliance Lineage** modal.<br>2. Search past appliance serial or customer ID. | Shows permanent audit trail: date of installation, gas refills, parts replaced, and warranty status. |
| **TC-QA-04** | Nodal Dispute Helpdesk | 1. Click **Raise Dispute Ticket**.<br>2. Select reason: *Tariff Discrepancy* or *Quality Concern*.<br>3. Submit ticket. | Ticket assigned to Regional Cooperative Dispute Officer for mandatory 48-hour resolution. |

---

### Suite 6: Worker Portal & Social Security
| Test ID | Feature | Test Steps | Expected Result |
| :--- | :--- | :--- | :--- |
| **TC-WRK-01** | Duty Availability Switch | 1. Login as Worker (`ramesh.w@demo.local` / `demo123`).<br>2. Go to `/worker-dashboard`.<br>3. Toggle status: `AVAILABLE` / `BUSY` / `OFFLINE`. | Instant status toggle; updates matching engine visibility in real-time. |
| **TC-WRK-02** | Dispatch Queue & Job Acceptance | 1. View **Incoming Work Requests**.<br>2. Inspect customer address, distance, and 93% payout.<br>3. Click **Accept Job** or **Decline**. | Accepted job moves to Active Work Orders; customer receives live dispatch alert. |
| **TC-WRK-03** | Transparent Earnings Wallet | 1. Navigate to **Earnings Ledger** on worker dashboard. | Shows net earnings without arbitrary platform commissions; shows direct UPI payout batch status. |
| **TC-WRK-04** | Worker Welfare Center | 1. Go to `/worker-welfare`.<br>2. Inspect active policies: ESIC Health, ₹5 Lakh Accident Cover, Mini-PF.<br>3. Click **Enroll in NSDC Upskilling Workshop**. | Instant enrollment in certified cooperative trade training. |

---

### Suite 7: Federation Dual-Console & Society Governance
| Test ID | Feature | Test Steps | Expected Result |
| :--- | :--- | :--- | :--- |
| **TC-FED-01** | Cooperative Society Registration | 1. Go to `/society-registration`.<br>2. Fill Society Name, District, 10 founding artisan members, and Bylaws.<br>3. Submit registration. | Generates official statutory tracking code (e.g. `SOC-OD-2026-9041`). |
| **TC-FED-02** | Society Lifecycle Timeline Tracking | 1. Go to `/society-timeline`.<br>2. Enter tracking code. | Displays 5-stage progress: Application ➔ Scrutiny ➔ Verification ➔ Registration Certificate. |
| **TC-FED-03** | NCCT Training Application | 1. Go to `/federation-portal`.<br>2. Fill NCCT Management & Governance Training application.<br>3. Submit form. | Records application and updates federation training roster. |
| **TC-FED-04** | Institutional Municipal Tenders | 1. In Federation Portal, click **Institutional Tenders** (`/institutional-tenders`).<br>2. Inspect BMC Smart City & Railway tenders.<br>3. Review allocated cooperative workforce pool. | Displays tender values, funding milestones, and allocated worker teams. |

---

### Suite 8: Cooperative Admin Console & Smart Allocation
| Test ID | Feature | Test Steps | Expected Result |
| :--- | :--- | :--- | :--- |
| **TC-ADM-01** | Worker Verification Audit | 1. Login as Admin (`admin@demo.local` / `demo123`).<br>2. Go to `/admin`.<br>3. Review pending artisan registrations.<br>4. Click **Verify ITI Certificate** ➔ **Approve**. | Worker status changes to `VERIFIED` and appears in public search directory. |
| **TC-ADM-02** | AI Demand Forecasting & Directives | 1. In Admin Console, review **AI Demand Forecast**.<br>2. Inspect 4-week projections for AC, Electrical, and Plumbing.<br>3. Review monsoon weather directives. | Renders predictive demand matrix with recommended workforce mobilization numbers. |
| **TC-ADM-03** | Inter-District Mutual Aid Transfer | 1. In Admin Console, view **Workforce Allocation**.<br>2. Click **Authorize Mutual Aid Transfer** (e.g. Cuttack to Bhubaneswar). | Approves temporary workforce deployment agreement between federations. |
| **TC-ADM-04** | SOS Emergency Panic Monitor | 1. Open Admin Governance Monitor.<br>2. Check live SOS alerts and panic coordinates. | Displays emergency alerts with geo-coordinates and rapid escalation buttons. |

---

### Suite 9: Multilingual AI Chatbot & Accessibility
| Test ID | Feature | Test Steps | Expected Result |
| :--- | :--- | :--- | :--- |
| **TC-ACC-01** | Floating AI Assistant Chatbot | 1. Click floating 🤖 **AI Assistant** widget on bottom right.<br>2. Ask: *"What is the fixed price of AC servicing?"*<br>3. Select Language: `Odia (ଓଡ଼ିଆ)`, `Hindi (हिंदी)`, or `English`. | Returns instantaneous accurate response quoting official cooperative rate card tariffs. |
| **TC-ACC-02** | High-Contrast Mode & Voice Accessibility | 1. Click **Contrast** button in top header bar.<br>2. Click **Listen to Page** / 🔊 Volume icons on review cards. | Toggles high-contrast theme; activates speech synthesis narrating page content. |

---

## 🎯 4. Test Completion Sign-Off Checklist

- [ ] All 16 Automated API tests pass with `node test_features.js`
- [ ] Google Maps loads without "This content is blocked" error on Render
- [ ] Customer Reviews & Worker Reviews tabs switch and display smoothly
- [ ] Speech synthesis reads reviews aloud upon clicking volume buttons
- [ ] End-to-end booking completes with OTP handshake and Form IV invoice
- [ ] Worker availability switch and welfare status work as expected
- [ ] All 3 demo accounts (`customer@demo.local`, `ramesh.w@demo.local`, `admin@demo.local`) log in successfully
