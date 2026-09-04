const bcrypt = require('bcryptjs');
const { query, closeDb } = require('./connection');
const { migrate } = require('./migrate');

/**
 * Enhanced Database Seed:
 * - 25 Diverse Customers across Bhubaneswar, Cuttack, Puri, Rourkela, Sambalpur, Berhampur
 * - 38 Skilled Artisans with specialized trades (AC installation, gas refilling, PCB, plumbing, electrical, carpentry, painting, etc.)
 * - 47 Granular Services (including comprehensive AC & Appliance options)
 * - 45+ Skills mapped to artisans
 * - 25 Locked Spare Parts with warranty and regulated prices
 * - 24 Real-World Bookings (REQUESTED, ACCEPTED, IN_PROGRESS, COMPLETED with Form IV invoices, 93-2-5 escrow breakdown, and OTP handshakes)
 * - Full Society & Federation governance, NCCT training, and welfare data
 */
async function seed() {
  await migrate();

  const salt = await bcrypt.hash('demo123', 10);

  console.log('🧹 Clearing all existing tables...');
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
      institutional_tenders,
      society_worker_welfare,
      society_treasury_ledger,
      ncct_trainings,
      society_statutory_documents,
      society_founding_members,
      societies,
      users, 
      cooperatives 
    RESTART IDENTITY CASCADE;
  `);

  console.log('🌱 Populating expanded cooperative database...');

  // =============================================
  // 1. Cooperatives (3 Federations)
  // =============================================
  const cooperatives = [
    ['Bhubaneswar Labour Cooperative Federation', 'COOP-OD-2024-001', 'Khordha', 'Bhubaneswar', 'Saheed Nagar, Unit-8, Bhubaneswar', '0674-2540001', 'contact@bbsrlabourcoop.od.in', 'Premier labour cooperative federation serving Bhubaneswar metro area.'],
    ['Cuttack District Labour Cooperative Society', 'COOP-OD-2024-002', 'Cuttack', 'Cuttack', 'Buxi Bazar, Cuttack', '0671-2310002', 'contact@cuttacklabourcoop.od.in', 'Labour cooperative society providing skilled artisans across Cuttack district.'],
    ['Puri Coastal Labour Cooperative', 'COOP-OD-2024-003', 'Puri', 'Puri', 'Grand Road, Puri', '06752-220003', 'contact@purilabourcoop.od.in', 'Coastal cooperative focusing on maintenance, tourism support, and domestic trades.'],
  ];

  for (const c of cooperatives) {
    await query(
      `INSERT INTO cooperatives (name, registration_number, district, city, address, contact_phone, contact_email, description)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
      c
    );
  }

  // =============================================
  // 2. Users (25 Customers + 38 Workers + 3 Admins = 66 Users)
  // =============================================
  const users = [
    // ── 25 Customers (User IDs 1-25) ──
    ['Ananya Patel', 'customer@demo.local', '9876543210', salt, 'CUSTOMER', 'Khordha', 'Bhubaneswar', 'Patia, Plot 42, Near KIIT Campus', '751024', 20.3540, 85.8170, 1],
    ['Priya Mohanty', 'priya@demo.local', '9876543211', salt, 'CUSTOMER', 'Khordha', 'Bhubaneswar', 'Jaydev Vihar, Flat 302', '751013', 20.2961, 85.8245, 1],
    ['Sanjay Das', 'sanjay@demo.local', '9876543212', salt, 'CUSTOMER', 'Cuttack', 'Cuttack', 'College Square, Buxi Lane', '753003', 20.4625, 85.8830, 1],
    ['Meera Rath', 'meera@demo.local', '9876543213', salt, 'CUSTOMER', 'Puri', 'Puri', 'VIP Road, Puri', '752001', 19.8135, 85.8312, 1],
    ['Vikram Sahoo', 'vikram@demo.local', '9876543214', salt, 'CUSTOMER', 'Khordha', 'Bhubaneswar', 'Nayapalli, Niladri Vihar Society', '751012', 20.2850, 85.8020, 1],
    ['Sunita Tripathy', 'sunita@demo.local', '9876543215', salt, 'CUSTOMER', 'Khordha', 'Bhubaneswar', 'Saheed Nagar, Plot 110', '751007', 20.2870, 85.8450, 1],
    ['Rohit Patnaik', 'rohit@demo.local', '9876543216', salt, 'CUSTOMER', 'Khordha', 'Bhubaneswar', 'Chandrasekharpur, HIG-44', '751016', 20.3350, 85.8100, 1],
    ['Sneha Mishra', 'sneha@demo.local', '9876543217', salt, 'CUSTOMER', 'Khordha', 'Bhubaneswar', 'Khandagiri Enclave, Plot 18', '751030', 20.2570, 85.7750, 1],
    ['Manas Ranjan Behera', 'manas@demo.local', '9876543218', salt, 'CUSTOMER', 'Cuttack', 'Cuttack', 'Badambadi Colony, House 14', '753012', 20.4550, 85.8750, 1],
    ['Swati Samantaray', 'swati@demo.local', '9876543219', salt, 'CUSTOMER', 'Cuttack', 'Cuttack', 'CDA Sector 9, Plot 520', '753014', 20.4890, 85.8600, 1],
    ['Arvind Panigrahi', 'arvind@demo.local', '9876543220', salt, 'CUSTOMER', 'Puri', 'Puri', 'Grand Road, Near Temple Gate', '752001', 19.8050, 85.8200, 1],
    ['Deepa Acharya', 'deepa@demo.local', '9876543221', salt, 'CUSTOMER', 'Puri', 'Puri', 'Sea Beach Road, Blue Wave Apt', '752002', 19.7950, 85.8250, 1],
    ['Rajesh Mohapatra', 'rajesh@demo.local', '9876543222', salt, 'CUSTOMER', 'Khordha', 'Bhubaneswar', 'Infocity Avenue, Cyber City', '751024', 20.3580, 85.8150, 1],
    ['Pooja Nayak', 'pooja@demo.local', '9876543223', salt, 'CUSTOMER', 'Khordha', 'Bhubaneswar', 'Rasulgarh Square, Krishna Tower', '751010', 20.3090, 85.8520, 1],
    ['Alok Sundaray', 'alok@demo.local', '9876543224', salt, 'CUSTOMER', 'Khordha', 'Bhubaneswar', 'VSS Nagar, Phase-2', '751007', 20.2950, 85.8360, 1],
    ['Kavita Jena', 'kavita@demo.local', '9876543225', salt, 'CUSTOMER', 'Cuttack', 'Cuttack', 'Buxi Bazar, Muslim Sahi', '753001', 20.4610, 85.8810, 1],
    ['Subhashree Rout', 'subhashree@demo.local', '9876543226', salt, 'CUSTOMER', 'Cuttack', 'Cuttack', 'Cantonment Road, Officer Colony', '753001', 20.4730, 85.8920, 1],
    ['Vandana Das', 'vandana@demo.local', '9876543227', salt, 'CUSTOMER', 'Sundargarh', 'Rourkela', 'Civil Township, Area 7', '769004', 22.2492, 84.8828, 1],
    ['Pradeep Kumar Sahu', 'pradeep@demo.local', '9876543228', salt, 'CUSTOMER', 'Sundargarh', 'Rourkela', 'Sector 4, Market Complex', '769002', 22.2580, 84.8650, 1],
    ['Geetanjali Swain', 'geetanjali@demo.local', '9876543229', salt, 'CUSTOMER', 'Sundargarh', 'Rourkela', 'Koel Nagar, C Block', '769014', 22.2610, 84.8950, 1],
    ['Ashish Barik', 'ashish@demo.local', '9876543230', salt, 'CUSTOMER', 'Sambalpur', 'Sambalpur', 'Budharaja, Main Road', '768004', 21.4669, 83.9812, 1],
    ['Madhumita Padhi', 'madhumita@demo.local', '9876543231', salt, 'CUSTOMER', 'Sambalpur', 'Sambalpur', 'Khetrajpur Station Area', '768003', 21.4820, 83.9650, 1],
    ['Debasis Pradhan', 'debasis@demo.local', '9876543232', salt, 'CUSTOMER', 'Ganjam', 'Berhampur', 'Gopalpur Road, Lotus Enclave', '760010', 19.3150, 84.7941, 1],
    ['Trupti Mayee Sahoo', 'trupti@demo.local', '9876543233', salt, 'CUSTOMER', 'Ganjam', 'Berhampur', 'Gandhi Nagar, 3rd Lane', '760001', 19.3110, 84.7890, 1],
    ['Tanmay Rath', 'tanmay@demo.local', '9876543234', salt, 'CUSTOMER', 'Khordha', 'Bhubaneswar', 'Sundarpada, Hi-Tech Plaza', '751002', 20.2450, 85.8200, 1],

    // ── 38 Workers (User IDs 26-63) ──
    // AC & Appliance Technicians (IDs 26-31)
    ['Rajendra Mohapatra (Master HVAC & Inverter Specialist)', 'rajendra.w@demo.local', '9876543301', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Baramunda, Bhubaneswar', '751003', 20.2750, 85.8100, 1],
    ['Dilip Barik (AC Installation & Ducting Tech)', 'dilip.w@demo.local', '9876543302', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Aiginia, Bhubaneswar', '751019', 20.2650, 85.8450, 1],
    ['Kailash Sahoo (Certified AC Gas Refill & Leak Expert)', 'kailash.w@demo.local', '9876543303', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Chandrasekharpur, Bhubaneswar', '751016', 20.3370, 85.8150, 1],
    ['Bhabani Shankar (Appliance & Refrigerator Repairer)', 'bhabani.w@demo.local', '9876543304', salt, 'WORKER', 'Cuttack', 'Cuttack', 'Mahanadi Vihar, Cuttack', '753004', 20.4720, 85.9050, 1],
    ['Hemant Swain (Window & Split AC Servicing)', 'hemant.w@demo.local', '9876543305', salt, 'WORKER', 'Puri', 'Puri', 'Penthakata, Puri', '752002', 19.8020, 85.8350, 1],
    ['Satyajit Mohanty (Microwave & Kitchen Appliance Tech)', 'satyajit.w@demo.local', '9876543306', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Patia, Bhubaneswar', '751024', 20.3520, 85.8190, 1],

    // Electrical Artisans (IDs 32-37)
    ['Ramesh Kumar (Master Electrician)', 'ramesh.w@demo.local', '9876543307', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Rasulgarh, Bhubaneswar', '751010', 20.3095, 85.8530, 1],
    ['Suresh Behera (Gold Electrician - Inverter & Solar)', 'suresh.w@demo.local', '9876543308', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Mancheswar, Bhubaneswar', '751017', 20.3240, 85.8380, 1],
    ['Prakash Jena (Apprentice Electrician)', 'prakash.w@demo.local', '9876543309', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Madhupatna, Bhubaneswar', '751024', 20.3540, 85.8170, 1],
    ['Akshaya Muduli (Smart Home & Lighting Electrician)', 'akshaya.w@demo.local', '9876543310', salt, 'WORKER', 'Cuttack', 'Cuttack', 'Buxi Bazar, Cuttack', '753001', 20.4630, 85.8820, 1],
    ['Naveen Jena (EV Charger & 3-Phase Panel Tech)', 'naveen.w@demo.local', '9876543311', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Jaydev Vihar, Bhubaneswar', '751013', 20.2980, 85.8230, 1],
    ['Bishnu Charan Das (Senior Industrial Electrician)', 'bishnu.w@demo.local', '9876543312', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Infocity, Bhubaneswar', '751024', 20.3490, 85.8210, 1],

    // Plumbing Artisans (IDs 38-43)
    ['Ganesh Pradhan (Master Plumber - Pumps & Concealed)', 'ganesh.w@demo.local', '9876543313', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Chandrasekharpur, Bhubaneswar', '751016', 20.3350, 85.8100, 1],
    ['Santosh Mishra (Master Plumber - Drainage & Sewerage)', 'santosh.w@demo.local', '9876543314', salt, 'WORKER', 'Cuttack', 'Cuttack', 'Bidanasi, Cuttack', '753014', 20.4890, 85.8770, 1],
    ['Kishore Mahapatra (Sanitary Ware & Geyser Plumber)', 'kishore.w@demo.local', '9876543315', salt, 'WORKER', 'Cuttack', 'Cuttack', 'Link Road, Cuttack', '753012', 20.4700, 85.8800, 1],
    ['Ajay Sahu (Water Tank & Tap Leak Specialist)', 'ajay.w@demo.local', '9876543316', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Saheed Nagar, Bhubaneswar', '751007', 20.2880, 85.8420, 1],
    ['Biswajit Das (High-Pressure Piping & Irrigation)', 'biswajit.w@demo.local', '9876543317', salt, 'WORKER', 'Puri', 'Puri', 'Grand Road, Puri', '752001', 19.8080, 85.8240, 1],
    ['Purna Chandra Palei (Emergency Burst Containment)', 'purna.w@demo.local', '9876543318', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Nayapalli, Bhubaneswar', '751012', 20.2840, 85.8050, 1],

    // Carpentry Artisans (IDs 44-48)
    ['Mohan Nayak (Silver Carpenter - Modular Kitchens)', 'mohan.w@demo.local', '9876543319', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Saheed Nagar, Bhubaneswar', '751007', 20.2870, 85.8450, 1],
    ['Tapan Sethi (Carpenter & Flatpack Furniture Pro)', 'tapan.w@demo.local', '9876543320', salt, 'WORKER', 'Cuttack', 'Cuttack', 'Tulsipur, Cuttack', '753008', 20.4650, 85.8880, 1],
    ['Dipti Ranjan (Locksmith & Security Door Specialist)', 'dipti.w@demo.local', '9876543321', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Khandagiri, Bhubaneswar', '751030', 20.2590, 85.7780, 1],
    ['Pradipta Rout (Wood Finishing & PU Polish Master)', 'pradipta.w@demo.local', '9876543322', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'VSS Nagar, Bhubaneswar', '751007', 20.2930, 85.8340, 1],
    ['Kartik Nayak (Window Mesh & Frame Carpenter)', 'kartik.w@demo.local', '9876543323', salt, 'WORKER', 'Puri', 'Puri', 'Loknath Road, Puri', '752001', 19.7990, 85.8150, 1],

    // Painting & Waterproofing (IDs 49-52)
    ['Biju Sahu (Gold Painter - Interior Emulsion)', 'biju.w@demo.local', '9876543324', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Khandagiri, Bhubaneswar', '751030', 20.2570, 85.7750, 1],
    ['Subash Naik (Waterproofing & Terrace Coating Expert)', 'subash.w@demo.local', '9876543325', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Dumduma, Bhubaneswar', '751019', 20.2730, 85.8380, 1],
    ['Ranjan Khatua (Exterior Weathercoat & Texture Artist)', 'ranjan.w@demo.local', '9876543326', salt, 'WORKER', 'Cuttack', 'Cuttack', 'Badambadi, Cuttack', '753012', 20.4580, 85.8720, 1],
    ['Bijay Das (Wall Putty & Primer Finishing Pro)', 'bijay.w@demo.local', '9876543327', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Patia, Bhubaneswar', '751024', 20.3550, 85.8160, 1],

    // Cleaning & Pest Control (IDs 53-56)
    ['Narayan Rout (Deep Cleaning & Sanitization Pro)', 'narayan.w@demo.local', '9876543328', salt, 'WORKER', 'Puri', 'Puri', 'Sipasarubali, Puri', '752002', 19.8100, 85.8380, 1],
    ['Laxman Biswal (Kitchen & Bathroom Descaling Pro)', 'laxman.w@demo.local', '9876543329', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Unit-4, Bhubaneswar', '751001', 20.2710, 85.8320, 1],
    ['Minati Barik (Sofa & Upholstery Deep Cleaner)', 'minati.w@demo.local', '9876543330', salt, 'WORKER', 'Cuttack', 'Cuttack', 'Chhatra Bazar, Cuttack', '753003', 20.4660, 85.8910, 1],
    ['Sudarshan Jena (Certified Pest & Termite Controller)', 'sudarshan.w@demo.local', '9876543331', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Nayapalli, Bhubaneswar', '751012', 20.2860, 85.8030, 1],

    // Gardening, Caregiving, Driving & Domestic (IDs 57-63)
    ['Raju Parida (Senior Landscape Gardener & Horticulturist)', 'raju.w@demo.local', '9876543332', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Nuapatna, Bhubaneswar', '751012', 20.2850, 85.8020, 1],
    ['Sanatan Behera (Terrace Garden & Drip Irrigation)', 'sanatan.w@demo.local', '9876543333', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Patia, Bhubaneswar', '751024', 20.3560, 85.8190, 1],
    ['Deepak Swain (Certified Geriatric Caregiver)', 'deepak.w@demo.local', '9876543334', salt, 'WORKER', 'Puri', 'Puri', 'Balighai, Puri', '752002', 19.8250, 85.8450, 1],
    ['Geeta Samal (Post-Operative Patient Nursing)', 'geeta.w@demo.local', '9876543335', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Jaydev Vihar, Bhubaneswar', '751013', 20.2970, 85.8260, 1],
    ['Manoj Dalai (Licensed City Chauffeur)', 'manoj.w@demo.local', '9876543336', salt, 'WORKER', 'Puri', 'Puri', 'Penthakata, Puri', '752001', 19.7980, 85.8210, 1],
    ['Pramod Mohanty (Highway & Outstation Chauffeur)', 'pramod.w@demo.local', '9876543337', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'Baramunda Bus Stand, Bhubaneswar', '751003', 20.2760, 85.8090, 1],
    ['Ashok Lenka (Domestic Assistant & Home Cleaner)', 'ashok.w@demo.local', '9876543338', salt, 'WORKER', 'Khordha', 'Bhubaneswar', 'VSS Nagar, Bhubaneswar', '751007', 20.2920, 85.8350, 1],

    // ── 3 Admins (User IDs 64-66) ──
    ['Arun Kumar Pattnaik (Federation Secretary)', 'admin@demo.local', '9876543401', salt, 'COOPERATIVE_ADMIN', 'Khordha', 'Bhubaneswar', 'Unit-8, Bhubaneswar', '751012', 20.2900, 85.8200, 1],
    ['Smt. Laxmi Devi (Cuttack Arbitrator)', 'admin2@demo.local', '9876543402', salt, 'COOPERATIVE_ADMIN', 'Cuttack', 'Cuttack', 'Buxi Bazar, Cuttack', '753001', 20.4620, 85.8830, 1],
    ['Shri Alok Mohapatra (Puri DCO & Registrar)', 'admin3@demo.local', '9876543403', salt, 'COOPERATIVE_ADMIN', 'Puri', 'Puri', 'VIP Road, Puri', '752002', 19.8120, 85.8320, 1],
  ];

  for (const u of users) {
    await query(
      `INSERT INTO users (name, email, phone, password, role, district, city, address, pincode, latitude, longitude, is_active)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)`,
      u
    );
  }

  // =============================================
  // 3. Worker Profiles (38 Workers)
  // =============================================
  // [userId, workerCode, coopId, expYears, area, lat, lng, verStatus, avail, rating, totalReviews, jobsDone, earnings, bio, tier, merit, strikes, sos, primaryTrade]
  const workerProfiles = [
    // AC & Appliance (Workers 1-6, user_ids 26-31)
    [26, 'WKR-OD-1001', 1, 12, 'Bhubaneswar', 20.2750, 85.8100, 'VERIFIED', 'AVAILABLE', 4.9, 68, 64, 235000, 'Senior HVAC master technician specializing in VRF, dual inverter ACs, PCB diagnostics & chillers.', 'MASTER', 960, 0, 0, 'Appliance Repair'],
    [27, 'WKR-OD-1002', 1, 7,  'Bhubaneswar', 20.2650, 85.8450, 'VERIFIED', 'AVAILABLE', 4.8, 44, 40, 138000, 'Expert in split AC installation, copper line brazing, vacuumization and safe uninstallation.', 'GOLD', 740, 0, 0, 'Appliance Repair'],
    [28, 'WKR-OD-1003', 1, 10, 'Bhubaneswar', 20.3370, 85.8150, 'VERIFIED', 'AVAILABLE', 4.9, 58, 55, 198000, 'Certified refrigeration expert for high-pressure nitrogen leak detection, flare nut repair & R32/R410A charging.', 'MASTER', 910, 0, 0, 'Appliance Repair'],
    [29, 'WKR-OD-1004', 2, 8,  'Cuttack',     20.4720, 85.9050, 'VERIFIED', 'AVAILABLE', 4.7, 39, 36, 112000, 'Refrigerator compressor replacement, defrost timers, washing machine drum repair & motors.', 'GOLD', 690, 0, 0, 'Appliance Repair'],
    [30, 'WKR-OD-1005', 3, 5,  'Puri',        19.8020, 85.8350, 'VERIFIED', 'AVAILABLE', 4.6, 31, 28, 78000,  'Specialist in high-pressure jet cleaning, anti-bacterial coil wash & window AC overhaul.', 'SILVER', 530, 0, 0, 'Appliance Repair'],
    [31, 'WKR-OD-1006', 1, 3,  'Bhubaneswar', 20.3520, 85.8190, 'VERIFIED', 'AVAILABLE', 4.4, 19, 17, 41000,  'Microwave magnetron replacement, kitchen chimneys, water purifiers & domestic mixer repairs.', 'BRONZE', 320, 0, 0, 'Appliance Repair'],

    // Electrical (Workers 7-12, user_ids 32-37)
    [32, 'WKR-OD-1007', 1, 10, 'Bhubaneswar', 20.3095, 85.8530, 'VERIFIED', 'AVAILABLE', 4.9, 58, 54, 185000, 'Master electrician specializing in 3-phase lines, MCB distribution panels & short circuit troubleshooting.', 'MASTER', 950, 0, 0, 'Electrical'],
    [33, 'WKR-OD-1008', 1, 6,  'Bhubaneswar', 20.3240, 85.8380, 'VERIFIED', 'AVAILABLE', 4.7, 42, 38, 115000, 'Skilled in inverter-battery setup, bypass wiring, solar rooftop connections & ceiling fan overhaul.', 'GOLD', 680, 0, 0, 'Electrical'],
    [34, 'WKR-OD-1009', 1, 2,  'Bhubaneswar', 20.3540, 85.8170, 'VERIFIED', 'AVAILABLE', 4.4, 18, 16, 38000,  'Apprentice electrician trained under ITI; switchboard fixing, modular plugs & fan installations.', 'BRONZE', 220, 0, 0, 'Electrical'],
    [35, 'WKR-OD-1010', 2, 7,  'Cuttack',     20.4630, 85.8820, 'VERIFIED', 'AVAILABLE', 4.8, 45, 42, 134000, 'Smart home automation, LED profile lighting, chandelier anchor fitting & concealed wiring.', 'GOLD', 710, 0, 0, 'Electrical'],
    [36, 'WKR-OD-1011', 1, 5,  'Bhubaneswar', 20.2980, 85.8230, 'VERIFIED', 'AVAILABLE', 4.6, 34, 31, 88000,  'EV home charging point setup, industrial plug installation & earth pit resistance optimization.', 'SILVER', 560, 0, 0, 'Electrical'],
    [37, 'WKR-OD-1012', 1, 14, 'Bhubaneswar', 20.3490, 85.8210, 'VERIFIED', 'AVAILABLE', 5.0, 72, 69, 260000, 'Senior industrial wiring master, generator changeover switch panels & transformer maintenance.', 'MASTER', 980, 0, 0, 'Electrical'],

    // Plumbing (Workers 13-18, user_ids 38-43)
    [38, 'WKR-OD-1013', 1, 12, 'Bhubaneswar', 20.3350, 85.8100, 'VERIFIED', 'AVAILABLE', 4.9, 64, 60, 210000, 'Senior master plumber with deep experience in CPVC waterlines, pressure booster pumps & diverters.', 'MASTER', 980, 0, 0, 'Plumbing'],
    [39, 'WKR-OD-1014', 2, 9,  'Cuttack',     20.4890, 85.8770, 'VERIFIED', 'AVAILABLE', 4.8, 48, 46, 161000, 'Master plumber in Cuttack specializing in underground drainage, sewer lines & acoustic leak detection.', 'MASTER', 890, 0, 0, 'Plumbing'],
    [40, 'WKR-OD-1015', 2, 6,  'Cuttack',     20.4700, 85.8800, 'VERIFIED', 'AVAILABLE', 4.6, 35, 32, 95000,  'Bathroom sanitary ware installation, EWC commodes, flush valves & storage geyser plumbing.', 'SILVER', 580, 0, 0, 'Plumbing'],
    [41, 'WKR-OD-1016', 1, 8,  'Bhubaneswar', 20.2880, 85.8420, 'VERIFIED', 'AVAILABLE', 4.8, 47, 44, 145000, 'Overhead water tank high-pressure disinfection, sludge removal & tap cartridge fixing.', 'GOLD', 750, 0, 0, 'Plumbing'],
    [42, 'WKR-OD-1017', 3, 5,  'Puri',        19.8080, 85.8240, 'VERIFIED', 'AVAILABLE', 4.5, 29, 27, 72000,  'Coastal corrosion-resistant plumbing, bathroom waterline fittings & hotel maintenance.', 'SILVER', 490, 0, 0, 'Plumbing'],
    [43, 'WKR-OD-1018', 1, 7,  'Bhubaneswar', 20.2840, 85.8050, 'VERIFIED', 'AVAILABLE', 4.8, 43, 40, 131000, 'Emergency high-pressure main line burst repair, rapid cutoff clamps & bypass waterlines.', 'GOLD', 720, 0, 0, 'Plumbing'],

    // Carpentry (Workers 19-23, user_ids 44-48)
    [44, 'WKR-OD-1019', 1, 5,  'Bhubaneswar', 20.2870, 85.8450, 'VERIFIED', 'AVAILABLE', 4.6, 32, 30, 84000,  'Professional carpenter specializing in modular kitchen cabinets, hydraulic hinges & drawers.', 'SILVER', 480, 0, 0, 'Carpentry'],
    [45, 'WKR-OD-1020', 2, 7,  'Cuttack',     20.4650, 85.8880, 'VERIFIED', 'AVAILABLE', 4.7, 41, 38, 122000, 'Flatpack furniture assembly (IKEA/Pepperfry beds, wardrobes, desks) & wood joinery.', 'GOLD', 670, 0, 0, 'Carpentry'],
    [46, 'WKR-OD-1021', 1, 8,  'Bhubaneswar', 20.2590, 85.7780, 'VERIFIED', 'AVAILABLE', 4.8, 46, 43, 139000, 'Security door mortise locks, keyless digital locks & teakwood door frame repair.', 'GOLD', 740, 0, 0, 'Carpentry'],
    [47, 'WKR-OD-1022', 1, 11, 'Bhubaneswar', 20.2930, 85.8340, 'VERIFIED', 'AVAILABLE', 4.9, 57, 53, 187000, 'Master wood finisher specializing in French spirit polish, PU clear coat & furniture antique restoration.', 'MASTER', 920, 0, 0, 'Carpentry'],
    [48, 'WKR-OD-1023', 3, 3,  'Puri',        19.7990, 85.8150, 'VERIFIED', 'AVAILABLE', 4.4, 21, 19, 44000,  'Window aluminium sliding frames, stainless steel mosquito mesh & roller wheel replacement.', 'BRONZE', 310, 0, 0, 'Carpentry'],

    // Painting & Waterproofing (Workers 24-27, user_ids 49-52)
    [49, 'WKR-OD-1024', 1, 8,  'Bhubaneswar', 20.2570, 85.7750, 'VERIFIED', 'AVAILABLE', 4.8, 46, 44, 142000, 'Expert painter for interior luxury emulsion, putty sanding & wall damp-proof coatings.', 'GOLD', 720, 0, 0, 'Painting'],
    [50, 'WKR-OD-1025', 1, 10, 'Bhubaneswar', 20.2730, 85.8380, 'VERIFIED', 'AVAILABLE', 4.9, 59, 56, 194000, 'Terrace chemical waterproofing, elastomeric membrane coating & structural crack sealing.', 'MASTER', 930, 0, 0, 'Painting'],
    [51, 'WKR-OD-1026', 2, 6,  'Cuttack',     20.4580, 85.8720, 'VERIFIED', 'AVAILABLE', 4.6, 36, 33, 98000,  'Exterior weathercoat anti-fungal painting & residential society bulk contracts.', 'SILVER', 540, 0, 0, 'Painting'],
    [52, 'WKR-OD-1027', 1, 2,  'Bhubaneswar', 20.3550, 85.8160, 'VERIFIED', 'AVAILABLE', 4.3, 15, 13, 31000,  'Surface preparation, primer coating, smooth wall putty application & crack filling.', 'BRONZE', 250, 0, 0, 'Painting'],

    // Cleaning & Pest Control (Workers 28-31, user_ids 53-56)
    [53, 'WKR-OD-1028', 3, 7,  'Puri',        19.8100, 85.8380, 'VERIFIED', 'AVAILABLE', 4.7, 43, 40, 126000, 'Hospital-grade rotary floor deep cleaning, commercial sanitization & apartment turnover.', 'GOLD', 690, 0, 0, 'Cleaning'],
    [54, 'WKR-OD-1029', 1, 5,  'Bhubaneswar', 20.2710, 85.8320, 'VERIFIED', 'AVAILABLE', 4.6, 33, 30, 86000,  'Intensive bathroom acid descaling, kitchen oil degreasing & ceramic tile buffing.', 'SILVER', 510, 0, 0, 'Cleaning'],
    [55, 'WKR-OD-1030', 2, 4,  'Cuttack',     20.4660, 85.8910, 'VERIFIED', 'AVAILABLE', 4.5, 28, 26, 68000,  'Sofa, mattress & carpet injection-extraction foam wash & sanitization.', 'SILVER', 480, 0, 0, 'Cleaning'],
    [56, 'WKR-OD-1031', 1, 9,  'Bhubaneswar', 20.2860, 85.8030, 'VERIFIED', 'AVAILABLE', 4.8, 52, 49, 162000, 'Eco-certified odorless herbal gel pest control & drill-fill termite barrier treatments.', 'MASTER', 880, 0, 0, 'Cleaning'],

    // Gardening, Caregiving, Driving & Domestic (Workers 32-38, user_ids 57-63)
    [57, 'WKR-OD-1032', 1, 7,  'Bhubaneswar', 20.2850, 85.8020, 'VERIFIED', 'AVAILABLE', 4.8, 38, 36, 94000,  'Senior landscape gardener, horticulturist & lawn maintenance specialist.', 'GOLD', 710, 0, 0, 'Gardening'],
    [58, 'WKR-OD-1033', 1, 6,  'Bhubaneswar', 20.3560, 85.8190, 'VERIFIED', 'AVAILABLE', 4.6, 32, 29, 81000,  'Terrace garden landscaping, micro drip irrigation kits & organic plant feeding.', 'SILVER', 530, 0, 0, 'Gardening'],
    [59, 'WKR-OD-1034', 3, 6,  'Puri',        19.8250, 85.8450, 'VERIFIED', 'AVAILABLE', 4.7, 36, 34, 92000,  'Certified geriatric caregiver with Red Cross first-aid credentials.', 'SILVER', 510, 0, 0, 'Caregiving'],
    [60, 'WKR-OD-1035', 1, 8,  'Bhubaneswar', 20.2970, 85.8260, 'VERIFIED', 'AVAILABLE', 4.8, 49, 46, 148000, 'Post-operative patient care, bed mobility assistance, vitals monitoring & nursing support.', 'GOLD', 760, 0, 0, 'Caregiving'],
    [61, 'WKR-OD-1036', 3, 8,  'Puri',        19.7980, 85.8210, 'VERIFIED', 'AVAILABLE', 4.6, 30, 28, 76000,  'Licensed commercial chauffeur with clean state driving record for luxury and manual cars.', 'SILVER', 460, 0, 0, 'Driving'],
    [62, 'WKR-OD-1037', 1, 10, 'Bhubaneswar', 20.2760, 85.8090, 'VERIFIED', 'AVAILABLE', 4.8, 47, 44, 137000, 'Outstation long-distance highway chauffeur with night driving credentials & mechanic skills.', 'GOLD', 730, 0, 0, 'Driving'],
    [63, 'WKR-OD-1038', 1, 5,  'Bhubaneswar', 20.2920, 85.8350, 'VERIFIED', 'AVAILABLE', 4.5, 26, 24, 60000,  'Domestic helper, home sanitation, and household management.', 'BRONZE', 290, 0, 0, 'Domestic Services'],
  ];

  for (const w of workerProfiles) {
    await query(
      `INSERT INTO workers (user_id, worker_code, cooperative_id, experience_years, service_area, latitude, longitude, verification_status, availability, rating, total_reviews, total_jobs_completed, total_earnings, bio, tier, merit_points, strike_count, sos_active, primary_trade)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19)`,
      w
    );
  }

  // =============================================
  // 4. Skills Taxonomy (45 Granular Skills)
  // =============================================
  const skills = [
    // AC & Appliance Repair (Skills 1-10)
    ['Split AC Deep Jet Service', 'Appliance Repair', 'Indoor and outdoor unit pressure jet washing and disinfection'],
    ['Split AC Installation', 'Appliance Repair', 'Mounting, copper piping, vacuuming and commissioning of split ACs'],
    ['AC Gas Leak & Refilling', 'Appliance Repair', 'Nitrogen pressure leak detection and R32/R410A gas charging'],
    ['Inverter AC PCB Diagnostics', 'Appliance Repair', 'Circuit board troubleshooting, IPM sensor and capacitor repair'],
    ['Window AC Overhaul', 'Appliance Repair', 'Comprehensive chemical fin wash and blower motor maintenance'],
    ['AC Uninstallation & Dismantling', 'Appliance Repair', 'Safe gas pump-down and dismantling of air conditioning units'],
    ['Refrigerator Compressor & Gas', 'Appliance Repair', 'Thermostat, relay switch, capillary tube and gas top-up'],
    ['Washing Machine Repair', 'Appliance Repair', 'Drum balance, inlet solenoid and drain pump maintenance'],
    ['Microwave Oven Repair', 'Appliance Repair', 'High voltage diode, magnetron and touch membrane repair'],
    ['Kitchen Chimney Degreasing', 'Appliance Repair', 'Blower wheel cleaning, oil collector and filter degreasing'],

    // Electrical (Skills 11-18)
    ['Switchboard & Socket Wiring', 'Electrical', 'Installation and repair of modular switches and power sockets'],
    ['Ceiling Fan & Exhaust Fitting', 'Electrical', 'Ceiling fan mounting, downrod balancing and capacitor fix'],
    ['MCB Distribution Board', 'Electrical', 'Distribution panel load balancing, MCB and isolator replacement'],
    ['Inverter & Battery Wiring', 'Electrical', 'Inverter setup, heavy battery cable wiring and bypass switch'],
    ['Concealed Home Wiring', 'Electrical', 'Conduit pipe pulling, earthing and complete circuit wiring'],
    ['Chandelier & Light Fixtures', 'Electrical', 'Heavy chandelier ceiling anchor drilling and decorative lighting'],
    ['EV Charger Installation', 'Electrical', 'Dedicated 16A/32A EV industrial socket and earthing line'],
    ['Emergency Short Circuit Fix', 'Emergency Services', '24/7 rapid restoration of tripped or sparking electrical lines'],

    // Plumbing (Skills 19-26)
    ['Tap & Flush Valve Leak Repair', 'Plumbing', 'Spindle, ceramic disc cartridge and teflon washer leak fixing'],
    ['Sanitary Ware & Commode Install', 'Plumbing', 'Wall-hung washbasin, EWC commode and CP fitting installation'],
    ['Water Tank Deep Cleaning', 'Plumbing', 'Pressure jet scrubbing, sludge extraction and UV chlorination'],
    ['Water Booster Pump Servicing', 'Plumbing', 'Automatic pressure switch, pump motor and impeller repair'],
    ['Concealed Pipe Leak Detection', 'Plumbing', 'Acoustic pipe leak sensing and minimal intrusion CPVC repair'],
    ['Drain & Sewer De-clogging', 'Plumbing', 'Rotary snake wire clearing and enzymatic line treatment'],
    ['Geyser Water Heater Plumbing', 'Plumbing', 'Wall bracket mount, anode replacement and element descaling'],
    ['Emergency Pipe Burst Containment', 'Emergency Services', 'High pressure burst cutoff and rapid clamp containment'],

    // Carpentry (Skills 27-31)
    ['Flatpack Furniture Assembly', 'Carpentry', 'Assembly of modular beds, wardrobes, study desks and dining sets'],
    ['Mortise & Digital Door Lock', 'Carpentry', 'Godrej brass mortise lock and keyless digital lock installation'],
    ['Modular Kitchen Hinge Align', 'Carpentry', 'Hydraulic soft-close hinge replacement and drawer track tune-up'],
    ['Custom Wood & Wardrobe Repair', 'Carpentry', 'Plywood shelf reinforcement and wooden door repair'],
    ['Window Mesh & Roller Fitting', 'Carpentry', 'Aluminium mosquito net sliding frame and roller replacement'],

    // Painting & Waterproofing (Skills 32-36)
    ['Interior Emulsion Painting', 'Painting', 'Putty sanding, primer coat and 2 coats luxury emulsion'],
    ['Terrace Chemical Waterproofing', 'Painting', 'Elastomeric PU waterproof membrane and ponding test'],
    ['Exterior Weathercoat Painting', 'Painting', 'Anti-algal weather-shield exterior coating for societies'],
    ['Wall Putty & Crack Sealing', 'Painting', 'Polymer modified crack filling and ultra-smooth sanding'],
    ['French Polish & PU Finish', 'Painting', 'Hand-rubbed spirit polish and clear polyurethane finish'],

    // Cleaning & Pest (Skills 37-41)
    ['Full Home Deep Cleaning', 'Cleaning', 'Rotary floor machine scrubbing, window and balcony wash'],
    ['Bathroom Acid Descaling', 'Cleaning', 'Hard water stain removal, grout cleaning and fixture buffing'],
    ['Kitchen Oil Degreasing', 'Cleaning', 'Caustic degreasing of tiles, platform, slab and chimney'],
    ['Sofa & Carpet Shampooing', 'Cleaning', 'Deep injection foam extraction wash for fabric sofas and rugs'],
    ['Pest & Termite Control', 'Cleaning', 'Odorless herbal gel baiting and anti-termite wall drilling'],

    // Gardening, Caregiving, Driving (Skills 42-47)
    ['Lawn Mowing & Horticulture', 'Gardening', 'Lawn aeration, hedge trimming and garden waste disposal'],
    ['Terrace Drip Irrigation', 'Gardening', 'Micro-drip tube setup, potting mix and organic fertilizer'],
    ['Geriatric Elderly Assistance', 'Caregiving', 'Bedside companionship, vitals check and mobility assistance'],
    ['Post-Operative Nursing Support', 'Caregiving', 'Wound hygiene monitoring, recovery care and physiotherapy'],
    ['Personal City Chauffeur', 'Driving', 'Licensed driving for luxury automatic and manual city cars'],
    ['Highway & Outstation Driving', 'Driving', 'Long-distance highway driving with route knowledge'],
  ];

  for (const s of skills) {
    await query(`INSERT INTO skills (name, category, description) VALUES ($1, $2, $3)`, s);
  }

  // =============================================
  // 5. Worker Skills Mapping (Worker IDs 1-38)
  // =============================================
  const workerSkills = [
    // AC & Appliance (Workers 1-6)
    [1, 1, 'EXPERT'], [1, 2, 'EXPERT'], [1, 3, 'EXPERT'], [1, 4, 'EXPERT'],
    [2, 2, 'EXPERT'], [2, 6, 'EXPERT'], [2, 1, 'INTERMEDIATE'],
    [3, 3, 'EXPERT'], [3, 1, 'EXPERT'], [3, 5, 'EXPERT'],
    [4, 7, 'EXPERT'], [4, 8, 'EXPERT'], [4, 9, 'EXPERT'],
    [5, 5, 'EXPERT'], [5, 1, 'EXPERT'], [5, 6, 'INTERMEDIATE'],
    [6, 9, 'EXPERT'], [6, 10, 'EXPERT'], [6, 8, 'INTERMEDIATE'],

    // Electrical (Workers 7-12)
    [7, 13, 'EXPERT'], [7, 11, 'EXPERT'], [7, 18, 'EXPERT'],
    [8, 14, 'EXPERT'], [8, 12, 'EXPERT'], [8, 11, 'INTERMEDIATE'],
    [9, 11, 'INTERMEDIATE'], [9, 12, 'INTERMEDIATE'],
    [10, 16, 'EXPERT'], [10, 15, 'EXPERT'], [10, 11, 'EXPERT'],
    [11, 17, 'EXPERT'], [11, 13, 'EXPERT'], [11, 14, 'INTERMEDIATE'],
    [12, 13, 'EXPERT'], [12, 15, 'EXPERT'], [12, 18, 'EXPERT'],

    // Plumbing (Workers 13-18)
    [13, 20, 'EXPERT'], [13, 22, 'EXPERT'], [13, 23, 'EXPERT'],
    [14, 24, 'EXPERT'], [14, 23, 'EXPERT'], [14, 26, 'EXPERT'],
    [15, 20, 'EXPERT'], [15, 25, 'EXPERT'], [15, 19, 'EXPERT'],
    [16, 21, 'EXPERT'], [16, 19, 'EXPERT'], [16, 20, 'INTERMEDIATE'],
    [17, 22, 'EXPERT'], [17, 20, 'EXPERT'],
    [18, 26, 'EXPERT'], [18, 19, 'EXPERT'], [18, 24, 'INTERMEDIATE'],

    // Carpentry (Workers 19-23)
    [19, 29, 'EXPERT'], [19, 30, 'EXPERT'], [19, 27, 'INTERMEDIATE'],
    [20, 27, 'EXPERT'], [20, 28, 'EXPERT'], [20, 30, 'EXPERT'],
    [21, 28, 'EXPERT'], [21, 30, 'EXPERT'],
    [22, 36, 'EXPERT'], [22, 30, 'EXPERT'],
    [23, 31, 'EXPERT'], [23, 27, 'INTERMEDIATE'],

    // Painting & Waterproofing (Workers 24-27)
    [24, 32, 'EXPERT'], [24, 35, 'EXPERT'],
    [25, 33, 'EXPERT'], [25, 34, 'EXPERT'], [25, 35, 'EXPERT'],
    [26, 34, 'EXPERT'], [26, 32, 'EXPERT'],
    [27, 35, 'INTERMEDIATE'], [27, 32, 'BEGINNER'],

    // Cleaning & Pest (Workers 28-31)
    [28, 37, 'EXPERT'], [28, 38, 'EXPERT'],
    [29, 38, 'EXPERT'], [29, 39, 'EXPERT'],
    [30, 40, 'EXPERT'], [30, 37, 'EXPERT'],
    [31, 41, 'EXPERT'], [31, 37, 'INTERMEDIATE'],

    // Gardening, Caregiving, Driving & Domestic (Workers 32-38)
    [32, 42, 'EXPERT'], [32, 43, 'INTERMEDIATE'],
    [33, 43, 'EXPERT'], [33, 42, 'EXPERT'],
    [34, 44, 'EXPERT'], [34, 45, 'INTERMEDIATE'],
    [35, 45, 'EXPERT'], [35, 44, 'EXPERT'],
    [36, 46, 'EXPERT'], [36, 47, 'INTERMEDIATE'],
    [37, 47, 'EXPERT'], [37, 46, 'EXPERT'],
    [38, 37, 'INTERMEDIATE'], [38, 39, 'INTERMEDIATE'],
  ];

  for (const ws of workerSkills) {
    await query(`INSERT INTO worker_skills (worker_id, skill_id, proficiency_level) VALUES ($1, $2, $3)`, ws);
  }

  // =============================================
  // 6. Services Catalog (47 Granular Services)
  // =============================================
  const services = [
    // ── Appliance Repair (AC & Major Appliances) (Services 1-10) ──
    ['Split AC Deep Jet Service', 'Appliance Repair', 'Indoor & outdoor coil high-pressure foam wash, fin straightening & blower antibacterial cleaning', 499, 'per_visit', 'Snowflake', 0],
    ['Split AC Installation & Mounting', 'Appliance Repair', 'Heavy-duty wall bracket mounting, precision copper line fitting, vacuuming & gas balance test', 1299, 'per_visit', 'Wrench', 1],
    ['Split AC Uninstallation & Dismantling', 'Appliance Repair', 'Refrigerant gas pump-down recovery into compressor, bracket removal & copper packing', 499, 'per_visit', 'Wrench', 0],
    ['AC Gas Leak Repair & Refilling', 'Appliance Repair', 'Nitrogen high-pressure leak testing, brazing, system vacuumization & R32/R410A gas top-up', 1899, 'per_visit', 'Wind', 1],
    ['Inverter AC PCB Diagnostics & Repair', 'Appliance Repair', 'Inverter circuit board troubleshooting, IPM sensor, capacitor & microcontroller diagnosis', 799, 'per_visit', 'Settings', 1],
    ['Window AC Comprehensive Service & Overhaul', 'Appliance Repair', 'Chemical fin spray wash, fan motor lubrication, tray descaling & filter disinfection', 449, 'per_visit', 'Snowflake', 0],
    ['Double-Door Refrigerator Cooling & Gas Charge', 'Appliance Repair', 'Compressor relay, defrost thermostat replacement, capillary tube & eco refrigerant charging', 899, 'per_visit', 'Wrench', 1],
    ['Fully-Automatic Washing Machine Repair', 'Appliance Repair', 'Drum bearing balancing, inlet water solenoid & electronic drain pump overhaul', 549, 'per_visit', 'Wrench', 0],
    ['Microwave Oven Magnetron & Touchpad Service', 'Appliance Repair', 'Magnetron emission testing, high-voltage diode replacement & membrane touch switch repair', 499, 'per_visit', 'Wrench', 0],
    ['Kitchen Chimney & Hob Deep Degreasing', 'Appliance Repair', 'Baffle filter caustic degreasing, motor carbon cleaning, blower rotor & suction check', 699, 'per_visit', 'Wrench', 0],

    // ── Electrical Services (Services 11-18) ──
    ['Switchboard & Modular Socket Repair', 'Electrical', 'Replacement of burnt switches, 16A power sockets, indicator & earthing impedance check', 199, 'per_visit', 'Zap', 0],
    ['Ceiling Fan & Exhaust Fan Installation', 'Electrical', 'Downrod anchor fitting, blade angle balancing, capacitor & bearing noise elimination', 249, 'per_visit', 'Zap', 0],
    ['Main MCB & Distribution Board Replacement', 'Electrical', 'Single/3-phase isolator upgrade, load balancing & short-circuit trip testing', 499, 'per_visit', 'Zap', 1],
    ['Inverter & Dual-Battery Setup Wiring', 'Electrical', 'Heavy gauge battery terminal cabling, changeover switch & bypass wiring', 649, 'per_visit', 'Zap', 1],
    ['Complete Room Concealed Re-wiring', 'Electrical', 'PVC conduit pipe pulling, multi-strand FRLS wire & circuit load testing', 1499, 'per_visit', 'Zap', 1],
    ['Chandelier & Decorative Lighting Fixture', 'Electrical', 'Heavy ceiling hook anchor drilling, chandelier assembly & multi-mode wiring', 599, 'per_visit', 'Zap', 0],
    ['EV Home Charger Point Installation', 'Electrical', 'Dedicated 16A/32A industrial socket, MCB protection & earthing rod install', 899, 'per_visit', 'Zap', 1],
    ['Emergency 60-Min Short-Circuit Restoration', 'Emergency Services', '24/7 priority fire-hazard short-circuit isolation & main supply restoration', 599, 'per_visit', 'AlertTriangle', 1],

    // ── Plumbing Services (Services 19-26) ──
    ['Tap, Spout & Flush Valve Leak Repair', 'Plumbing', 'Ceramic disc cartridge, spindle replacement, washer & teflon leak stop', 249, 'per_visit', 'Droplets', 0],
    ['Bathroom Sanitary Ware & Fitting Install', 'Plumbing', 'Wall-hung washbasin, EWC commode seat & diverter shower installation', 699, 'per_visit', 'Droplets', 1],
    ['Overhead Water Tank Deep Disinfection', 'Plumbing', 'Mechanical high-pressure jet wash, sediment removal & UV chlorination', 799, 'per_visit', 'Droplets', 0],
    ['Water Pressure Booster Pump Repair & Setup', 'Plumbing', 'Automatic pressure sensor switch, motor capacitor & impeller servicing', 649, 'per_visit', 'Droplets', 1],
    ['Concealed Wall Pipe Leakage Detection', 'Plumbing', 'Acoustic pipe leak detection with minimal wall intrusion & CPVC repair', 849, 'per_visit', 'Droplets', 1],
    ['Blocked Drain & Sewer Pipe De-clogging', 'Plumbing', 'Rotary mechanical snake rod clearing, grease removal & flow restoration', 499, 'per_visit', 'Droplets', 0],
    ['Geyser / Water Heater Installation & Descaling', 'Plumbing', 'Geyser wall bracket mounting, anode rod check & heating element descale', 549, 'per_visit', 'Droplets', 1],
    ['Emergency 60-Min Main Pipe Burst Containment', 'Emergency Services', 'High-pressure municipal/overhead main line burst cutoff & bypass clamp', 599, 'per_visit', 'AlertTriangle', 1],

    // ── Carpentry Services (Services 27-31) ──
    ['Flatpack Furniture Assembly', 'Carpentry', 'Bed frame, 3-door wardrobe, study desk & dining table assembly', 599, 'per_visit', 'Hammer', 0],
    ['Door Lock & Brass Mortise Handle Fitting', 'Carpentry', 'Godrej mortise lock mortising, cylinder fitting & striker plate alignment', 399, 'per_visit', 'Hammer', 0],
    ['Modular Kitchen Cabinet Hinge Alignment', 'Carpentry', 'Soft-close hydraulic hinge installation, drawer channel & shutter tuning', 349, 'per_visit', 'Hammer', 0],
    ['Custom Wooden Wardrobe / Almirah Repair', 'Carpentry', 'Plywood shelf reinforcement, slider door track & laminate re-pasting', 699, 'per_visit', 'Hammer', 1],
    ['Window Glass & Mosquito Mesh Screen Fitting', 'Carpentry', 'Aluminium sliding frame, SS wire mesh fixing & track roller replacement', 449, 'per_visit', 'Hammer', 0],

    // ── Painting & Waterproofing (Services 32-36) ──
    ['Full Interior Home Painting (Per Room)', 'Painting', 'Surface sanding, 2 coats acrylic putty, 1 coat primer & 2 coats luxury emulsion', 2499, 'per_visit', 'Paintbrush', 1],
    ['Exterior Weathercoat Anti-Fungal Painting', 'Painting', 'Power wash, anti-algal primer & silicon-enhanced exterior weather protection', 3999, 'per_visit', 'Paintbrush', 1],
    ['Terrace & Roof Chemical Waterproofing', 'Painting', 'Polyurethane fiber-reinforced waterproof elastomeric coating with 5-yr guarantee', 1999, 'per_visit', 'Paintbrush', 1],
    ['Wall Putty, Primer & Deep Crack Sealing', 'Painting', 'Crack widening, polymer seal sealant fill, fiber tape & smooth sanding', 699, 'per_visit', 'Paintbrush', 0],
    ['Wood Polish & PU Finish for Furniture', 'Painting', 'Hand-rubbed french spirit polish, PU clear coat & teak finish', 899, 'per_visit', 'Paintbrush', 1],

    // ── Cleaning & Pest Control (Services 37-41) ──
    ['Full Home Deep Cleaning (1BHK / 2BHK)', 'Cleaning', 'Hospital-grade rotary floor machine scrub, kitchen, balcony & window clean', 1499, 'per_visit', 'SprayCan', 0],
    ['Bathroom Intensive Descaling & Acid Wash', 'Cleaning', 'Hard-water scale removal, grout scrubbing, exhaust & tile shine buffing', 499, 'per_visit', 'SprayCan', 0],
    ['Kitchen Intensive Degreasing & Tile Scrub', 'Cleaning', 'Food oil splatter removal, platform polishing & chimney surface cleaning', 699, 'per_visit', 'SprayCan', 0],
    ['Sofa, Mattress & Carpet Shampooing', 'Cleaning', 'Injection-extraction deep foam wash, stain lift & hot air quick drying', 649, 'per_visit', 'SprayCan', 0],
    ['Eco-Certified Pest & Termite Control', 'Cleaning', 'Odorless herbal gel baiting, anti-termite wall perimeter barrier spray', 899, 'per_visit', 'SprayCan', 0],

    // ── Gardening, Caregiving, Driving & Domestic (Services 42-47) ──
    ['Garden Maintenance & Lawn Mowing', 'Gardening', 'Lawn edging, bush trimming, organic manure dressing & leaf disposal', 399, 'per_visit', 'Flower2', 0],
    ['Terrace Garden Setup & Drip Irrigation', 'Gardening', 'Planter box potting mix, nutrient feed & automatic micro-drip kit install', 999, 'per_visit', 'Flower2', 1],
    ['Elderly Patient Care & Daily Assistance', 'Caregiving', 'Geriatric mobility aid, vitals logging, feeding & medication assistance', 599, 'per_day', 'HeartPulse', 0],
    ['Post-Operative Patient Care & Nursing', 'Caregiving', 'Wound hygiene supervision, recovery exercises & physiotherapy coordination', 799, 'per_day', 'HeartPulse', 1],
    ['Verified Chauffeur On-Demand (8-Hour Shift)', 'Driving', 'Police-verified uniformed chauffeur for automatic and manual city vehicles', 649, 'per_day', 'Car', 0],
    ['Outstation Highway Chauffeur Service', 'Driving', 'Experienced highway driver for long-distance roundtrips with night allowance', 999, 'per_day', 'Car', 0],
  ];

  for (const s of services) {
    await query(`INSERT INTO services (name, category, description, base_price, price_unit, icon, is_complex) VALUES ($1, $2, $3, $4, $5, $6, $7)`, s);
  }

  // =============================================
  // 7. Locked Spare Parts Matrix (25 Regulated Items)
  // =============================================
  const parts = [
    // AC & Appliance
    ['Appliance Repair', 'R32 Eco-friendly AC Gas Canister (500g)', 850, 'can', 6],
    ['Appliance Repair', 'Universal AC Run Capacitor (45uF)', 380, 'piece', 6],
    ['Appliance Repair', 'Heavy Duty AC Outdoor Wall Bracket Set', 650, 'set', 24],
    ['Appliance Repair', '1/4" & 3/8" Insulated Copper Pipe Set (3m)', 950, 'set', 12],
    ['Appliance Repair', 'Universal Electronic AC Inverter PCB Board', 1450, 'piece', 12],
    ['Appliance Repair', 'Heavy Duty Refrigerator Relay & Overload Kit', 290, 'piece', 6],
    ['Appliance Repair', 'Washing Machine Heavy Duty Drain Pump Motor', 580, 'piece', 12],

    // Electrical
    ['Electrical', '16A Havells Modular MCB', 220, 'piece', 12],
    ['Electrical', 'Anchor 6A 2-Way Switch', 65, 'piece', 24],
    ['Electrical', 'Finolex 2.5 sqmm Copper Wire (10m)', 340, 'bundle', 12],
    ['Electrical', 'Orient 2.5uF Fan Capacitor', 110, 'piece', 6],
    ['Electrical', '16A Heavy Duty Industrial 3-Pin Power Plug', 180, 'piece', 12],
    ['Electrical', 'Schneider Electric 40A 30mA RCCB Shock Protector', 1250, 'piece', 24],

    // Plumbing
    ['Plumbing', 'Astral 1/2" Brass Ball Valve', 185, 'piece', 12],
    ['Plumbing', 'Supreme CPVC 1" Elbow Joint', 45, 'piece', 24],
    ['Plumbing', 'Teflon Sealing Tape (Pack of 3)', 60, 'pack', 6],
    ['Plumbing', 'SS Flexible Waste Pipe (Braided)', 160, 'piece', 12],
    ['Plumbing', 'Jaquar Half-Turn Ceramic Disc Spindle', 280, 'piece', 12],
    ['Plumbing', 'Supreme 1" Non-Return Valve (NRV)', 320, 'piece', 12],

    // Carpentry
    ['Carpentry', 'Godrej Stainless Steel Mortise Lock Set', 750, 'set', 36],
    ['Carpentry', 'Hettich Soft-Close Hydraulic Hinges (Pair)', 240, 'pair', 24],
    ['Carpentry', 'Ebco Heavy-Duty Telescopic Drawer Channel (18")', 380, 'pair', 24],

    // Painting & Waterproofing
    ['Painting', 'Asian Paints Damp-Proof Acrylic Primer (1L)', 320, 'litre', 12],
    ['Painting', 'Waterproof Wall Putty (5kg Bag)', 190, 'bag', 6],
    ['Painting', 'Dr. Fixit Fastflex 2K Waterproof Membrane (5kg)', 880, 'pack', 36],
  ];

  for (const p of parts) {
    await query(`INSERT INTO parts_catalog (trade_category, part_name, standard_price, unit, warranty_months) VALUES ($1, $2, $3, $4, $5)`, p);
  }

  // =============================================
  // 8. Certifications
  // =============================================
  const certifications = [
    [1, 'HVAC Master Technician Certificate', 'CESL India', 'CESL-ME-2013-11002', '2013-12-01', 'VERIFIED'],
    [1, 'Daikin Variable Refrigerant Certified Specialist', 'Daikin Institute', 'DKN-VRF-2019-902', '2019-04-10', 'VERIFIED'],
    [2, 'AC Installation & Pipe Brazing Safety License', 'NSDC Skill India', 'NSDC-HVAC-2018-441', '2018-06-15', 'VERIFIED'],
    [3, 'Refrigerant Handling & Environmental Safety', 'National Ozone Safety Council', 'OZN-IND-2020-112', '2020-02-20', 'VERIFIED'],
    [7, 'ITI Master Electrician Certificate', 'National ITI Bhubaneswar', 'ITI-BBSR-2014-E1024', '2014-06-15', 'VERIFIED'],
    [7, 'Electrical Safety Standard Training', 'OSEB Training Centre', 'OSEB-ST-2020-442', '2020-03-10', 'VERIFIED'],
    [8, 'Solar Rooftop & Inverter Technician', 'National Solar Energy Federation', 'MNRE-SLR-2021-309', '2021-08-11', 'VERIFIED'],
    [13, 'Master Plumber License', 'NSDC Skill India', 'NSDC-PLB-2013-3201', '2013-11-05', 'VERIFIED'],
    [14, 'Senior Underground Sewer & Drainage License', 'Cuttack Municipal Corp.', 'CMC-MPL-2015-7088', '2015-01-15', 'VERIFIED'],
    [19, 'Carpentry NTC Certification', 'NCVT', 'NCVT-CRP-2019-4102', '2019-05-12', 'VERIFIED'],
    [24, 'Painting & Weather Coating Cert.', 'NSDC Skill India', 'NSDC-PNT-2017-5034', '2017-08-22', 'VERIFIED'],
    [25, 'Structural Waterproofing & Membrane Specialist', 'Dr. Fixit Institute', 'DFX-WPR-2016-881', '2016-10-18', 'VERIFIED'],
  ];

  for (const c of certifications) {
    await query(`INSERT INTO certifications (worker_id, certification_name, issuing_organization, certificate_number, issue_date, verification_status) VALUES ($1, $2, $3, $4, $5, $6)`, c);
  }

  // =============================================
  // 9. Real-World Bookings (24 Bookings with 93-2-5 Model)
  // =============================================
  // Helper for 93-2-5 calculation
  // labour amount, partsCost, cooperativeFee (5%), platformFee (2%), totalAmount
  const testBookings = [
    // ── CASE 1: Split AC Deep Jet Service (Worker Rajendra Mohapatra & Customer Ananya Patel)
    ['BKG-2026-0001', 1, 1, null, 1, 'Khordha', 'Bhubaneswar', 'Patia, Plot 42, Near KIIT Campus', '751024', 20.3540, 85.8170, '2026-08-28', '10:00 AM', 0, 0, 0, 'ACCEPTED', 499, 0, null, 24.95, 9.98, 533.93, 'Living room AC cooling slow; arrival OTP ready.', '4821', '7193', null, null, null, 0, null, '2026-08-28T07:00:00Z'],

    // ── CASE 2: Emergency Short Circuit (Worker Ramesh Kumar)
    ['BKG-2026-0002', 2, 7, null, 18, 'Khordha', 'Bhubaneswar', 'Jaydev Vihar, Flat 302', '751013', 20.2961, 85.8245, '2026-08-28', '02:00 PM', 1, 0, 0, 'IN_PROGRESS', 599, 220, '16A Havells Modular MCB', 29.95, 11.98, 860.93, 'Emergency short-circuit restoration contained. Ready for Completion OTP.', '5932', '8401', 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=400', null, null, 0, null, '2026-08-28T07:30:00Z'],

    // ── CASE 3: Master-Apprentice Pairing (Apprentice Prakash Jena with Master Ramesh Kumar)
    ['BKG-2026-0003', 1, 9, 7, 15, 'Khordha', 'Bhubaneswar', 'Patia, Tower B-402', '751024', 20.3540, 85.8170, '2026-08-28', '04:00 PM', 0, 0, 0, 'MATCHED', 1499, 340, 'Finolex 2.5 sqmm Copper Wire', 74.95, 29.98, 1943.93, 'Heavy complete room concealed rewiring. Apprentice paired with Master Ramesh.', '6319', '2847', null, null, null, 0, null, '2026-08-28T08:00:00Z'],

    // ── CASE 4: Split AC Installation & Commissioning (Worker Dilip Barik)
    ['BKG-2026-0004', 5, 2, null, 2, 'Khordha', 'Bhubaneswar', 'Nayapalli, Niladri Vihar Society', '751012', 20.2850, 85.8020, '2026-08-29', '09:00 AM', 0, 0, 0, 'ACCEPTED', 1299, 650, 'Heavy Duty AC Outdoor Wall Bracket Set', 64.95, 25.98, 2039.93, 'New 1.5 Ton Inverter AC installation with bracket mounting.', '7741', '1952', null, null, null, 0, null, '2026-08-28T08:30:00Z'],

    // ── CASE 5: AC Gas Leak Repair & Refilling (Completed, 30-Day Guarantee Active)
    ['BKG-2026-0005', 2, 3, null, 4, 'Khordha', 'Bhubaneswar', 'Jaydev Vihar, House 12', '751013', 20.2961, 85.8245, '2026-08-27', '11:00 AM', 0, 0, 0, 'COMPLETED', 1899, 850, 'R32 Eco-friendly AC Gas Canister (500g)', 94.95, 37.98, 2881.93, 'Nitrogen leak test performed and R32 refilled. Standard 30-Day Guarantee armed.', '3842', '9156', 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=400', 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=400', '2026-09-03T11:00:00Z', 0, '2026-08-27T12:30:00Z', '2026-08-27T08:00:00Z'],

    // ── CASE 6: Overhead Water Tank Deep Disinfection (Worker Ajay Sahu)
    ['BKG-2026-0006', 7, 16, null, 21, 'Khordha', 'Bhubaneswar', 'Chandrasekharpur, HIG-44', '751016', 20.3350, 85.8100, '2026-08-26', '10:00 AM', 0, 0, 0, 'COMPLETED', 799, 0, null, 39.95, 15.98, 854.93, '1000L Sintex overhead tank pressure cleaned with UV disinfection.', '5129', '6384', 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400', 'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=400', '2026-09-02T10:00:00Z', 0, '2026-08-26T12:00:00Z', '2026-08-26T07:00:00Z'],

    // ── CASE 7: Flatpack Furniture Assembly (Worker Tapan Sethi)
    ['BKG-2026-0007', 3, 20, null, 27, 'Cuttack', 'Cuttack', 'College Square, Buxi Lane', '753003', 20.4625, 85.8830, '2026-08-26', '03:00 PM', 0, 0, 0, 'COMPLETED', 599, 0, null, 29.95, 11.98, 640.93, 'King-size engineered wood bed & 3-door wardrobe assembled.', '8204', '4719', null, null, '2026-09-02T15:00:00Z', 0, '2026-08-26T17:00:00Z', '2026-08-26T11:00:00Z'],

    // ── CASE 8: Inverter AC PCB Diagnostics & Board Repair (Worker Rajendra Mohapatra)
    ['BKG-2026-0008', 6, 1, null, 5, 'Khordha', 'Bhubaneswar', 'Saheed Nagar, Plot 110', '751007', 20.2870, 85.8450, '2026-08-28', '08:00 AM', 0, 0, 0, 'IN_PROGRESS', 799, 380, 'Universal AC Run Capacitor (45uF)', 39.95, 15.98, 1234.93, 'Inverter AC E6 error code PCB repair in progress.', '1928', '3746', null, null, null, 0, null, '2026-08-28T07:15:00Z'],

    // ── CASE 9: Full Home Deep Cleaning (Worker Narayan Rout)
    ['BKG-2026-0009', 4, 28, null, 37, 'Puri', 'Puri', 'VIP Road, Puri', '752001', 19.8135, 85.8312, '2026-08-25', '01:00 PM', 0, 0, 0, 'COMPLETED', 1499, 0, null, 74.95, 29.98, 1603.93, '2BHK vacation home deep sanitization and floor scrub completed.', '9012', '4581', 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=400', 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=400', '2026-09-01T13:00:00Z', 0, '2026-08-25T15:00:00Z', '2026-08-25T09:00:00Z'],

    // ── CASE 10: Broadcast Dispatch Pool - AC Deep Jet Service (First-to-Accept)
    ['BKG-2026-0010', 8, null, null, 1, 'Khordha', 'Bhubaneswar', 'Khandagiri Enclave, Plot 18', '751030', 20.2570, 85.7750, '2026-08-28', '05:00 PM', 0, 0, 0, 'REQUESTED', 499, 0, null, 24.95, 9.98, 533.93, 'Split AC jet cleaning requested by citizen. Broadcast alert active.', '3491', '8120', null, null, null, 0, null, '2026-08-28T09:00:00Z'],

    // ── CASE 11: Broadcast Dispatch Pool - AC Gas Refill & Leak Test (First-to-Accept)
    ['BKG-2026-0011', 13, null, null, 4, 'Khordha', 'Bhubaneswar', 'Infocity Avenue, Cyber City', '751024', 20.3580, 85.8150, '2026-08-28', '06:30 PM', 0, 0, 0, 'REQUESTED', 1899, 0, null, 94.95, 37.98, 2031.93, 'AC not cooling at all, suspected gas leakage. Broadcast dispatch alert.', '4192', '7731', null, null, null, 0, null, '2026-08-28T09:15:00Z'],

    // ── CASE 12: Broadcast Dispatch Pool - Emergency 60-Min Plumbing Pipe Burst
    ['BKG-2026-0012', 10, null, null, 26, 'Cuttack', 'Cuttack', 'CDA Sector 9, Plot 520', '753014', 20.4890, 85.8600, '2026-08-28', '07:00 PM', 1, 0, 0, 'REQUESTED', 599, 0, null, 29.95, 11.98, 640.93, '🚨 Emergency high-pressure bathroom main pipe burst. Immediate response needed.', '9941', '1284', null, null, null, 0, null, '2026-08-28T09:20:00Z'],
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

  // =============================================
  // 10. Payments & Form IV Invoices
  // =============================================
  const payments = [
    [5, 'TXN-DEMO-20260827-005', 2881.93, 'UPI', 'SUCCESS', '2026-08-27T12:35:00Z'],
    [6, 'TXN-DEMO-20260826-006', 854.93, 'UPI', 'SUCCESS', '2026-08-26T12:05:00Z'],
    [7, 'TXN-DEMO-20260826-007', 640.93, 'NET_BANKING', 'SUCCESS', '2026-08-26T17:10:00Z'],
    [9, 'TXN-DEMO-20260825-009', 1603.93, 'UPI', 'SUCCESS', '2026-08-25T15:10:00Z'],
  ];

  for (const p of payments) {
    await query(`INSERT INTO payments (booking_id, transaction_id, amount, payment_method, status, paid_at) VALUES ($1, $2, $3, $4, $5, $6)`, p);
  }

  const invoices = [
    [1, 'INV-2026-0001', 'Bhubaneswar Labour Cooperative Federation', 'Ananya Patel', 'Rajendra Mohapatra (Master)', 'Split AC Deep Jet Service', '2026-08-28', 499, 0, 24.95, 9.98, 533.93, 'UNPAID'],
    [2, 'INV-2026-0002', 'Bhubaneswar Labour Cooperative Federation', 'Priya Mohanty', 'Ramesh Kumar (Master)', 'Emergency 60-Min Short-Circuit', '2026-08-28', 599, 220, 29.95, 11.98, 860.93, 'UNPAID'],
    [3, 'INV-2026-0003', 'Bhubaneswar Labour Cooperative Federation', 'Ananya Patel', 'Prakash Jena (w/ Master Ramesh)', 'Complete Room Concealed Re-wiring', '2026-08-28', 1499, 340, 74.95, 29.98, 1943.93, 'UNPAID'],
    [4, 'INV-2026-0004', 'Bhubaneswar Labour Cooperative Federation', 'Vikram Sahoo', 'Dilip Barik (Gold)', 'Split AC Installation & Mounting', '2026-08-29', 1299, 650, 64.95, 25.98, 2039.93, 'UNPAID'],
    [5, 'INV-2026-0005', 'Bhubaneswar Labour Cooperative Federation', 'Priya Mohanty', 'Kailash Sahoo (Master)', 'AC Gas Leak Repair & Refilling', '2026-08-27', 1899, 850, 94.95, 37.98, 2881.93, 'PAID'],
    [6, 'INV-2026-0006', 'Bhubaneswar Labour Cooperative Federation', 'Rohit Patnaik', 'Ajay Sahu (Gold)', 'Overhead Water Tank Deep Disinfection', '2026-08-26', 799, 0, 39.95, 15.98, 854.93, 'PAID'],
    [7, 'INV-2026-0007', 'Cuttack District Labour Cooperative Society', 'Sanjay Das', 'Tapan Sethi (Gold)', 'Flatpack Furniture Assembly', '2026-08-26', 599, 0, 29.95, 11.98, 640.93, 'PAID'],
    [8, 'INV-2026-0008', 'Bhubaneswar Labour Cooperative Federation', 'Sunita Tripathy', 'Rajendra Mohapatra (Master)', 'Inverter AC PCB Diagnostics', '2026-08-28', 799, 380, 39.95, 15.98, 1234.93, 'UNPAID'],
    [9, 'INV-2026-0009', 'Puri Coastal Labour Cooperative', 'Meera Rath', 'Narayan Rout (Gold)', 'Full Home Deep Cleaning', '2026-08-25', 1499, 0, 74.95, 29.98, 1603.93, 'PAID'],
    [10, 'INV-2026-0010', 'Bhubaneswar Labour Cooperative Federation', 'Sneha Mishra', 'Assigned Cooperative Artisan', 'Split AC Deep Jet Service', '2026-08-28', 499, 0, 24.95, 9.98, 533.93, 'UNPAID'],
  ];

  for (const inv of invoices) {
    await query(`INSERT INTO invoices (booking_id, invoice_number, cooperative_name, customer_name, worker_name, service_name, service_date, amount, parts_cost, cooperative_fee, platform_fee, total_amount, payment_status) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)`, inv);
  }

  // =============================================
  // 11. Reviews & Appliance Lineages
  // =============================================
  const reviews = [
    [5, 2, 3, 5, 'Kailash bhai detected the micro flare leak with nitrogen and recharged R32 gas. AC cooling like brand new!', 5, 5, 5, 'Thank you! Remember to keep the outdoor unit unobstructed.'],
    [6, 7, 16, 5, 'Ajay cleared all the sedimentation and disinfected our 1000L tank. Water pressure is superb now.', 5, 5, 5, 'Always glad to serve Chandrasekharpur.'],
    [7, 3, 20, 5, 'Tapan arrived right on time and assembled the 3-door wardrobe with high precision.', 5, 5, 5, 'Thank you sir for supporting cooperative artisans.'],
    [9, 4, 28, 5, 'Narayan and his team made the sea-facing apartment spotless before our family vacation.', 5, 5, 5, 'Puri Coastal Labour Cooperative is at your service.'],
  ];

  for (const r of reviews) {
    await query(`INSERT INTO reviews (booking_id, customer_id, worker_id, rating, comment, punctuality_score, quality_score, safety_score, worker_reply) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`, r);
  }

  const lineage = [
    [2, 'Split Air Conditioner (Living Room)', 'Daikin 1.5 Ton Inverter', 'SN-DK-2022-4410', '2026-08-27', 'Nitrogen leak test, flare nut brazed & R32 refrigerant refilled.', 'Kailash Sahoo (Certified AC Gas Expert)', 5, '2027-02-27'],
    [7, 'Overhead Water Storage Tank', 'Sintex Triple Layer 1000L', 'SN-SN-2021-9921', '2026-08-26', 'Mechanical high-pressure wash and UV chlorination completed.', 'Ajay Sahu (Water Tank Specialist)', 6, '2027-02-26'],
    [1, 'Main Electrical Distribution Board', 'Havells 8-Way Modular Box', 'SN-HV-2023-8821', '2026-08-26', 'Installed 16A C-Curve MCB with earthing test.', 'Ramesh Kumar (Master Artisan)', 2, '2027-08-26'],
  ];

  for (const l of lineage) {
    await query(`INSERT INTO appliance_lineage (customer_id, appliance_type, brand_model, serial_number, last_service_date, service_summary, technician_name, booking_id, warranty_until) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`, l);
  }

  // =============================================
  // 12. Welfare Records
  // =============================================
  const welfare = [
    [1, 'Insurance', 'ESIC Group Accident Insurance', 'ESIC National Council', 'ENROLLED', '2024-01-15', '₹2,00,000 accidental coverage + disability income protection'],
    [1, 'Health', 'Cooperative Health Support & Annual Checkup', 'Cooperative Labour Welfare Fund', 'ENROLLED', '2024-01-15', 'Annual full-body checkup + family diagnostics assistance'],
    [1, 'Training', 'NSDC Advanced Inverter HVAC Refrigeration', 'NSDC / National ITI Network', 'ENROLLED', '2024-06-01', 'Certified advanced 2-week inverter AC diagnostics module'],
    [7, 'Insurance', 'ESIC Group Accident Insurance', 'ESIC National Council', 'ENROLLED', '2024-02-10', 'Covered under ESIC accident insurance scheme'],
    [7, 'Pension', 'EPFO Social Security & Pension Corpus', 'EPFO India', 'ENROLLED', '2024-02-10', 'Monthly cooperative retirement fund contribution active'],
  ];

  for (const w of welfare) {
    await query(`INSERT INTO worker_welfare (worker_id, benefit_type, benefit_name, provider, status, enrollment_date, details) VALUES ($1, $2, $3, $4, $5, $6, $7)`, w);
  }

  // =============================================
  // 13. Societies & Legal Formation Roster (Pages 1 & 2)
  // =============================================
  const societiesSeed = [
    [
      'SOC-OD-2024-001',
      'Shramik Kalyan National Labour Cooperative Samiti',
      'ACTIVE',
      'REG-NL-2024-8891',
      'shramik.kalyan@coop.gov.in',
      '0674-2548891',
      'Khordha',
      'Bhubaneswar',
      'Plot 45, Master Canteen Square, Bhubaneswar',
      '751001',
      'Empowering multi-trade skilled artisans under national cooperative guidelines with fair wage distribution and health safety nets.',
      1, // is_nlcf_affiliated = 1 (YES)
      'NLCF-CERT-2024-4412',
      '2024-03-15',
      'Khordha District Cooperative Office',
      'Shri Debendra Nayak (DCO)',
      1, // dco_linked = 1
      1, // ncct_training_completed = 1
      1, // ministry_recognized = 1
      850000.0, // initial_capital_balance
      'COOP-9988112233',
      'Apex State Cooperative Bank, Bhubaneswar Main',
      'OSCB0001002',
      'HALF_YEARLY',
      9, // timeline_stage = 9 (Approved & Certified)
      'SS-SOC-2024-001',
      24,
    ],
    [
      'SOC-OD-2024-002',
      'Utkal Shilpi Seva Sahakari Samiti',
      'ACTIVE',
      'REG-OD-2024-6623',
      'utkal.shilpi@coop.gov.in',
      '0671-2316623',
      'Cuttack',
      'Cuttack',
      'Badambadi Colony, Cuttack',
      '753012',
      'Dedicated cooperative society representing plumbing, electrical, and carpentry artisans across Cuttack district.',
      0, // is_nlcf_affiliated = 0
      null,
      null,
      'Cuttack District Cooperative Office',
      'Smt. Mamata Panda (DCO)',
      1,
      0,
      1,
      420000.0,
      'COOP-4455667788',
      'Cuttack Central Cooperative Bank',
      'CCCB0002004',
      'QUARTERLY',
      9,
      'SS-SOC-2024-002',
      18,
    ],
    [
      'SOC-OD-2026-003',
      'Jagannath Nirman Sahakari Federation',
      'DCO_REVIEW',
      null,
      'jagannath.nirman@coop.gov.in',
      '06752-224411',
      'Puri',
      'Puri',
      'VIP Road, Near Bus Stand, Puri',
      '752002',
      'Newly formed cooperative society for construction, electrical, and plumbing artisans in coastal pilgrimage areas.',
      0,
      null,
      null,
      'Puri District Cooperative Office',
      'Shri Alok Mohapatra (DCO)',
      0,
      0,
      0,
      25000.0,
      'COOP-1122334455',
      'Puri Urban Cooperative Bank',
      'PUCB0003001',
      'QUARTERLY',
      7,
      'SS-SOC-2026-9812',
      12,
    ],
  ];

  for (const s of societiesSeed) {
    await query(
      `INSERT INTO societies (
        society_code, name, status, registration_number, registered_email, registered_phone,
        district, city, address, pincode, objectives, is_nlcf_affiliated, nlcf_certificate_no,
        nlcf_affiliation_date, dco_office_name, dco_officer_name, dco_linked, ncct_training_completed,
        ministry_recognized, initial_capital_balance, bank_account_no, cooperative_bank_name,
        bank_ifsc, audit_frequency, timeline_stage, tracking_id, total_workers_count
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27)`,
      s
    );
  }

  // =============================================
  // 14. Society 10 Founding Members
  // =============================================
  const foundingMembers = [
    [3, 'Bibhuti Bhusan Sahoo', 'Master Electrician', 'Plot 12, VIP Road, Puri', '9861001101', '****-****-4411', 'PRESIDENT', 1],
    [3, 'Subhashree Mohanty', 'Cooperative Accountancy Specialist', 'Lane 4, Grand Road, Puri', '9861001102', '****-****-4412', 'SECRETARY', 1],
    [3, 'Prafulla Kumar Jena', 'Senior Master Plumber', 'Station Road, Puri', '9861001103', '****-****-4413', 'TREASURER', 1],
    [3, 'Girish Chandra Dash', 'Senior Carpenter & Wood Art', 'Balighai, Puri', '9861001104', '****-****-4414', 'MEMBER', 1],
    [3, 'Jayanti Pradhan', 'Appliance Technician', 'Kumarpada, Puri', '9861001105', '****-****-4415', 'MEMBER', 1],
    [3, 'Manoranjan Behera', 'Industrial Mason & Builder', 'Talabania, Puri', '9861001106', '****-****-4416', 'MEMBER', 1],
    [3, 'Sasmita Sahoo', 'Decorative Painter & Finisher', 'Chakratirtha Road, Puri', '9861001107', '****-****-4417', 'MEMBER', 1],
    [3, 'Tuna Barik', 'Sanitary & Waste Pipe Specialist', 'Loknath Road, Puri', '9861001108', '****-****-4418', 'MEMBER', 1],
    [3, 'Bikash Mohapatra', 'Solar & Battery Technician', 'Atharanala, Puri', '9861001109', '****-****-4419', 'MEMBER', 1],
    [3, 'Hemant Kumar Swain', 'HVAC Air Conditioning Mechanic', 'Penthakata, Puri', '9861001110', '****-****-4420', 'MEMBER', 1],
  ];

  for (const m of foundingMembers) {
    await query(
      `INSERT INTO society_founding_members (society_id, full_name, occupation, address, phone, aadhaar_number, role_in_society, is_signatory)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
      m
    );
  }

  // =============================================
  // 15. Statutory Documents
  // =============================================
  const statutoryDocs = [
    [3, 'APPLICATION_FORM', 'Signed Formation Application (10 Members)', 'https://gov.in/docs/app_form_signed.pdf', 'VERIFIED', 'Shri Alok Mohapatra (DCO)'],
    [3, 'MEMBER_LIST', 'Official Founding Member List & Identity Proofs', 'https://gov.in/docs/member_roster.pdf', 'VERIFIED', 'Shri Alok Mohapatra (DCO)'],
    [3, 'BYLAWS', 'Model Cooperative Bylaws (Multi-State Format)', 'https://gov.in/docs/society_bylaws.pdf', 'VERIFIED', 'Shri Alok Mohapatra (DCO)'],
    [3, 'RESOLUTION_OF_FORMATION', 'First General Body Meeting Minutes & Formation Resolution', 'https://gov.in/docs/resolution_minutes.pdf', 'VERIFIED', 'Shri Alok Mohapatra (DCO)'],
    [3, 'BANK_CERTIFICATE', 'Puri Urban Co-op Bank Balance Certificate (₹25,000)', 'https://gov.in/docs/bank_cert_25000.pdf', 'VERIFIED', 'Shri Alok Mohapatra (DCO)'],
    [3, 'AFFIDAVIT', 'Executive Non-Profit & Cooperative Principles Affidavit', 'https://gov.in/docs/affidavit_notary.pdf', 'VERIFIED', 'Shri Alok Mohapatra (DCO)'],
  ];

  for (const doc of statutoryDocs) {
    await query(
      `INSERT INTO society_statutory_documents (society_id, doc_type, document_name, document_url, verification_status, verified_by_officer)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      doc
    );
  }

  // =============================================
  // 16. NCCT Training Records
  // =============================================
  const ncctRecords = [
    ['NCCT-2024-001', 1, 7, 'Ramesh Kumar', 'Electrical', 'Advanced Solar Inverter & Smart Grid Architecture', 'NCCT Regional Institute of Management, Bhubaneswar', 'TECHNICAL', 'CERTIFIED', 2500.0, 2000.0, 500.0, 'NCCT-CERT-EL-9081', '2024-01-10', '2024-02-15'],
    ['NCCT-2024-002', 1, 13, 'Ganesh Pradhan', 'Plumbing', 'Concealed Pressure Piping & Hydrostatic Leak Diagnostics', 'NCCT Regional Institute of Management, Bhubaneswar', 'TECHNICAL', 'CERTIFIED', 2500.0, 2000.0, 500.0, 'NCCT-CERT-PL-7712', '2024-02-01', '2024-03-05'],
    ['NCCT-2024-003', 1, 1, 'Rajendra Mohapatra', 'Appliance Repair', 'VRF / Inverter HVAC Dual-Circuit Refrigeration', 'NCCT Regional Institute of Management, Bhubaneswar', 'TECHNICAL', 'CERTIFIED', 2800.0, 2200.0, 600.0, 'NCCT-CERT-HVAC-3309', '2024-03-10', '2024-04-12'],
    ['NCCT-2024-004', 2, 19, 'Mohan Nayak', 'Carpentry', 'Modular Hydraulic Fittings & Precision Joinery', 'NCCT Regional Institute of Management, Cuttack', 'TECHNICAL', 'CERTIFIED', 2200.0, 1800.0, 400.0, 'NCCT-CERT-CR-5541', '2024-04-05', '2024-05-10'],
    ['NCCT-2024-005', 1, 8, 'Suresh Behera', 'Electrical', 'Cooperative Accountancy, GST Form IV & Digital Billing', 'NCCT National Institute of Cooperative Governance', 'ACCOUNTING_GOVERNANCE', 'ENROLLED', 2000.0, 1500.0, 500.0, null, '2026-08-01', null],
  ];

  for (const n of ncctRecords) {
    await query(
      `INSERT INTO ncct_trainings (training_code, society_id, worker_id, worker_name, trade, course_name, institute_name, training_type, status, cost_per_worker, subsidy_amount, payable_by_society, certificate_no, enrolled_date, completion_date)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)`,
      n
    );
  }

  // =============================================
  // 17. Society Treasury Ledger
  // =============================================
  const treasuryLedger = [
    [1, 'TXN-TREAS-001', 'TREASURY_DEPOSIT', 500000.0, null, null, 'Initial Treasury Corpus & Member Capital Contribution', 500000.0],
    [1, 'TXN-TREAS-002', '2_PERCENT_PLATFORM_FEE', 14200.0, null, null, 'Accumulated 2% platform operations fee on completed bookings', 514200.0],
    [1, 'TXN-TREAS-003', '5_PERCENT_WELFARE_FUND', 35500.0, null, null, 'Statutory 5% PF & insurance deposit into reserve pool', 549700.0],
    [1, 'TXN-TREAS-004', 'CANCELLATION_REVENUE', 3800.0, null, null, 'Standard cooperative late cancellation forfeiture share', 553500.0],
    [1, 'TXN-TREAS-005', 'LOAN_DISBURSEMENT', -45000.0, 1, null, 'Disbursed toolkit upgrade micro-loan to 3 senior electrician members', 508500.0],
    [1, 'TXN-TREAS-006', 'LOAN_REPAYMENT', 8500.0, 1, null, 'Monthly EMI repayment received for toolkit micro-loans', 517000.0],
    [1, 'TXN-TREAS-007', 'PROJECT_FUNDS_INFLOW', 350000.0, null, 1, 'Milestone Advance received for BMC Smart City Facility Revamp Tender', 867000.0],
    [1, 'TXN-TREAS-008', 'INSURANCE_PREMIUM_OUTFLOW', -12400.0, null, null, 'Annual ESIC Group Accident & Medical policy renewal premium', 854600.0],
  ];

  for (const t of treasuryLedger) {
    await query(
      `INSERT INTO society_treasury_ledger (society_id, transaction_code, transaction_type, amount, worker_id, project_id, description, balance_after)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
      t
    );
  }

  // =============================================
  // 18. Worker Welfare & Micro-Loans Ledger
  // =============================================
  const workerWelfareSeed = [
    [1, 1, 'ESIC-POL-2024-9011', 'ESIC National Council', 'ACTIVE', 'ACC-POL-5L-8821', 500000.0, 'ACTIVE', 25000.0, 8500.0, 2200.0, '2026-09-15', 18400.0],
    [2, 1, 'ESIC-POL-2024-9012', 'ESIC National Council', 'ACTIVE', 'ACC-POL-5L-8822', 500000.0, 'ACTIVE', 15000.0, 4200.0, 1500.0, '2026-09-15', 12800.0],
    [3, 1, 'ESIC-POL-2024-9013', 'ESIC National Council', 'ACTIVE', 'ACC-POL-5L-8823', 500000.0, 'ACTIVE', 0.0, 0.0, 0.0, null, 24600.0],
    [7, 1, 'ESIC-POL-2024-9014', 'ESIC National Council', 'ACTIVE', 'ACC-POL-5L-8824', 500000.0, 'ACTIVE', 10000.0, 3100.0, 1000.0, '2026-09-20', 9500.0],
    [13, 1, 'ESIC-POL-2024-9015', 'ESIC National Council', 'ACTIVE', 'ACC-POL-5L-8825', 500000.0, 'ACTIVE', 0.0, 0.0, 0.0, null, 15400.0],
    [19, 2, 'ESIC-POL-2024-9016', 'National Insurance Co', 'ACTIVE', 'ACC-POL-5L-8826', 500000.0, 'ACTIVE', 8000.0, 5600.0, 1200.0, '2026-09-15', 4200.0],
  ];

  for (const ww of workerWelfareSeed) {
    await query(
      `INSERT INTO society_worker_welfare (
        worker_id, society_id, health_insurance_policy_no, health_insurance_provider,
        health_insurance_status, accident_policy_no, accident_coverage_amount, accident_policy_status,
        loan_sanctioned_amount, loan_balance_due, next_loan_due_amount, next_loan_due_date, mini_pf_accumulated
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)`,
      ww
    );
  }

  // =============================================
  // 19. Institutional Tenders & Bids
  // =============================================
  const tendersSeed = [
    [
      'TNDR-BMC-2026-041',
      'Bhubaneswar Smart City Public Infrastructure Electrical & Lighting Maintenance',
      'Bhubaneswar Municipal Administration (BMA)',
      'Electrical',
      'Khordha',
      850000.0,
      1, // requires_nlcf_affiliation = 1
      'AWARDED',
      1, // awarded to Shramik Kalyan Sahakari Samiti
      350000.0,
      500000.0,
      6,
      '2026-09-30',
    ],
    [
      'TNDR-ECOR-2026-108',
      'East Coast Railway Staff Quarters Sanitary & Hydro-Plumbing Overhaul',
      'East Coast Railway Division',
      'Plumbing',
      'Khordha',
      620000.0,
      1,
      'IN_PROGRESS',
      1,
      250000.0,
      370000.0,
      4,
      '2026-10-15',
    ],
    [
      'TNDR-CDA-2026-055',
      'Cuttack Development Authority Residential Complex Painting & Waterproofing',
      'Cuttack Development Authority (CDA)',
      'Painting',
      'Cuttack',
      450000.0,
      0,
      'OPEN',
      null,
      0.0,
      450000.0,
      0,
      '2026-09-25',
    ],
  ];

  for (const t of tendersSeed) {
    await query(
      `INSERT INTO institutional_tenders (
        tender_code, title, issuing_authority, category, district, estimated_value,
        requires_nlcf_affiliation, status, awarded_society_id, funds_received, due_remaining,
        allocated_workers_count, bid_submission_deadline
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)`,
      t
    );
  }

  // Update workers with society affiliations & NCCT training flags
  await query(`UPDATE workers SET society_id = 1, is_nlcf_affiliated = 1, is_ncct_certified = 1, ncct_certificate_no = 'NCCT-CERT-HVAC-3309' WHERE id = 1`);
  await query(`UPDATE workers SET society_id = 1, is_nlcf_affiliated = 1, is_ncct_certified = 0 WHERE id = 2`);
  await query(`UPDATE workers SET society_id = 1, is_nlcf_affiliated = 1, is_ncct_certified = 0 WHERE id = 3`);
  await query(`UPDATE workers SET society_id = 1, is_nlcf_affiliated = 1, is_ncct_certified = 1, ncct_certificate_no = 'NCCT-CERT-EL-9081' WHERE id = 7`);
  await query(`UPDATE workers SET society_id = 1, is_nlcf_affiliated = 1, is_ncct_certified = 0 WHERE id = 8`);
  await query(`UPDATE workers SET society_id = 1, is_nlcf_affiliated = 1, is_ncct_certified = 1, ncct_certificate_no = 'NCCT-CERT-PL-7712' WHERE id = 13`);
  await query(`UPDATE workers SET society_id = 2, is_nlcf_affiliated = 0, is_ncct_certified = 1, ncct_certificate_no = 'NCCT-CERT-CR-5541' WHERE id = 19`);

  console.log('\n✅ Database Populated Successfully: 25 Customers, 38 Multi-Trade Workers, 47 Granular Services & Complete 93-2-5 Cooperative Framework!\n');
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
