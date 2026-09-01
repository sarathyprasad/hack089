const { query, ensureDatabaseExists } = require('./connection');

/**
 * Create all PostgreSQL database tables and apply schema migrations for 7-Phase Workflow.
 */
async function migrate() {
  await ensureDatabaseExists();

  const ddl = `
    -- =============================================
    -- Cooperatives
    -- =============================================
    CREATE TABLE IF NOT EXISTS cooperatives (
      id SERIAL PRIMARY KEY,
      name TEXT NOT NULL,
      registration_number TEXT UNIQUE NOT NULL,
      district TEXT NOT NULL,
      city TEXT,
      address TEXT,
      contact_phone TEXT,
      contact_email TEXT,
      description TEXT,
      created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
    );

    -- =============================================
    -- Users (Customer, Worker, Admin)
    -- =============================================
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      phone TEXT,
      password TEXT NOT NULL,
      role VARCHAR(50) NOT NULL CHECK(role IN ('CUSTOMER', 'WORKER', 'COOPERATIVE_ADMIN')),
      avatar_url TEXT,
      district TEXT,
      city TEXT,
      address TEXT,
      pincode TEXT,
      latitude REAL,
      longitude REAL,
      is_active INTEGER DEFAULT 1,
      created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
    );

    -- =============================================
    -- Workers (extends Users with role='WORKER')
    -- =============================================
    CREATE TABLE IF NOT EXISTS workers (
      id SERIAL PRIMARY KEY,
      user_id INTEGER NOT NULL UNIQUE,
      worker_code TEXT UNIQUE NOT NULL,
      cooperative_id INTEGER NOT NULL,
      experience_years INTEGER DEFAULT 0,
      service_area TEXT,
      latitude REAL,
      longitude REAL,
      verification_status VARCHAR(50) DEFAULT 'PENDING' CHECK(verification_status IN ('PENDING', 'VERIFIED', 'REJECTED')),
      availability VARCHAR(50) DEFAULT 'AVAILABLE' CHECK(availability IN ('AVAILABLE', 'BUSY', 'OFFLINE', 'ON_LEAVE')),
      rating REAL DEFAULT 0.0,
      total_reviews INTEGER DEFAULT 0,
      total_jobs_completed INTEGER DEFAULT 0,
      total_earnings REAL DEFAULT 0.0,
      bio TEXT,
      tier VARCHAR(50) DEFAULT 'BRONZE' CHECK(tier IN ('BRONZE', 'SILVER', 'GOLD', 'MASTER')),
      merit_points INTEGER DEFAULT 100,
      strike_count INTEGER DEFAULT 0,
      sos_active INTEGER DEFAULT 0,
      created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
      FOREIGN KEY (cooperative_id) REFERENCES cooperatives(id)
    );

    -- Ensure newly introduced columns exist in workers if table was already created
    ALTER TABLE workers ADD COLUMN IF NOT EXISTS tier VARCHAR(50) DEFAULT 'BRONZE';
    ALTER TABLE workers ADD COLUMN IF NOT EXISTS merit_points INTEGER DEFAULT 100;
    ALTER TABLE workers ADD COLUMN IF NOT EXISTS strike_count INTEGER DEFAULT 0;
    ALTER TABLE workers ADD COLUMN IF NOT EXISTS sos_active INTEGER DEFAULT 0;
    ALTER TABLE workers ADD COLUMN IF NOT EXISTS primary_trade TEXT;
    ALTER TABLE workers ADD COLUMN IF NOT EXISTS sub_skills TEXT;
    ALTER TABLE workers ADD COLUMN IF NOT EXISTS tools_owned TEXT;
    ALTER TABLE workers ADD COLUMN IF NOT EXISTS aadhaar_number TEXT;
    ALTER TABLE workers ADD COLUMN IF NOT EXISTS pan_number TEXT;
    ALTER TABLE workers ADD COLUMN IF NOT EXISTS ration_card TEXT;
    ALTER TABLE workers ADD COLUMN IF NOT EXISTS bank_name TEXT;
    ALTER TABLE workers ADD COLUMN IF NOT EXISTS bank_account TEXT;
    ALTER TABLE workers ADD COLUMN IF NOT EXISTS bank_ifsc TEXT;
    ALTER TABLE workers ADD COLUMN IF NOT EXISTS emergency_contact_name TEXT;
    ALTER TABLE workers ADD COLUMN IF NOT EXISTS emergency_contact_phone TEXT;
    ALTER TABLE workers ADD COLUMN IF NOT EXISTS emergency_contact_relation TEXT;
    ALTER TABLE workers ADD COLUMN IF NOT EXISTS application_no TEXT;
    ALTER TABLE workers ADD COLUMN IF NOT EXISTS rejection_reason TEXT;
    ALTER TABLE workers ADD COLUMN IF NOT EXISTS reviewed_by_admin_id INTEGER;
    ALTER TABLE workers ADD COLUMN IF NOT EXISTS reviewed_at TIMESTAMPTZ;

    -- =============================================
    -- Skills
    -- =============================================
    CREATE TABLE IF NOT EXISTS skills (
      id SERIAL PRIMARY KEY,
      name TEXT NOT NULL,
      category TEXT NOT NULL,
      description TEXT,
      created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
    );

    -- =============================================
    -- Worker Skills (many-to-many)
    -- =============================================
    CREATE TABLE IF NOT EXISTS worker_skills (
      id SERIAL PRIMARY KEY,
      worker_id INTEGER NOT NULL,
      skill_id INTEGER NOT NULL,
      proficiency_level VARCHAR(50) DEFAULT 'INTERMEDIATE' CHECK(proficiency_level IN ('BEGINNER', 'INTERMEDIATE', 'EXPERT')),
      FOREIGN KEY (worker_id) REFERENCES workers(id) ON DELETE CASCADE,
      FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE,
      UNIQUE(worker_id, skill_id)
    );

    -- =============================================
    -- Certifications
    -- =============================================
    CREATE TABLE IF NOT EXISTS certifications (
      id SERIAL PRIMARY KEY,
      worker_id INTEGER NOT NULL,
      certification_name TEXT NOT NULL,
      issuing_organization TEXT,
      certificate_number TEXT,
      issue_date TEXT,
      expiry_date TEXT,
      document_url TEXT,
      verification_status VARCHAR(50) DEFAULT 'PENDING' CHECK(verification_status IN ('PENDING', 'VERIFIED', 'REJECTED')),
      created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (worker_id) REFERENCES workers(id) ON DELETE CASCADE
    );

    -- =============================================
    -- Services
    -- =============================================
    CREATE TABLE IF NOT EXISTS services (
      id SERIAL PRIMARY KEY,
      name TEXT NOT NULL,
      category TEXT NOT NULL,
      description TEXT,
      base_price REAL NOT NULL,
      price_unit TEXT DEFAULT 'per_visit',
      icon TEXT,
      is_complex INTEGER DEFAULT 0,
      is_active INTEGER DEFAULT 1,
      created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
    );

    ALTER TABLE services ADD COLUMN IF NOT EXISTS is_complex INTEGER DEFAULT 0;

    -- =============================================
    -- Locked Parts Catalog (Phase 2 & 4 Price Matrix)
    -- =============================================
    CREATE TABLE IF NOT EXISTS parts_catalog (
      id SERIAL PRIMARY KEY,
      trade_category VARCHAR(100) NOT NULL,
      part_name TEXT NOT NULL,
      standard_price REAL NOT NULL,
      unit TEXT DEFAULT 'piece',
      warranty_months INTEGER DEFAULT 6,
      created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
    );

    -- =============================================
    -- Bookings (Phase 1-6 Enhanced)
    -- =============================================
    CREATE TABLE IF NOT EXISTS bookings (
      id SERIAL PRIMARY KEY,
      booking_code TEXT UNIQUE NOT NULL,
      customer_id INTEGER NOT NULL,
      worker_id INTEGER,
      paired_master_worker_id INTEGER,
      service_id INTEGER NOT NULL,
      location_district TEXT,
      location_city TEXT,
      location_address TEXT,
      location_pincode TEXT,
      latitude REAL,
      longitude REAL,
      scheduled_date TEXT,
      scheduled_time TEXT,
      is_emergency INTEGER DEFAULT 0,
      is_bulk_order INTEGER DEFAULT 0,
      bulk_discount_amount REAL DEFAULT 0.0,
      status VARCHAR(50) DEFAULT 'REQUESTED' CHECK(status IN ('REQUESTED', 'MATCHED', 'ACCEPTED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
      amount REAL,
      parts_cost REAL DEFAULT 0.0,
      parts_details TEXT,
      cooperative_fee REAL,
      platform_fee REAL,
      total_amount REAL,
      notes TEXT,
      arrival_otp VARCHAR(6),
      completion_otp VARCHAR(6),
      pre_job_photo_url TEXT,
      post_job_photo_url TEXT,
      guarantee_armed_until TIMESTAMPTZ,
      guarantee_claimed INTEGER DEFAULT 0,
      completed_at TIMESTAMPTZ,
      cancelled_at TIMESTAMPTZ,
      cancellation_reason TEXT,
      created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (customer_id) REFERENCES users(id),
      FOREIGN KEY (worker_id) REFERENCES workers(id),
      FOREIGN KEY (paired_master_worker_id) REFERENCES workers(id),
      FOREIGN KEY (service_id) REFERENCES services(id)
    );

    -- Ensure newly introduced columns exist in bookings
    ALTER TABLE bookings ADD COLUMN IF NOT EXISTS arrival_otp VARCHAR(6);
    ALTER TABLE bookings ADD COLUMN IF NOT EXISTS completion_otp VARCHAR(6);
    ALTER TABLE bookings ADD COLUMN IF NOT EXISTS is_bulk_order INTEGER DEFAULT 0;
    ALTER TABLE bookings ADD COLUMN IF NOT EXISTS bulk_discount_amount REAL DEFAULT 0.0;
    ALTER TABLE bookings ADD COLUMN IF NOT EXISTS paired_master_worker_id INTEGER;
    ALTER TABLE bookings ADD COLUMN IF NOT EXISTS pre_job_photo_url TEXT;
    ALTER TABLE bookings ADD COLUMN IF NOT EXISTS post_job_photo_url TEXT;
    ALTER TABLE bookings ADD COLUMN IF NOT EXISTS parts_cost REAL DEFAULT 0.0;
    ALTER TABLE bookings ADD COLUMN IF NOT EXISTS parts_details TEXT;
    ALTER TABLE bookings ADD COLUMN IF NOT EXISTS guarantee_armed_until TIMESTAMPTZ;
    ALTER TABLE bookings ADD COLUMN IF NOT EXISTS guarantee_claimed INTEGER DEFAULT 0;
    ALTER TABLE bookings ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMPTZ;
    ALTER TABLE bookings ADD COLUMN IF NOT EXISTS cancellation_reason TEXT;

    -- =============================================
    -- Payments (Phase 5 Escrow Model)
    -- =============================================
    CREATE TABLE IF NOT EXISTS payments (
      id SERIAL PRIMARY KEY,
      booking_id INTEGER NOT NULL,
      transaction_id TEXT UNIQUE NOT NULL,
      amount REAL NOT NULL,
      payment_method VARCHAR(50) CHECK(payment_method IN ('UPI', 'CARD', 'NET_BANKING', 'CASH')),
      status VARCHAR(50) DEFAULT 'PENDING' CHECK(status IN ('PENDING', 'ESCROW_HELD', 'SUCCESS', 'FAILED', 'REFUNDED')),
      paid_at TIMESTAMPTZ,
      created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (booking_id) REFERENCES bookings(id)
    );

    -- =============================================
    -- Invoices (Phase 5 Form IV Tax Invoices)
    -- =============================================
    CREATE TABLE IF NOT EXISTS invoices (
      id SERIAL PRIMARY KEY,
      booking_id INTEGER NOT NULL UNIQUE,
      invoice_number TEXT UNIQUE NOT NULL,
      cooperative_name TEXT,
      customer_name TEXT,
      worker_name TEXT,
      service_name TEXT,
      service_date TEXT,
      amount REAL,
      parts_cost REAL DEFAULT 0.0,
      cooperative_fee REAL,
      platform_fee REAL,
      total_amount REAL,
      payment_status VARCHAR(50) DEFAULT 'UNPAID',
      created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (booking_id) REFERENCES bookings(id)
    );

    ALTER TABLE invoices ADD COLUMN IF NOT EXISTS parts_cost REAL DEFAULT 0.0;

    -- =============================================
    -- Reviews (Phase 6 2-Way Feedback)
    -- =============================================
    CREATE TABLE IF NOT EXISTS reviews (
      id SERIAL PRIMARY KEY,
      booking_id INTEGER NOT NULL UNIQUE,
      customer_id INTEGER NOT NULL,
      worker_id INTEGER NOT NULL,
      rating INTEGER NOT NULL CHECK(rating >= 1 AND rating <= 5),
      comment TEXT,
      punctuality_score INTEGER DEFAULT 5,
      quality_score INTEGER DEFAULT 5,
      safety_score INTEGER DEFAULT 5,
      worker_reply TEXT,
      created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (booking_id) REFERENCES bookings(id),
      FOREIGN KEY (customer_id) REFERENCES users(id),
      FOREIGN KEY (worker_id) REFERENCES workers(id)
    );

    ALTER TABLE reviews ADD COLUMN IF NOT EXISTS punctuality_score INTEGER DEFAULT 5;
    ALTER TABLE reviews ADD COLUMN IF NOT EXISTS quality_score INTEGER DEFAULT 5;
    ALTER TABLE reviews ADD COLUMN IF NOT EXISTS safety_score INTEGER DEFAULT 5;
    ALTER TABLE reviews ADD COLUMN IF NOT EXISTS worker_reply TEXT;

    -- =============================================
    -- Worker Welfare (Phase 5 & 7)
    -- =============================================
    CREATE TABLE IF NOT EXISTS worker_welfare (
      id SERIAL PRIMARY KEY,
      worker_id INTEGER NOT NULL,
      benefit_type TEXT NOT NULL,
      benefit_name TEXT NOT NULL,
      provider TEXT,
      status VARCHAR(50) DEFAULT 'AVAILABLE' CHECK(status IN ('AVAILABLE', 'ENROLLED', 'PENDING', 'EXPIRED')),
      enrollment_date TEXT,
      details TEXT,
      created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (worker_id) REFERENCES workers(id) ON DELETE CASCADE
    );

    -- =============================================
    -- Appliance Service Lineage (Phase 6 Permanent History)
    -- =============================================
    CREATE TABLE IF NOT EXISTS appliance_lineage (
      id SERIAL PRIMARY KEY,
      customer_id INTEGER NOT NULL,
      appliance_type VARCHAR(100) NOT NULL,
      brand_model TEXT,
      serial_number TEXT,
      last_service_date TEXT,
      service_summary TEXT,
      technician_name TEXT,
      booking_id INTEGER,
      warranty_until TEXT,
      created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE,
      FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL
    );

    -- =============================================
    -- Dispute Resolution Tickets (Phase 7 Governance)
    -- =============================================
    CREATE TABLE IF NOT EXISTS dispute_tickets (
      id SERIAL PRIMARY KEY,
      ticket_code TEXT UNIQUE NOT NULL,
      booking_id INTEGER,
      customer_id INTEGER NOT NULL,
      worker_id INTEGER,
      issue_type VARCHAR(100) NOT NULL,
      description TEXT NOT NULL,
      status VARCHAR(50) DEFAULT 'OPEN' CHECK(status IN ('OPEN', 'IN_REVIEW', 'RESOLVED', 'CLOSED')),
      resolution_notes TEXT,
      arbitrator_name TEXT,
      created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
      resolved_at TIMESTAMPTZ,
      FOREIGN KEY (customer_id) REFERENCES users(id),
      FOREIGN KEY (worker_id) REFERENCES workers(id),
      FOREIGN KEY (booking_id) REFERENCES bookings(id)
    );

    -- =============================================
    -- SOS Emergency Logs (Phase 4 Worker Safety)
    -- =============================================
    CREATE TABLE IF NOT EXISTS sos_logs (
      id SERIAL PRIMARY KEY,
      worker_id INTEGER NOT NULL,
      booking_id INTEGER,
      latitude REAL,
      longitude REAL,
      status VARCHAR(50) DEFAULT 'ACTIVE' CHECK(status IN ('ACTIVE', 'ACKNOWLEDGED', 'RESOLVED')),
      details TEXT,
      triggered_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
      resolved_at TIMESTAMPTZ,
      FOREIGN KEY (worker_id) REFERENCES workers(id) ON DELETE CASCADE
    );

    -- =============================================
    -- Indexes
    -- =============================================
    CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
    CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
    CREATE INDEX IF NOT EXISTS idx_workers_cooperative ON workers(cooperative_id);
    CREATE INDEX IF NOT EXISTS idx_workers_verification ON workers(verification_status);
    CREATE INDEX IF NOT EXISTS idx_workers_tier ON workers(tier);
    CREATE INDEX IF NOT EXISTS idx_bookings_customer ON bookings(customer_id);
    CREATE INDEX IF NOT EXISTS idx_bookings_worker ON bookings(worker_id);
    CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
    CREATE INDEX IF NOT EXISTS idx_appliance_customer ON appliance_lineage(customer_id);
    CREATE INDEX IF NOT EXISTS idx_disputes_status ON dispute_tickets(status);
    CREATE INDEX IF NOT EXISTS idx_sos_status ON sos_logs(status);
  `;

  await query(ddl);
  console.log('✅ PostgreSQL migration complete — 7-Phase schema, tables, and indexes ready.');
}

if (require.main === module) {
  migrate()
    .then(() => {
      console.log('Migration finished.');
      process.exit(0);
    })
    .catch((err) => {
      console.error('Migration failed:', err);
      process.exit(1);
    });
}

module.exports = { migrate };
