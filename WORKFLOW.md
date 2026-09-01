# System Workflows & User Journeys — Shram Setu

This document outlines the detailed workflows across all platform roles and actors.

---

## 1. 👤 Citizen / Customer Workflow

```mermaid
graph TD
    A[Browse Services Catalog / Directory] --> B[Click 'Book Service']
    B --> C[Select Service & Address in Khordha/Cuttack/Puri]
    C --> D{Emergency 24/7?}
    D -->|Yes| E[Prioritize 24/7 Emergency Response Squad]
    D -->|No| F[Standard Scheduled Booking]
    E --> G[Smart Matching Engine: Skill + Proximity + Availability]
    F --> G
    G --> H[Select Top-Ranked Verified Worker]
    H --> I[Review Standardized Tariff: Base + 10% Welfare + 5% Fee]
    I --> J[Order Placed -> Booking Status: REQUESTED]
    J --> K[Assigned Worker Accepts -> Status: ACCEPTED]
    K --> L[Worker Arrives On-Site -> Status: IN_PROGRESS]
    L --> M[Worker Finishes Job -> Status: COMPLETED]
    M --> N[Customer Pays via UPI / Card]
    N --> O[Instant Government Tax Invoice Generated]
    O --> P[Customer Rates & Reviews Worker]
```

### Key Customer Steps:
1. **Service Selection**: Citizen explores catalog with government standard rates.
2. **Smart Matching Wizard**: 4-step wizard with location selection and instant worker recommendations scored by algorithm.
3. **Transparent Quotation**: Clear breakdown of 10% worker social security contribution.
4. **Lifecycle Tracking**: 5-step visual progress bar with direct phone link to assigned worker.
5. **Payment & Invoicing**: Instant UPI simulation and printable tax invoice.
6. **Citizen Review**: 5-star rating with quality tags to support cooperative worker ranking.

---

## 2. 👷 Worker Member Workflow

```mermaid
graph TD
    W1[Worker Logs into Portal] --> W2[Set Duty Availability: AVAILABLE / BUSY / OFFLINE]
    W2 --> W3[Incoming Job Dispatch Notification]
    W3 --> W4{Accept Order?}
    W4 -->|Decline| W5[Return to Federation Dispatch Pool]
    W4 -->|Accept| W6[Job Moves to Active Work Orders]
    W6 --> W7[Travel to Site -> Click 'Start Work']
    W7 --> W8[Execute Repairs -> Click 'Mark Task Completed']
    W8 --> W9[Earnings Credited to Worker Ledger]
    W9 --> W10[10% Capped Levy Contributed to Welfare Pool]
    W10 --> W11[Worker Explores Enrolled Welfare Programs in Welfare Centre]
```

### Key Worker Steps:
1. **Duty Availability**: 1-click status switch ensuring workers maintain autonomy over working hours.
2. **Dispatch Queue**: Incoming work requests with customer location and payout value.
3. **On-Site Execution**: Progression from Start Work to Task Completed.
4. **Earnings Ledger**: Transparent history of payouts without arbitrary platform commission cuts.
5. **Worker Welfare Centre**: Direct visibility into ESIC accident cover, health cards, EPFO pensions, and 1-click NSDC workshop enrollments.

---

## 3. 🏢 Cooperative Administrator Workflow

```mermaid
graph TD
    A1[Admin Logs into Federation Portal] --> A2[Review Federation KPI Banner]
    A2 --> A3[Audit Pending Worker Registrations]
    A3 --> A4{Review ITI / Trade Certificates}
    A4 -->|Approve| A5[Mark Worker: VERIFIED -> Active in Directory]
    A4 -->|Reject| A6[Mark Worker: REJECTED with Reason]
    A2 --> A7[Booking & Dispatch Oversight across Districts]
    A2 --> A8[AI Demand Forecasting & Seasonal Spike Directives]
    A8 --> A9[Workforce Gap Analysis: Shortage vs Surplus]
    A9 --> A10[Authorize Inter-District Mutual Aid Workforce Transfer]
```

### Key Administrator Steps:
1. **Federation Oversight**: Monitor active dispatches, completed gigs, emergency volume, and earnings across all member societies.
2. **Worker Verification**: Review submitted trade licenses and ITI credentials before activating workers on the public directory.
3. **AI Demand Forecasting**: Monitor 4-week predictive demand tables and seasonal weather directives.
4. **Inter-Cooperative Mutual Aid**: Authorize temporary inter-district worker transfer agreements to balance regional shortages.
