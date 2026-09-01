# Shram Setu — REST API Documentation

Base URL: `http://localhost:5000/api`

All authenticated endpoints require the `Authorization` header:
`Authorization: Bearer <JWT_TOKEN>`

---

## 1. Authentication & Users (`/api/auth`)

### `POST /api/auth/register`
Register a new customer or worker member.
- **Request Body**:
  ```json
  {
    "name": "Arun Sethi",
    "email": "arun@example.com",
    "phone": "+91 98765 43210",
    "password": "password123",
    "role": "CUSTOMER",
    "district": "Khordha",
    "city": "Bhubaneswar",
    "address": "Saheed Nagar, Plot 42",
    "pincode": "751007",
    "cooperativeId": 1,
    "skills": ["Electrical Repair", "Wiring"],
    "experienceYears": 5
  }
  ```
- **Response `201 Created`**:
  ```json
  {
    "message": "User registered successfully",
    "token": "eyJhbGciOi...",
    "user": { "id": 26, "name": "Arun Sethi", "role": "CUSTOMER", "email": "arun@example.com" }
  }
  ```

### `POST /api/auth/login`
Authenticate existing user and retrieve session token.
- **Request Body**:
  ```json
  { "email": "customer@demo.local", "password": "demo123" }
  ```
- **Response `200 OK`**:
  ```json
  {
    "token": "eyJhbGciOi...",
    "user": { "id": 4, "name": "Priya Mohanty", "role": "CUSTOMER", "email": "customer@demo.local" }
  }
  ```

### `GET /api/auth/me`
Retrieve current authenticated user profile.
- **Headers**: `Authorization: Bearer <token>`
- **Response `200 OK`**: User profile object with worker and cooperative details if applicable.

---

## 2. Public Services & Workers Catalog (`/api/services`, `/api/workers`)

### `GET /api/services`
List all government-standardized services.
- **Query Params**: `category`, `search`
- **Response `200 OK`**: Array of services with base rates, duration, and worker counts.

### `GET /api/workers`
Search verified cooperative worker directory.
- **Query Params**: `trade`, `district`, `verified` (`true`/`false`), `search`
- **Response `200 OK`**: Array of workers with skills, certifications, rating, and federation.

### `GET /api/workers/:id`
Retrieve full worker profile with verified certifications, trade skills, and customer reviews.

---

## 3. Smart Matching & Bookings (`/api/matching`, `/api/bookings`)

### `POST /api/matching/recommend`
Calculate composite recommendation scores for workers.
- **Request Body**:
  ```json
  {
    "serviceId": 1,
    "district": "Khordha",
    "city": "Bhubaneswar",
    "isEmergency": true
  }
  ```
- **Algorithm**: `Score = (Skill * 0.50) + (Proximity * 0.30) + (Availability * 0.20)`
- **Response `200 OK`**: Ranked list of verified workers with score breakdown and distance estimates.

### `POST /api/bookings`
Create a new service order.
- **Request Body**:
  ```json
  {
    "serviceId": 1,
    "workerId": 1,
    "scheduledDate": "2026-08-28",
    "scheduledTime": "10:00 AM",
    "locationAddress": "Flat 302, Royal Residency",
    "locationCity": "Bhubaneswar",
    "locationDistrict": "Khordha",
    "locationPincode": "751024",
    "notes": "Main switchboard tripping repeatedly",
    "isEmergency": false
  }
  ```
- **Response `201 Created`**: Booking confirmation with auto-generated tax invoice and booking code (`BK-OD-2026-XXXX`).

### `GET /api/bookings`
List bookings for the authenticated user or all bookings for Admin.

### `GET /api/bookings/:id`
Retrieve booking details with assigned worker, payment record, and invoice.

### `PUT /api/bookings/:id/status`
Update booking progress state (`REQUESTED`, `MATCHED`, `ACCEPTED`, `IN_PROGRESS`, `COMPLETED`).

### `POST /api/bookings/:id/cancel`
Cancel an active booking with recorded cancellation reason.

---

## 4. Worker Portal (`/api/worker-portal`)

### `GET /api/worker-portal/dashboard`
Retrieve worker metrics (total earnings, completed tasks, customer rating, incoming jobs queue, active jobs).

