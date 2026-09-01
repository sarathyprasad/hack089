const bcrypt = require('bcryptjs');
const { query, closeDb } = require('./connection');
const { migrate } = require('./migrate');

/**
 * Seed the PostgreSQL database with 10 Real-World Test Cases covering the 7-Phase Workflow.
 */
async function seed() {
  await migrate();

  const salt = await bcrypt.hash('demo123', 10);

  console.log('🧹 Clearing existing tables...');
  await query(`
    TRUNCATE TABLE 
      sos_logs,
      dispute_tickets,
      appliance_lineage,
      worker_welfare, 
      reviews, 
      invoices, 
      payments, 
      bookings, 
      parts_catalog,
      certifications, 
      worker_skills, 
      workers, 
      skills, 
      services, 
      users, 
      cooperatives 
    RESTART IDENTITY CASCADE;
  `);

  console.log('🌱 Populating 10 Real-World Test Cases in PostgreSQL...');

  // =============================================
  // 1. Cooperatives (3 Federations)
  // =============================================
  const cooperatives = [
    ['Bhubaneswar Labour Cooperative Federation', 'COOP-OD-2024-001', 'Khordha', 'Bhubaneswar', 'Saheed Nagar, Unit-8, Bhubaneswar', '0674-2540001', 'contact@bbsrlabourcoop.od.in', 'Premier labour cooperative federation serving Bhubaneswar metro area.'],
    ['Cuttack District Labour Cooperative Society', 'COOP-OD-2024-002', 'Cuttack', 'Cuttack', 'Buxi Bazar, Cuttack', '0671-2310002', 'contact@cuttacklabourcoop.od.in', 'Labour cooperative society providing skilled artisans across Cuttack district.'],
    ['Puri Coastal Labour Cooperative', 'COOP-OD-2024-003', 'Puri', 'Puri', 'Grand Road, Puri', '06752-220003', 'contact@purilabourcoop.od.in', 'Coastal cooperative focusing on maintenance and domestic trades.'],
  ];

  for (const c of cooperatives) {
    await query(
      `INSERT INTO cooperatives (name, registration_number, district, city, address, contact_phone, contact_email, description)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
      c
    );
  }

  // =============================================
  // 2. Users (5 Customers + 18 Workers + 2 Admins = 25 Users)
  // =============================================
  const users = [
    // Customers (IDs 1-5)
    ['Ananya Patel', 'customer@demo.local', '9876543210', salt, 'CUSTOMER', 'Khordha', 'Bhubaneswar', 'Patia, Bhubaneswar', '751024', 20.3540, 85.8170, 1],
    ['Priya Mohanty', 'priya@demo.local', '9876543211', salt, 'CUSTOMER', 'Khordha', 'Bhubaneswar', 'Jaydev Vihar, Bhubaneswar', '751013', 20.2961, 85.8245, 1],
    ['Sanjay Das', 'sanjay@demo.local', '9876543212', salt, 'CUSTOMER', 'Cuttack', 'Cuttack', 'College Square, Cuttack', '753003', 20.4625, 85.8830, 1],
    ['Meera Rath', 'meera@demo.local', '9876543213', salt, 'CUSTOMER', 'Puri', 'Puri', 'VIP Road, Puri', '752001', 19.8135, 85.8312, 1],
    ['Vikram Sahoo', 'vikram@demo.local', '9876543214', salt, 'CUSTOMER', 'Khordha', 'Bhubaneswar', 'Nayapalli, Bhubaneswar', '751012', 20.2850, 85.8020, 1],

    // Workers (IDs 6-23)
    ['Ramesh Kumar (Master Electrician)', 'ramesh.w@demo.local', '9876543301', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Rasulgarh, Bhubaneswar', '751010', 20.3095, 85.8530, 1],
    ['Suresh Behera (Gold Electrician)', 'suresh.w@demo.local', '9876543302', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Mancheswar, Bhubaneswar', '751017', 20.3240, 85.8380, 1],
    ['Ganesh Pradhan (Master Plumber)', 'ganesh.w@demo.local', '9876543303', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Chandrasekharpur, Bhubaneswar', '751016', 20.3350, 85.8100, 1],
    ['Mohan Nayak (Silver Carpenter)', 'mohan.w@demo.local', '9876543304', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Saheed Nagar, Bhubaneswar', '751007', 20.2870, 85.8450, 1],
    ['Biju Sahu (Gold Painter)', 'biju.w@demo.local', '9876543305', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Khandagiri, Bhubaneswar', '751030', 20.2570, 85.7750, 1],
    ['Prakash Jena (Bronze Apprentice)', 'prakash.w@demo.local', '9876543306', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Madhupatna, Bhubaneswar', '751024', 20.3540, 85.8170, 1],
    ['Santosh Mishra (Master Plumber)', 'santosh.w@demo.local', '9876543307', salt, 'WORKER', 'Cuttack', 'Cuttack', 'Bidanasi, Cuttack', '753014', 20.4890, 85.8770, 1],
    ['Raju Parida (Gardener & Safety SOS)', 'raju.w@demo.local', '9876543308', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Nuapatna, Bhubaneswar', '751012', 20.2850, 85.8020, 1],
    ['Deepak Swain (Silver Caregiver)', 'deepak.w@demo.local', '9876543309', salt, 'WORKER', 'Puri', 'Puri', 'Balighai, Puri', '752002', 19.8250, 85.8450, 1],
    ['Manoj Dalai (Licensed Driver)', 'manoj.w@demo.local', '9876543310', salt, 'WORKER', 'Puri', 'Puri', 'Penthakata, Puri', '752001', 19.7980, 85.8210, 1],
    ['Rajendra Mohapatra (Master AC Tech)', 'rajendra.w@demo.local', '9876543311', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Baramunda, Bhubaneswar', '751003', 20.2750, 85.8100, 1],
    ['Ashok Lenka (Domestic Helper)', 'ashok.w@demo.local', '9876543312', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'VSS Nagar, Bhubaneswar', '751007', 20.2920, 85.8350, 1],
    ['Tapan Sethi (Carpenter)', 'tapan.w@demo.local', '9876543313', salt, 'WORKER', 'Cuttack', 'Cuttack', 'Tulsipur, Cuttack', '753008', 20.4650, 85.8880, 1],
    ['Dilip Barik (Appliance Repair)', 'dilip.w@demo.local', '9876543314', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Aiginia, Bhubaneswar', '751019', 20.2650, 85.8450, 1],
    ['Harish Panda (IT & CCTV Tech)', 'harish.w@demo.local', '9876543315', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Infocity, Bhubaneswar', '751024', 20.3470, 85.8200, 1],
    ['Narayan Rout (Deep Cleaning)', 'narayan.w@demo.local', '9876543316', salt, 'WORKER', 'Puri', 'Puri', 'Sipasarubali, Puri', '752002', 19.8100, 85.8380, 1],
    ['Kishore Mahapatra (Senior Plumber)', 'kishore.w@demo.local', '9876543317', salt, 'WORKER', 'Cuttack', 'Cuttack', 'Link Road, Cuttack', '753012', 20.4700, 85.8800, 1],
    ['Subash Naik (New Applicant)', 'subash.w@demo.local', '9876543318', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Dumduma, Bhubaneswar', '751019', 20.2730, 85.8380, 1],

    // Admins (IDs 24-25)
    ['Arun Kumar Pattnaik (Federation Secretary)', 'admin@demo.local', '9876543401', salt, 'COOPERATIVE_ADMIN', 'Khordha', 'Bhubaneswar', 'Unit-8, Bhubaneswar', '751012', 20.2900, 85.8200, 1],
    ['Smt. Laxmi Devi (Cuttack Arbitrator)', 'admin2@demo.local', '9876543402', salt, 'COOPERATIVE_ADMIN', 'Cuttack', 'Cuttack', 'Buxi Bazar, Cuttack', '753001', 20.4620, 85.8830, 1],
  ];

  for (const u of users) {
    await query(
      `INSERT INTO users (name, email, phone, password, role, district, city, address, pincode, latitude, longitude, is_active)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)`,
      u
    );
  }

  // =============================================
  // 3. Worker Profiles with Verified Status and Tiers
  // =============================================
  const workerProfiles = [
    [6,  'WKR-OD-1001', 1, 10, 'Bhubaneswar', 20.3095, 85.8530, 'VERIFIED', 'AVAILABLE', 4.9, 58, 54, 185000, 'Master electrician specializing in 3-phase lines, MCB panels, and solar rooftop installations.', 'MASTER', 950, 0, 0, 'Electrical'],
    [7,  'WKR-OD-1002', 1, 6,  'Bhubaneswar', 20.3240, 85.8380, 'VERIFIED', 'AVAILABLE', 4.7, 42, 38, 115000, 'Skilled electrician with expertise in appliance wiring and inverter setup.', 'GOLD', 680, 0, 0, 'Electrical'],
    [8,  'WKR-OD-1003', 1, 12, 'Bhubaneswar', 20.3350, 85.8100, 'VERIFIED', 'AVAILABLE', 4.9, 64, 60, 210000, 'Senior master plumber with deep experience in CPVC waterlines and pressure pumps.', 'MASTER', 980, 0, 0, 'Plumbing'],
    [9,  'WKR-OD-1004', 1, 5,  'Bhubaneswar', 20.2870, 85.8450, 'VERIFIED', 'AVAILABLE', 4.6, 32, 30, 84000,  'Professional carpenter specializing in modular furniture, doors, and hydraulic hinges.', 'SILVER', 480, 0, 0, 'Carpentry'],
    [10, 'WKR-OD-1005', 1, 8,  'Bhubaneswar', 20.2570, 85.7750, 'VERIFIED', 'AVAILABLE', 4.8, 46, 44, 142000, 'Expert painter for residential society bulk contracts and waterproof coating.', 'GOLD', 720, 0, 0, 'Painting'],
    [11, 'WKR-OD-1006', 1, 2,  'Bhubaneswar', 20.3540, 85.8170, 'VERIFIED', 'AVAILABLE', 4.4, 18, 16, 38000,  'Apprentice electrician trained under ITI; paired with master artisan for complex jobs.', 'BRONZE', 220, 0, 0, 'Electrical'],
    [12, 'WKR-OD-1007', 2, 9,  'Cuttack',     20.4890, 85.8770, 'VERIFIED', 'AVAILABLE', 4.8, 48, 46, 161000, 'Master plumber in Cuttack specializing in underground drainage and leak detection.', 'MASTER', 890, 0, 0, 'Plumbing'],
    [13, 'WKR-OD-1008', 1, 7,  'Bhubaneswar', 20.2850, 85.8020, 'VERIFIED', 'AVAILABLE', 4.8, 38, 36, 94000,  'Senior landscape gardener, horticulturist, and terrace garden specialist.', 'GOLD', 710, 0, 0, 'Gardening'],
    [14, 'WKR-OD-1009', 3, 6,  'Puri',        19.8250, 85.8450, 'VERIFIED', 'AVAILABLE', 4.7, 36, 34, 92000,  'Certified caregiver with Red Cross geriatric first aid credentials.', 'SILVER', 510, 0, 0, 'Caregiving'],
    [15, 'WKR-OD-1010', 3, 8,  'Puri',        19.7980, 85.8210, 'VERIFIED', 'AVAILABLE', 4.6, 30, 28, 76000,  'Commercial chauffeur with clean state driving record.', 'SILVER', 460, 0, 0, 'Driving'],
    [16, 'WKR-OD-1011', 1, 11, 'Bhubaneswar', 20.2750, 85.8100, 'VERIFIED', 'AVAILABLE', 4.9, 58, 55, 195000, 'Senior HVAC master technician specializing in inverter split ACs and chillers.', 'MASTER', 940, 0, 0, 'Appliance Repair'],
    [17, 'WKR-OD-1012', 1, 5,  'Bhubaneswar', 20.2920, 85.8350, 'VERIFIED', 'AVAILABLE', 4.5, 26, 24, 60000,  'Domestic helper and home sanitation professional.', 'BRONZE', 290, 0, 0, 'Domestic Services'],
    [18, 'WKR-OD-1013', 2, 7,  'Cuttack',     20.4650, 85.8880, 'PENDING',  'AVAILABLE', 0.0, 0,  0,  0,      'New applicant awaiting cooperative document verification.', 'BRONZE', 100, 0, 0, 'Carpentry'],
    [19, 'WKR-OD-1014', 1, 4,  'Bhubaneswar', 20.2650, 85.8450, 'VERIFIED', 'AVAILABLE', 4.3, 16, 14, 39000,  'Appliance repair technician for washing machines and refrigerators.', 'BRONZE', 240, 0, 0, 'Appliance Repair'],
    [20, 'WKR-OD-1015', 1, 3,  'Bhubaneswar', 20.3470, 85.8200, 'VERIFIED', 'AVAILABLE', 4.4, 14, 12, 32000,  'Security CCTV technician and networking installer.', 'BRONZE', 210, 0, 0, 'Technician Services'],
    [21, 'WKR-OD-1016', 3, 5,  'Puri',        19.8100, 85.8380, 'REJECTED', 'OFFLINE',   0.0, 0,  0,  0,      'Documents incomplete — pending trade re-certification.', 'BRONZE', 0, 1, 0, 'Cleaning'],
    [22, 'WKR-OD-1017', 2, 6,  'Cuttack',     20.4700, 85.8800, 'VERIFIED', 'AVAILABLE', 4.6, 32, 30, 86000,  'Skilled carpenter and wood polishing specialist.', 'SILVER', 520, 0, 0, 'Carpentry'],
    [23, 'WKR-OD-1018', 1, 2,  'Bhubaneswar', 20.2730, 85.8380, 'PENDING',  'AVAILABLE', 0.0, 0,  0,  0,      'New painter registration under review by cooperative federation.', 'BRONZE', 100, 0, 0, 'Painting'],
  ];

  for (const w of workerProfiles) {
    await query(
      `INSERT INTO workers (user_id, worker_code, cooperative_id, experience_years, service_area, latitude, longitude, verification_status, availability, rating, total_reviews, total_jobs_completed, total_earnings, bio, tier, merit_points, strike_count, sos_active, primary_trade)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19)`,
      w
    );
  }

  // =============================================
  // 4. Skills Taxonomy
  // =============================================
  const skills = [
    ['Electrical Wiring', 'Electrical', 'Residential and commercial electrical wiring'],
    ['Electrical Repair', 'Electrical', 'Repair of electrical fixtures and systems'],
    ['Appliance Installation', 'Electrical', 'Installation of electrical appliances'],
    ['Pipe Fitting', 'Plumbing', 'Installation and repair of pipes'],
    ['Leak Repair', 'Plumbing', 'Detection and repair of water leaks'],
    ['Drainage Work', 'Plumbing', 'Drainage system installation and maintenance'],
    ['Furniture Making', 'Carpentry', 'Custom furniture construction'],
    ['Door & Window Repair', 'Carpentry', 'Repair and installation of doors and windows'],
    ['Woodwork', 'Carpentry', 'General woodworking and finishing'],
    ['Interior Painting', 'Painting', 'Interior wall and ceiling painting'],
    ['Exterior Painting', 'Painting', 'Exterior wall and surface painting'],
    ['Deep Cleaning', 'Cleaning', 'Thorough deep cleaning of homes and offices'],
    ['Sanitation', 'Cleaning', 'Sanitation and disinfection services'],
    ['Landscaping', 'Gardening', 'Garden design and landscaping'],
    ['Plant Maintenance', 'Gardening', 'Regular plant care and maintenance'],
    ['Elderly Care', 'Caregiving', 'Professional elderly care and assistance'],
    ['Child Care', 'Caregiving', 'Safe and caring child supervision'],
    ['Personal Driving', 'Driving', 'Licensed driving for personal vehicles'],
    ['Commercial Driving', 'Driving', 'Driving for commercial purposes'],
    ['AC Repair', 'Appliance Repair', 'Air conditioner servicing and repair'],
    ['Refrigerator Repair', 'Appliance Repair', 'Refrigerator and freezer repair'],
    ['Cooking', 'Domestic Services', 'Home cooking and meal preparation'],
    ['Household Management', 'Domestic Services', 'General household help and management'],
    ['CCTV Installation', 'Technician Services', 'Security camera setup and maintenance'],
    ['Computer Repair', 'Technician Services', 'Computer and laptop repair'],
  ];

  for (const s of skills) {
    await query(`INSERT INTO skills (name, category, description) VALUES ($1, $2, $3)`, s);
  }

  // =============================================
  // 5. Worker Skills Mapping
  // =============================================
  const workerSkills = [
    [1, 1, 'EXPERT'], [1, 2, 'EXPERT'], [1, 3, 'EXPERT'],
    [2, 1, 'EXPERT'], [2, 2, 'EXPERT'], [2, 3, 'INTERMEDIATE'],
    [3, 4, 'EXPERT'], [3, 5, 'EXPERT'], [3, 6, 'EXPERT'],
    [4, 7, 'EXPERT'], [4, 8, 'EXPERT'], [4, 9, 'INTERMEDIATE'],
    [5, 10, 'EXPERT'], [5, 11, 'EXPERT'],
    [6, 1, 'INTERMEDIATE'], [6, 2, 'INTERMEDIATE'],
    [7, 4, 'EXPERT'], [7, 5, 'EXPERT'], [7, 6, 'INTERMEDIATE'],
    [8, 14, 'EXPERT'], [8, 15, 'EXPERT'],
    [9, 16, 'EXPERT'], [9, 17, 'INTERMEDIATE'],
    [10, 18, 'EXPERT'], [10, 19, 'INTERMEDIATE'],
    [11, 20, 'EXPERT'], [11, 21, 'EXPERT'],
    [12, 22, 'EXPERT'], [12, 23, 'EXPERT'],
    [13, 7, 'INTERMEDIATE'], [13, 9, 'BEGINNER'],
    [14, 20, 'EXPERT'], [14, 21, 'EXPERT'],
    [15, 24, 'EXPERT'], [15, 25, 'EXPERT'],
    [16, 12, 'EXPERT'], [16, 13, 'EXPERT'],
    [17, 4, 'EXPERT'], [17, 5, 'EXPERT'],
    [18, 10, 'BEGINNER'],
  ];

  for (const ws of workerSkills) {
    await query(`INSERT INTO worker_skills (worker_id, skill_id, proficiency_level) VALUES ($1, $2, $3)`, ws);
  }

  // =============================================
  // 6. Services Catalog (15 Standard Items)
  // =============================================
  const services = [
    ['Electrical Repair', 'Electrical', 'Repair of switches, wiring, MCB, and electrical fixtures', 299, 'per_visit', 'Zap', 0],
    ['Electrical Installation', 'Electrical', 'New wiring, 3-phase switch board, and heavy appliance cabling', 499, 'per_visit', 'Zap', 1],
    ['Plumbing Repair', 'Plumbing', 'Pipe repair, leak fixing, tap and flush repair', 349, 'per_visit', 'Droplets', 0],
    ['Plumbing Installation', 'Plumbing', 'Complete bathroom waterline fitting and drainage conduit installation', 599, 'per_visit', 'Droplets', 1],
    ['Carpentry Work', 'Carpentry', 'Furniture repair, door/window fixing, woodwork', 399, 'per_visit', 'Hammer', 0],
    ['Painting Service', 'Painting', 'Interior and exterior premium weather coating', 15, 'per_sqft', 'Paintbrush', 1],
    ['Deep Cleaning', 'Cleaning', 'Full home or commercial hospital-grade deep sanitation', 999, 'per_session', 'SprayCan', 0],
    ['Gardening Service', 'Gardening', 'Garden maintenance, landscaping, plant care', 299, 'per_visit', 'Flower2', 0],
    ['Caregiver Service', 'Caregiving', 'Elderly care, child care, and patient assistance', 499, 'per_day', 'HeartPulse', 0],
    ['Driver Service', 'Driving', 'Personal or commercial driving on demand', 399, 'per_day', 'Car', 0],
    ['AC/Appliance Repair', 'Appliance Repair', 'Compressor replacement, PCB diagnostics, and gas charging', 449, 'per_visit', 'Wrench', 1],
    ['Domestic Help', 'Domestic Services', 'Cooking, cleaning, and household management', 349, 'per_day', 'Home', 0],
    ['CCTV/IT Services', 'Technician Services', 'NVR/DVR 8-channel CCTV setup and fiber network termination', 599, 'per_visit', 'Settings', 1],
    ['Emergency Electrical', 'Emergency Services', '24/7 priority emergency electrical short-circuit restoration', 599, 'per_visit', 'AlertTriangle', 1],
    ['Emergency Plumbing', 'Emergency Services', '24/7 emergency high-pressure main line burst containment', 599, 'per_visit', 'AlertTriangle', 1],
  ];

  for (const s of services) {
    await query(`INSERT INTO services (name, category, description, base_price, price_unit, icon, is_complex) VALUES ($1, $2, $3, $4, $5, $6, $7)`, s);
  }

  // =============================================
  // 7. Locked Spare Parts Matrix (Phase 2 & 4)
  // =============================================
  const parts = [
    ['Electrical', '16A Havells Modular MCB', 220, 'piece', 12],
    ['Electrical', 'Anchor 6A 2-Way Switch', 65, 'piece', 24],
    ['Electrical', 'Finolex 2.5 sqmm Copper Wire (10m)', 340, 'bundle', 12],
    ['Electrical', 'Orient 2.5uF Fan Capacitor', 110, 'piece', 6],
    ['Plumbing', 'Astral 1/2" Brass Ball Valve', 185, 'piece', 12],
    ['Plumbing', 'Supreme CPVC 1" Elbow Joint', 45, 'piece', 24],
    ['Plumbing', 'Teflon Sealing Tape (Pack of 3)', 60, 'pack', 6],
    ['Plumbing', 'SS Flexible Waste Pipe (Braided)', 160, 'piece', 12],
    ['Appliance Repair', 'Universal AC Run Capacitor (45uF)', 380, 'piece', 6],
    ['Appliance Repair', 'R32 Eco-friendly AC Gas Canister (500g)', 850, 'can', 6],
    ['Appliance Repair', 'Heavy Duty Refrigerator Relay Kit', 290, 'piece', 6],
    ['Carpentry', 'Godrej Stainless Steel Mortise Lock Set', 750, 'set', 36],
    ['Carpentry', 'Hettich Soft-Close Hydraulic Hinges (Pair)', 240, 'pair', 24],
    ['Painting', 'Asian Paints Damp-Proof Acrylic Primer (1L)', 320, 'litre', 12],
    ['Painting', 'Waterproof Wall Putty (5kg Bag)', 190, 'bag', 6],
  ];

  for (const p of parts) {
    await query(`INSERT INTO parts_catalog (trade_category, part_name, standard_price, unit, warranty_months) VALUES ($1, $2, $3, $4, $5)`, p);
  }

  // =============================================
  // 8. Certifications
  // =============================================
  const certifications = [
    [1, 'ITI Master Electrician Certificate', 'Govt. ITI Bhubaneswar', 'ITI-BBSR-2014-E1024', '2014-06-15', 'VERIFIED'],
    [1, 'Electrical Safety Standard Training', 'OSEB Training Centre', 'OSEB-ST-2020-442', '2020-03-10', 'VERIFIED'],
    [2, 'ITI Electrician Certificate', 'Govt. ITI Cuttack', 'ITI-CTC-2018-E2055', '2018-07-20', 'VERIFIED'],
    [3, 'Master Plumber License', 'NSDC Skill India', 'NSDC-PLB-2013-3201', '2013-11-05', 'VERIFIED'],
    [4, 'Carpentry NTC Certification', 'NCVT', 'NCVT-CRP-2019-4102', '2019-05-12', 'VERIFIED'],
    [5, 'Painting & Weather Coating Cert.', 'NSDC Skill India', 'NSDC-PNT-2017-5034', '2017-08-22', 'VERIFIED'],
    [7, 'Master Plumber License', 'Cuttack Municipal Corp.', 'CMC-MPL-2015-7088', '2015-01-15', 'VERIFIED'],
    [11, 'HVAC Master Technician Certificate', 'CESL India', 'CESL-ME-2013-11002', '2013-12-01', 'VERIFIED'],
  ];

  for (const c of certifications) {
    await query(`INSERT INTO certifications (worker_id, certification_name, issuing_organization, certificate_number, issue_date, verification_status) VALUES ($1, $2, $3, $4, $5, $6)`, c);
  }

  // =============================================
  // 9. THE 10 REAL-WORLD TEST CASES (PHASE 1-7 COMPLETE FLOWS)
  // =============================================
  const testBookings = [
    // CASE 1: Ready for Arrival OTP Handshake (Customer Ananya Patel & Master Artisan Ramesh Kumar)
    ['BKG-2026-0001', 1, 1, null, 1, 'Khordha', 'Bhubaneswar', 'Patia, Plot 42, Near KIIT Campus', '751024', 20.3540, 85.8170, '2026-08-28', '10:00 AM', 0, 0, 0, 'ACCEPTED', 299, 0, null, 14.95, 14.95, 328.9, 'Main switch board sparking; customer has Arrival OTP ready.', '4821', '7193', null, null, null, 0, null, '2026-08-28T07:00:00Z'],

    // CASE 2: Emergency Plumbing In-Progress on Site (Arrival OTP entered, Pre-Job photo uploaded)
    ['BKG-2026-0002', 2, 3, null, 15, 'Khordha', 'Bhubaneswar', 'Jaydev Vihar, Flat 302', '751013', 20.2961, 85.8245, '2026-08-28', '02:00 PM', 1, 0, 0, 'IN_PROGRESS', 599, 185, 'Astral 1/2" Brass Ball Valve', 29.95, 29.95, 843.9, 'Emergency pipe burst contained. Ready for Completion OTP.', '5932', '8401', 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400', null, null, 0, null, '2026-08-28T07:30:00Z'],

    // CASE 3: Master-Artisan Pairing Case (Bronze Apprentice Prakash Jena paired with Master Ramesh Kumar)
    ['BKG-2026-0003', 1, 6, 1, 2, 'Khordha', 'Bhubaneswar', 'Patia, Tower B-402', '751024', 20.3540, 85.8170, '2026-08-28', '04:00 PM', 0, 0, 0, 'MATCHED', 499, 0, null, 24.95, 24.95, 548.9, 'Heavy 3-phase rewiring. Apprentice Prakash paired with Master Ramesh.', '6319', '2847', null, null, null, 0, null, '2026-08-28T08:00:00Z'],

    // CASE 4: Institutional / Apartment Society Bulk Contract Discount (-15%)
    ['BKG-2026-0004', 5, 5, null, 6, 'Khordha', 'Bhubaneswar', 'Nayapalli, Niladri Vihar Society', '751012', 20.2850, 85.8020, '2026-08-29', '09:00 AM', 0, 1, 450, 'ACCEPTED', 2550, 320, 'Asian Paints Damp-Proof Acrylic Primer', 127.5, 127.5, 3125.0, 'Society common corridor repainting with 15% master contract discount.', '7741', '1952', null, null, null, 0, null, '2026-08-28T08:30:00Z'],

    // CASE 5: Completed with 7-Day Free Repair Guarantee Active (Eligible for 1-click Free Re-dispatch)
    ['BKG-2026-0005', 2, 3, null, 3, 'Khordha', 'Bhubaneswar', 'Jaydev Vihar, House 12', '751013', 20.2961, 85.8245, '2026-08-27', '11:00 AM', 0, 0, 0, 'COMPLETED', 349, 185, 'Astral 1/2" Brass Ball Valve', 17.45, 17.45, 568.9, 'Kitchen faucet repair completed yesterday. Standard 7-Day Guarantee is armed.', '3842', '9156', 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400', 'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=400', '2026-09-03T11:00:00Z', 0, '2026-08-27T12:30:00Z', '2026-08-27T08:00:00Z'],

    // CASE 6: Completed & Paid with Odisha Form IV Tax Invoice Available
    ['BKG-2026-0006', 1, 1, null, 1, 'Khordha', 'Bhubaneswar', 'Patia, Plot 42', '751024', 20.3540, 85.8170, '2026-08-26', '10:00 AM', 0, 0, 0, 'COMPLETED', 299, 220, '16A Havells Modular MCB', 14.95, 14.95, 548.9, 'MCB replacement paid via UPI. Printable Form IV invoice generated.', '5129', '6384', 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=400', 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=400', '2026-09-02T10:00:00Z', 0, '2026-08-26T12:00:00Z', '2026-08-26T07:00:00Z'],

    // CASE 7: Active Dispute in Human Arbitration Desk (Customer Sanjay Das & Worker Santosh Mishra)
    ['BKG-2026-0007', 3, 7, null, 4, 'Cuttack', 'Cuttack', 'College Square, Buxi Lane', '753003', 20.4625, 85.8830, '2026-08-26', '03:00 PM', 0, 0, 0, 'COMPLETED', 599, 230, 'CPVC 1" Elbow Joint', 29.95, 29.95, 888.9, 'Drainage fitting inquiry under human arbitration.', '8204', '4719', null, null, '2026-09-02T15:00:00Z', 0, '2026-08-26T17:00:00Z', '2026-08-26T11:00:00Z'],

    // CASE 8: Worker Safety SOS Distress Beacon Active on Live Map
    ['BKG-2026-0008', 5, 8, null, 8, 'Khordha', 'Bhubaneswar', 'Nayapalli, Near Flyover', '751012', 20.2850, 85.8020, '2026-08-28', '08:00 AM', 0, 0, 0, 'IN_PROGRESS', 299, 0, null, 14.95, 14.95, 328.9, 'Gardener Raju Parida triggered 1-Tap SOS beacon during on-site duty.', '1928', '3746', null, null, null, 0, null, '2026-08-28T07:15:00Z'],

    // CASE 9: 5-Star Completed Order with Permanent Appliance Lineage Entry
    ['BKG-2026-0009', 2, 11, null, 11, 'Khordha', 'Bhubaneswar', 'Jaydev Vihar, Plot 88', '751013', 20.2961, 85.8245, '2026-08-25', '01:00 PM', 0, 0, 0, 'COMPLETED', 449, 380, 'Universal AC Run Capacitor (45uF)', 22.45, 22.45, 873.9, 'Daikin AC PCB & capacitor servicing completed and logged to lineage.', '9012', '4581', 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=400', 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=400', '2026-09-01T13:00:00Z', 0, '2026-08-25T15:00:00Z', '2026-08-25T09:00:00Z'],

    // CASE 10: Incoming Request in Dispatch Pool (Awaiting Worker Accept / Decline)
    ['BKG-2026-0010', 4, 1, null, 1, 'Khordha', 'Bhubaneswar', 'VIP Road, Bhubaneswar', '751012', 20.2900, 85.8200, '2026-08-28', '05:00 PM', 0, 0, 0, 'REQUESTED', 299, 0, null, 14.95, 14.95, 328.9, 'New incoming electrical job in dispatch pool with voice audio alert ready.', '3491', '8120', null, null, null, 0, null, '2026-08-28T09:00:00Z'],
  ];

  for (const b of testBookings) {
    await query(
      `INSERT INTO bookings (
        booking_code, customer_id, worker_id, paired_master_worker_id, service_id, location_district, location_city, location_address, location_pincode,
        latitude, longitude, scheduled_date, scheduled_time, is_emergency, is_bulk_order, bulk_discount_amount, status,
        amount, parts_cost, parts_details, cooperative_fee, platform_fee, total_amount, notes,
        arrival_otp, completion_otp, pre_job_photo_url, post_job_photo_url, guarantee_armed_until, guarantee_claimed,
        completed_at, created_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $30, $31, $32)`,
      b
    );
  }

  // Payments for Completed Cases (5, 6, 7, 9)
  const payments = [
    [5, 'TXN-DEMO-20260827-005', 568.9, 'UPI', 'SUCCESS', '2026-08-27T12:35:00Z'],
    [6, 'TXN-DEMO-20260826-006', 548.9, 'UPI', 'SUCCESS', '2026-08-26T12:05:00Z'],
    [7, 'TXN-DEMO-20260826-007', 888.9, 'NET_BANKING', 'SUCCESS', '2026-08-26T17:10:00Z'],
    [9, 'TXN-DEMO-20260825-009', 873.9, 'UPI', 'SUCCESS', '2026-08-25T15:10:00Z'],
  ];

  for (const p of payments) {
    await query(`INSERT INTO payments (booking_id, transaction_id, amount, payment_method, status, paid_at) VALUES ($1, $2, $3, $4, $5, $6)`, p);
  }

  // Invoices for all 10 Cases
  const invoices = [
    [1, 'INV-2026-0001', 'Bhubaneswar Labour Cooperative Federation', 'Ananya Patel', 'Ramesh Kumar (Master)', 'Electrical Repair', '2026-08-28', 299, 0, 14.95, 14.95, 328.9, 'UNPAID'],
    [2, 'INV-2026-0002', 'Bhubaneswar Labour Cooperative Federation', 'Priya Mohanty', 'Ganesh Pradhan (Master)', 'Emergency Plumbing', '2026-08-28', 599, 185, 29.95, 29.95, 843.9, 'UNPAID'],
    [3, 'INV-2026-0003', 'Bhubaneswar Labour Cooperative Federation', 'Ananya Patel', 'Prakash Jena (w/ Master Ramesh)', 'Electrical Installation', '2026-08-28', 499, 0, 24.95, 24.95, 548.9, 'UNPAID'],
    [4, 'INV-2026-0004', 'Bhubaneswar Labour Cooperative Federation', 'Vikram Sahoo', 'Biju Sahu (Gold)', 'Painting Service (Bulk)', '2026-08-29', 2550, 320, 127.5, 127.5, 3125.0, 'UNPAID'],
    [5, 'INV-2026-0005', 'Bhubaneswar Labour Cooperative Federation', 'Priya Mohanty', 'Ganesh Pradhan (Master)', 'Plumbing Repair', '2026-08-27', 349, 185, 17.45, 17.45, 568.9, 'PAID'],
    [6, 'INV-2026-0006', 'Bhubaneswar Labour Cooperative Federation', 'Ananya Patel', 'Ramesh Kumar (Master)', 'Electrical Repair', '2026-08-26', 299, 220, 14.95, 14.95, 548.9, 'PAID'],
    [7, 'INV-2026-0007', 'Cuttack District Labour Cooperative Society', 'Sanjay Das', 'Santosh Mishra (Master)', 'Plumbing Installation', '2026-08-26', 599, 230, 29.95, 29.95, 888.9, 'PAID'],
    [8, 'INV-2026-0008', 'Bhubaneswar Labour Cooperative Federation', 'Vikram Sahoo', 'Raju Parida', 'Gardening Service', '2026-08-28', 299, 0, 14.95, 14.95, 328.9, 'UNPAID'],
    [9, 'INV-2026-0009', 'Bhubaneswar Labour Cooperative Federation', 'Priya Mohanty', 'Rajendra Mohapatra (Master)', 'AC/Appliance Repair', '2026-08-25', 449, 380, 22.45, 22.45, 873.9, 'PAID'],
    [10, 'INV-2026-0010', 'Bhubaneswar Labour Cooperative Federation', 'Meera Rath', 'Assigned Cooperative Worker', 'Electrical Repair', '2026-08-28', 299, 0, 14.95, 14.95, 328.9, 'UNPAID'],
  ];

  for (const inv of invoices) {
    await query(`INSERT INTO invoices (booking_id, invoice_number, cooperative_name, customer_name, worker_name, service_name, service_date, amount, parts_cost, cooperative_fee, platform_fee, total_amount, payment_status) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)`, inv);
  }

  // Reviews for Cases 5, 6, 9
  const reviews = [
    [5, 2, 3, 5, 'Ganesh bhai fixed the kitchen pipe quickly. 7-Day Guarantee is armed and verified.', 5, 5, 5, 'Thank you! Always happy to serve Jaydev Vihar.'],
    [6, 1, 1, 5, 'Ramesh ji arrived right after OTP handshake and installed original Havells MCB.', 5, 5, 5, 'Thank you madam for choosing Bhubaneswar Labour Cooperative.'],
    [9, 2, 11, 5, 'Daikin AC cooling restored to ice cold. Permanent lineage logged in digital book.', 5, 5, 5, 'Keep the filter clean; call us anytime under warranty.'],
  ];

  for (const r of reviews) {
    await query(`INSERT INTO reviews (booking_id, customer_id, worker_id, rating, comment, punctuality_score, quality_score, safety_score, worker_reply) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`, r);
  }

  // Appliance Lineage Records (Phase 6)
  const lineage = [
    [1, 'Main Electrical Distribution Box', 'L&T 8-Way Modular Box', 'SN-LT-2023-9081', '2026-08-26', 'Replaced 16A tripping MCB with Havells C-Curve. Load balanced.', 'Ramesh Kumar (Master Artisan)', 6, '2027-08-26'],
    [2, 'Split Air Conditioner (Living Room)', 'Daikin 1.5 Ton Inverter', 'SN-DK-2022-4410', '2026-08-25', 'Universal 45uF capacitor replaced and gas pressure checked.', 'Rajendra Mohapatra (Master Artisan)', 9, '2027-02-25'],
    [2, 'Kitchen RO Water Purifier', 'Kent Grand Plus RO+UV', 'SN-KT-2021-3382', '2026-08-27', 'Inlet brass ball valve replaced. Standard 7-Day Guarantee active.', 'Ganesh Pradhan (Master Artisan)', 5, '2027-01-27'],
  ];

  for (const l of lineage) {
    await query(`INSERT INTO appliance_lineage (customer_id, appliance_type, brand_model, serial_number, last_service_date, service_summary, technician_name, booking_id, warranty_until) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`, l);
  }

  // Dispute Case 7 in Arbitration Desk
  await query(`
    INSERT INTO dispute_tickets (ticket_code, booking_id, customer_id, worker_id, issue_type, description, status)
    VALUES ('DISP-2026-001', 7, 3, 7, 'Billing Query', 'Customer inquired regarding pipe joint count measurement on Cuttack drainage.', 'OPEN')
  `);

  // SOS Emergency Log for Case 8
  await query(`
    INSERT INTO sos_logs (worker_id, booking_id, latitude, longitude, status, details)
    VALUES (8, 8, 20.2850, 85.8020, 'ACTIVE', '🚨 High priority distress beacon triggered on-site in Nayapalli, Bhubaneswar.')
  `);

  // Welfare records
  const welfare = [
    [1, 'Insurance', 'ESIC Group Accident Insurance', 'ESIC Govt of India', 'ENROLLED', '2024-01-15', '₹2,00,000 accidental coverage + disability income protection'],
    [1, 'Health', 'Cooperative Health Support & Annual Checkup', 'Odisha Cooperative Welfare Fund', 'ENROLLED', '2024-01-15', 'Annual full-body checkup + family diagnostics assistance'],
    [1, 'Training', 'NSDC Advanced Solar & Green Energy Workshop', 'NSDC / ITI Odisha', 'ENROLLED', '2024-06-01', 'Certified 2-week advanced solar rooftop installation module'],
    [3, 'Insurance', 'ESIC Group Accident Insurance', 'ESIC Govt of India', 'ENROLLED', '2024-02-10', 'Covered under ESIC accident insurance scheme'],
    [3, 'Pension', 'EPFO Social Security & Pension Corpus', 'EPFO India', 'ENROLLED', '2024-02-10', 'Monthly cooperative retirement fund contribution active'],
  ];

  for (const w of welfare) {
    await query(`INSERT INTO worker_welfare (worker_id, benefit_type, benefit_name, provider, status, enrollment_date, details) VALUES ($1, $2, $3, $4, $5, $6, $7)`, w);
  }

  console.log('\n✅ 10 Real-World 7-Phase Test Cases Populated Successfully in PostgreSQL!\n');
}

if (require.main === module) {
  seed()
    .then(async () => {
      await closeDb();
      process.exit(0);
    })
    .catch(async (err) => {
      console.error('❌ Seed failed:', err);
      await closeDb();
      process.exit(1);
    });
}

module.exports = { seed };
