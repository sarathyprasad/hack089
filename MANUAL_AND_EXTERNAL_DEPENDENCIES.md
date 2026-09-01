# Manual and External Dependencies — Shram Setu

This document lists all libraries, drivers, runtime dependencies, and confirms zero external paid API dependencies for the POC demonstration.

---

## 1. Zero External Paid API Dependency Guarantee

For the POC evaluation, the platform is **100% self-contained and operates with zero external paid third-party dependencies**:
- **Payment Processing**: Simulated UPI QR, Card, and Net Banking gateway with instant receipt and transaction ID generation.
- **SMS / OTP Verification**: Simulated instant credential verification.
- **Maps & Geocoding**: Regional distance calculation using haversine mathematical algorithm across Khordha, Cuttack, and Puri coordinates.
- **AI Demand Forecasting**: Predictive seasonal regression algorithm based on historical booking frequency, population density, and seasonal weather patterns.

---

## 2. Backend Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `express` | `^5.2.1` | Core REST API web framework |
| `pg` | `^8.23.0` | High-performance PostgreSQL client and connection pool driver |
| `jsonwebtoken` | `^9.0.3` | JWT token issuance and verification for stateless authentication |
| `bcryptjs` | `^3.0.3` | Password hashing with cryptographic salts |
| `cors` | `^2.8.6` | Cross-Origin Resource Sharing middleware |
| `helmet` | `^8.3.0` | HTTP security headers |
| `morgan` | `^1.11.0` | HTTP request logging |
| `dotenv` | `^17.4.2` | Environment variables loader |

---

## 3. Frontend Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `react` | `^18.3.1` | User interface library |
| `react-dom` | `^18.3.1` | React DOM bindings |
| `react-router-dom` | `^6.26.1` | Client-side routing with protected route guards |
| `lucide-react` | `^0.436.0` | Modern SVG icons |
| `tailwindcss` | `^3.4.10` | Utility-first CSS framework with government design tokens |
| `vite` | `^5.4.2` | High-speed frontend build tool and development server |