### `PUT /api/worker-portal/availability`
Update duty status (`AVAILABLE`, `BUSY`, `OFFLINE`).

### `PUT /api/worker-portal/jobs/:id/action`
Execute job dispatch action (`ACCEPT`, `DECLINE`, `START`, `COMPLETE`).

### `GET /api/worker-portal/welfare`
Retrieve enrolled and available social security schemes (ESIC, EPFO, Health, ITI training).

### `POST /api/worker-portal/welfare/enroll`
Simulate 1-click enrollment into a government welfare program.

---

## 5. Cooperative Admin & Smart Features (`/api/admin`, `/api/smart-features`)

### `GET /api/admin/dashboard`
Retrieve 7-KPI summary and cooperative analytics.

### `GET /api/admin/workers`
List workers with audit details and filter by status (`PENDING`, `VERIFIED`, `REJECTED`).

### `PUT /api/admin/workers/:id/verify`
Update worker verification status (`VERIFIED`, `REJECTED`, `PENDING`).

### `GET /api/smart-features/forecast`
Retrieve predictive seasonal demand models and 4-week forward projections.

### `GET /api/smart-features/allocation`
Retrieve regional supply vs demand gap matrix and mutual aid proposals.

### `POST /api/smart-features/mutual-aid/:id/approve`
Authorize an inter-cooperative mutual aid workforce transfer.

---

## 6. Payments & Reviews (`/api/payments`, `/api/reviews`)

### `POST /api/payments/process`
Process simulated payment via UPI, Card, or Net Banking. Generates `TXN-DEMO-2026-XXXXXX` transaction ID and updates invoice status to `PAID`.

### `GET /api/payments/invoice/:bookingId`
Retrieve official government tax invoice for a booking.

### `POST /api/reviews`
Submit star rating (1-5), feedback tags, and citizen comments for completed service. Automatically recalculates worker's average rating.

---

## 7. Multilingual & Localization API (`/api/localization`)

### `GET /api/localization/languages`
Retrieve all supported Indian regional languages and metadata:
- **Response `200 OK`**:
  ```json
  {
    "languages": [
      { "code": "EN", "name": "English", "nativeName": "English", "direction": "ltr" },
      { "code": "HI", "name": "Hindi", "nativeName": "हिंदी", "direction": "ltr" },
      { "code": "OR", "name": "Odia", "nativeName": "ଓଡ଼ିଆ", "direction": "ltr" },
      { "code": "BN", "name": "Bengali", "nativeName": "বাংলা", "direction": "ltr" },
      { "code": "TE", "name": "Telugu", "nativeName": "తెలుగు", "direction": "ltr" }
    ]
  }
  ```

### `GET /api/localization/:lang`
Retrieve the complete dictionary and localized terms for a language code (`EN`, `HI`, `OR`, `BN`, `TE`):
- **Example**: `GET /api/localization/OR`
- **Response `200 OK`**:
  ```json
  {
    "language": "OR",
    "name": "Odia",
    "nativeName": "ଓଡ଼ିଆ",
    "dictionary": {
      "portalTitle": "ସରକାରୀ ଶ୍ରମ ସମବାୟ ସେବା ପୋର୍ଟାଲ",
      "tagline": "ଯାଞ୍ଚ ହୋଇଥିବା ଦକ୍ଷତା। ନ୍ୟାଯ୍ୟ କାର୍ଯ୍ୟ। ସଶକ୍ତ ସମୁଦାୟ।",
      "categories": {
        "Electrical": "ବିଦ୍ୟୁତ୍ ମରାମତି ଓ ୱେୟାରିଂ",
        "Plumbing": "ପ୍ଲମ୍ବିଂ / ନଳକୂପ କାର୍ଯ୍ୟ"
      },
      "welfare": {
        "esic": "ଇଏସଆଇସି ଦୁର୍ଘଟଣା ବୀମା (୨,୦୦,୦୦୦ ଟଙ୍କା ପର୍ଯ୍ୟନ୍ତ)"
      }
    }
  }
  ```

### `GET /api/localization/translate?key=tagline&lang=hi`
Translate a specific key or phrase dynamically into any supported language.

