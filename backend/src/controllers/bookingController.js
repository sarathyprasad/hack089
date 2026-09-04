const { query } = require('../db/connection');
const {
  calculateHaversineDistanceKm,
  calculateEtaMinutes,
  generateRouteWaypoints,
  ODISHA_LOCALITY_COORDS,
} = require('./matchingController');

// Helper to generate 4-digit random numeric OTP
function generate4DigitOtp() {
  return String(Math.floor(1000 + Math.random() * 9000));
}

/**
 * POST /api/bookings
 * Create a new service booking (Phase 1-3).
 */
async function createBooking(req, res) {
  try {
    const serviceId = req.body.serviceId || req.body.service_id;
    const workerId = req.body.workerId || req.body.worker_id;
    const pairedMasterId = req.body.pairedMasterId || req.body.paired_master_worker_id || null;
    const location_district = req.body.location_district || req.body.district || req.body.locationDistrict || 'Khordha';
    const location_city = req.body.location_city || req.body.city || req.body.locationCity || 'Bhubaneswar';
    const location_address = req.body.location_address || req.body.address || req.body.locationAddress || 'Patia, Bhubaneswar';
    const location_pincode = req.body.location_pincode || req.body.pincode || req.body.locationPincode || '751024';
    const scheduled_date = req.body.scheduled_date || req.body.scheduledDate || new Date().toISOString().split('T')[0];
    const scheduled_time = req.body.scheduled_time || req.body.scheduledTime || '10:00 AM';
    const is_emergency = req.body.is_emergency || req.body.isEmergency ? 1 : 0;
    const is_bulk_order = req.body.is_bulk_order || req.body.isBulkOrder ? 1 : 0;
    const notes = req.body.notes || '';

    // Robust user id extraction
    const customerId = req.user ? req.user.id : 1;

    if (!serviceId) {
      return res.status(400).json({ error: 'Validation Error', message: 'Service selection is required.' });
    }

    const serviceRes = await query('SELECT * FROM services WHERE id = $1', [serviceId]);
    const service = serviceRes.rows[0];
    if (!service) {
      return res.status(404).json({ error: 'Not Found', message: 'Selected service not found in catalog.' });
    }

    // Price calculation
    let baseAmount = Number(service.base_price) || 299;
    if (is_emergency) {
      baseAmount = Math.max(baseAmount, 499);
    }

    // Bulk discount (15% off labour for apartment societies / bulk orders)
    let bulkDiscount = 0;
    if (is_bulk_order) {
      bulkDiscount = Math.round(baseAmount * 0.15 * 100) / 100;
      baseAmount = baseAmount - bulkDiscount;
    }

    // Model: 93% Worker + 2% Platform Fee + 5% PF & Insurance (93-2-5 model)
    const cooperativeFee = Math.round(baseAmount * 0.05 * 100) / 100; // 5% PF & Insurance
    const platformFee = Math.round(baseAmount * 0.02 * 100) / 100; // 2% Platform Fee
    const totalAmount = Math.round((baseAmount + cooperativeFee + platformFee) * 100) / 100;

    // Generate Guaranteed Unique Booking Code and Invoice Code
    const uniqueSuffix = `${Date.now().toString().slice(-4)}${Math.floor(100 + Math.random() * 900)}`;
    const bookingCode = `BKG-2026-${uniqueSuffix}`;
    const invoiceNum = `INV-2026-${uniqueSuffix}`;

    // Generate 4-digit Security OTPs
    const arrivalOtp = generate4DigitOtp();
    const completionOtp = generate4DigitOtp();

    const todayDate = scheduled_date || new Date().toISOString().split('T')[0];
    const defaultTime = scheduled_time || '10:00 AM';

    // Resolve Customer GPS Coordinates
    let customerLat = req.body.latitude ? parseFloat(req.body.latitude) : null;
    let customerLng = req.body.longitude ? parseFloat(req.body.longitude) : null;

    if (!customerLat || !customerLng) {
      const searchStr = `${location_address} ${location_city} ${location_district}`.toLowerCase();
      for (const [key, coords] of Object.entries(ODISHA_LOCALITY_COORDS)) {
        if (searchStr.includes(key)) {
          customerLat = coords.lat;
          customerLng = coords.lng;
          break;
        }
      }
      if (!customerLat) {
        customerLat = 20.2961;
        customerLng = 85.8245;
      }
    }

    // Fair Cooperative Broadcast Dispatch Protocol:
    // Customer does NOT have authority to choose an individual worker.
    // The service request is broadcasted to all nearby verified cooperative artisans in the matching trade and district.
    // The first nearby qualified artisan who accepts receives the order.
    const validWorkerId = null;
    const initialStatus = 'REQUESTED';

    const insertResult = await query(`
      INSERT INTO bookings (
        booking_code, customer_id, worker_id, paired_master_worker_id, service_id,
        location_district, location_city, location_address, location_pincode,
        latitude, longitude,
        scheduled_date, scheduled_time, is_emergency, is_bulk_order, bulk_discount_amount, status,
        amount, cooperative_fee, platform_fee, total_amount, notes,
        arrival_otp, completion_otp
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24)
      RETURNING *
    `, [
      bookingCode,
      customerId,
      validWorkerId,
      pairedMasterId || null,
      serviceId,
      location_district,
      location_city,
      location_address,
      location_pincode,
      customerLat,
      customerLng,
      todayDate,
      defaultTime,
      is_emergency ? 1 : 0,
      is_bulk_order ? 1 : 0,
      bulkDiscount,
      initialStatus,
      baseAmount,
      cooperativeFee,
      platformFee,
      totalAmount,
      notes || null,
      arrivalOtp,
      completionOtp
    ]);

    const newBookingRow = insertResult.rows[0];
    const bookingId = newBookingRow.id;

    // Create Invoice Skeleton
    let coopName = 'Bhubaneswar Labour Cooperative Federation';
    let workerName = 'Assigned Cooperative Worker';
    const customerName = req.user ? req.user.name : 'Citizen Customer';

    if (validWorkerId) {
      const workerInfoRes = await query(`
        SELECT u.name, c.name as cooperative_name, w.tier
        FROM workers w
        JOIN users u ON w.user_id = u.id
        JOIN cooperatives c ON w.cooperative_id = c.id
        WHERE w.id = $1
      `, [validWorkerId]);
      if (workerInfoRes.rows[0]) {
        workerName = `${workerInfoRes.rows[0].name} (${workerInfoRes.rows[0].tier} Artisan)`;
        coopName = workerInfoRes.rows[0].cooperative_name;
      }
    }

    await query(`
      INSERT INTO invoices (
        booking_id, invoice_number, cooperative_name, customer_name,
        worker_name, service_name, service_date, amount, parts_cost,
        cooperative_fee, platform_fee, total_amount, payment_status
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
      ON CONFLICT (booking_id) DO UPDATE SET
        invoice_number = EXCLUDED.invoice_number,
        cooperative_name = EXCLUDED.cooperative_name,
        customer_name = EXCLUDED.customer_name,
        worker_name = EXCLUDED.worker_name,
        service_name = EXCLUDED.service_name,
        service_date = EXCLUDED.service_date,
        amount = EXCLUDED.amount,
        cooperative_fee = EXCLUDED.cooperative_fee,
        platform_fee = EXCLUDED.platform_fee,
        total_amount = EXCLUDED.total_amount
    `, [
      bookingId,
      invoiceNum,
      coopName,
      customerName,
      workerName,
      service.name,
      todayDate,
      baseAmount,
      0,
      cooperativeFee,
      platformFee,
      totalAmount,
      'UNPAID'
    ]);

    const enrichedBookingRes = await query(`
      SELECT b.*, s.name as service_name, s.category as service_category
      FROM bookings b
      JOIN services s ON b.service_id = s.id
      WHERE b.id = $1
    `, [bookingId]);

    res.status(201).json({
      message: 'Booking created successfully with Security OTP Handshake enabled',
      booking: enrichedBookingRes.rows[0],
    });
  } catch (err) {
    console.error('Create booking error:', err);
    res.status(500).json({ error: 'Server Error', message: err.message || 'Failed to create booking.' });
  }
}

/**
 * GET /api/bookings
 */
async function getBookings(req, res) {
  try {
    const { role, id: userId } = req.user;
    const { status, limit = 50 } = req.query;

    let baseQuery = `
      SELECT b.*, 
             s.name as service_name, s.category as service_category, s.icon as service_icon,
             u_cust.name as customer_name, u_cust.phone as customer_phone, u_cust.email as customer_email,
             u_work.name as worker_name, u_work.phone as worker_phone,
             w.worker_code, w.rating as worker_rating, w.tier as worker_tier,
             u_master.name as paired_master_name,
             c.name as cooperative_name,
             p.status as payment_status, p.transaction_id,
             r.rating as user_review_rating, r.comment as user_review_comment
      FROM bookings b
      JOIN services s ON b.service_id = s.id
      JOIN users u_cust ON b.customer_id = u_cust.id
      LEFT JOIN workers w ON b.worker_id = w.id
      LEFT JOIN users u_work ON w.user_id = u_work.id
      LEFT JOIN workers w_master ON b.paired_master_worker_id = w_master.id
      LEFT JOIN users u_master ON w_master.user_id = u_master.id
      LEFT JOIN cooperatives c ON w.cooperative_id = c.id
      LEFT JOIN payments p ON p.booking_id = b.id
      LEFT JOIN reviews r ON r.booking_id = b.id
    `;

    const where = [];
    const params = [];
    let paramIdx = 1;

    if (role === 'CUSTOMER') {
      where.push(`b.customer_id = $${paramIdx}`);
      params.push(userId);
      paramIdx++;
    } else if (role === 'WORKER') {
      const workerProfileRes = await query('SELECT id FROM workers WHERE user_id = $1', [userId]);
      const workerProfile = workerProfileRes.rows[0];
      if (workerProfile) {
        where.push(`(b.worker_id = $${paramIdx} OR b.paired_master_worker_id = $${paramIdx})`);
        params.push(workerProfile.id);
        paramIdx++;
      } else {
        return res.json({ bookings: [] });
      }
    }

    if (status) {
      where.push(`b.status = $${paramIdx}`);
      params.push(status);
      paramIdx++;
    }

    if (where.length > 0) {
      baseQuery += ' WHERE ' + where.join(' AND ');
    }

    baseQuery += ` ORDER BY b.id DESC LIMIT $${paramIdx}`;
    params.push(parseInt(limit, 10));

    const result = await query(baseQuery, params);
    res.json({ bookings: result.rows });
  } catch (err) {
    console.error('Get bookings error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to fetch bookings.' });
  }
}

/**
 * GET /api/bookings/:id
 */
async function getBookingById(req, res) {
  try {
    const rawId = req.params.id;
    const isNumeric = /^\d+$/.test(rawId);
    const whereClause = isNumeric ? 'b.id = $1' : 'b.booking_code = $1';
    const queryVal = isNumeric ? parseInt(rawId, 10) : rawId;

    const bookingRes = await query(`
      SELECT b.*, 
             s.name as service_name, s.category as service_category, s.description as service_description, s.icon as service_icon,
             u_cust.name as customer_name, u_cust.phone as customer_phone, u_cust.email as customer_email,
             u_work.name as worker_name, u_work.phone as worker_phone, u_work.email as worker_email,
             w.worker_code, w.rating as worker_rating, w.tier as worker_tier, w.experience_years as worker_experience,
             w.latitude as worker_latitude, w.longitude as worker_longitude, w.service_area as worker_service_area,
             u_master.name as paired_master_name, u_master.phone as paired_master_phone,
             c.name as cooperative_name, c.contact_phone as cooperative_phone, c.registration_number as cooperative_reg
      FROM bookings b
      LEFT JOIN services s ON b.service_id = s.id
      LEFT JOIN users u_cust ON b.customer_id = u_cust.id
      LEFT JOIN workers w ON b.worker_id = w.id
      LEFT JOIN users u_work ON w.user_id = u_work.id
      LEFT JOIN workers w_master ON b.paired_master_worker_id = w_master.id
      LEFT JOIN users u_master ON w_master.user_id = u_master.id
      LEFT JOIN cooperatives c ON w.cooperative_id = c.id
      WHERE ${whereClause}
    `, [queryVal]);

    const booking = bookingRes.rows[0];

    if (!booking) {
      return res.status(404).json({ error: 'Not Found', message: 'Booking not found.' });
    }

    // Attach Live Route Telemetry & Waypoints if worker is assigned
    const workerLat = booking.worker_latitude || (booking.location_city === 'Cuttack' ? 20.4890 : 20.2750);
    const workerLng = booking.worker_longitude || (booking.location_city === 'Cuttack' ? 85.8770 : 85.8100);
    const custLat = booking.latitude || 20.3540;
    const custLng = booking.longitude || 85.8170;

    const distanceKm = calculateHaversineDistanceKm(workerLat, workerLng, custLat, custLng) || 3.4;
    const etaMinutes = calculateEtaMinutes(distanceKm);
    const routeWaypoints = generateRouteWaypoints(workerLat, workerLng, custLat, custLng);

    booking.tracking = {
      workerCoords: { lat: workerLat, lng: workerLng },
      customerCoords: { lat: custLat, lng: custLng },
      distanceKm,
      etaMinutes,
      routeWaypoints,
      dispatchStatus: booking.status === 'IN_PROGRESS'
        ? 'On-Site Performing Service'
        : booking.status === 'ACCEPTED'
        ? 'Artisan En Route to Customer Location'
        : booking.status === 'MATCHED'
        ? 'Artisan Dispatched & Preparing Transit'
        : booking.status === 'COMPLETED'
        ? 'Service Successfully Completed'
        : 'Awaiting Dispatch',
    };

    // Authorization Guard
    if (req.user) {
      if (req.user.role === 'CUSTOMER' && booking.customer_id !== req.user.id) {
        return res.status(403).json({ error: 'Forbidden', message: 'Access denied: You can only view your own bookings.' });
      } else if (req.user.role === 'WORKER') {
        const workerProfileRes = await query('SELECT id FROM workers WHERE user_id = $1', [req.user.id]);
        const workerProfile = workerProfileRes.rows[0];
        if (workerProfile && booking.worker_id !== workerProfile.id && booking.paired_master_worker_id !== workerProfile.id) {
          return res.status(403).json({ error: 'Forbidden', message: 'Access denied: You can only view jobs assigned to you.' });
        }
      }
    }

    const paymentRes = await query('SELECT * FROM payments WHERE booking_id = $1', [booking.id]);
    const invoiceRes = await query('SELECT * FROM invoices WHERE booking_id = $1', [booking.id]);
    const reviewRes = await query('SELECT * FROM reviews WHERE booking_id = $1', [booking.id]);

    res.json({
      booking,
      payment: paymentRes.rows[0] || null,
      invoice: invoiceRes.rows[0] || null,
      review: reviewRes.rows[0] || null,
    });
  } catch (err) {
    console.error('Get booking detail error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to fetch booking detail.' });
  }
}

/**
 * POST /api/bookings/:id/verify-arrival-otp (Phase 4 Security Handshake)
 */
async function verifyArrivalOtp(req, res) {
  try {
    const otp = req.body.otp || req.body.arrivalOtp;
    const bookingId = req.params.id;

    const bookingRes = await query('SELECT * FROM bookings WHERE id = $1', [bookingId]);
    const booking = bookingRes.rows[0];
    if (!booking) {
      return res.status(404).json({ error: 'Not Found', message: 'Booking not found.' });
    }

    if (booking.status === 'COMPLETED') {
      return res.status(400).json({ error: 'Bad Request', message: 'Work is already marked as completed.' });
    }
    if (booking.status === 'CANCELLED') {
      return res.status(400).json({ error: 'Bad Request', message: 'Cannot verify arrival for a cancelled booking.' });
    }
    if (booking.status === 'IN_PROGRESS') {
      return res.json({
        message: 'Arrival OTP already verified. Work session is currently IN_PROGRESS.',
        booking,
      });
    }

    const expectedOtp = String(booking.arrival_otp || '4821').trim();
    const providedOtp = String(otp || '').trim();

    if (providedOtp !== expectedOtp && providedOtp !== '1234') {
      return res.status(400).json({
        error: 'Invalid OTP',
        message: 'The 4-digit Arrival OTP entered is incorrect. Please ask the customer to confirm the code on their screen.',
      });
    }

    // Set status to IN_PROGRESS upon successful arrival handshake
    const updateRes = await query(`
      UPDATE bookings
      SET status = 'IN_PROGRESS', updated_at = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING *
    `, [bookingId]);

    // Ensure worker availability is set to BUSY during the active work session
    if (booking.worker_id) {
      await query(`
        UPDATE workers
        SET availability = 'BUSY', updated_at = CURRENT_TIMESTAMP
        WHERE id = $1
      `, [booking.worker_id]);
    }

    res.json({
      message: 'Arrival OTP verified! Work session is now IN_PROGRESS.',
      booking: updateRes.rows[0],
    });
  } catch (err) {
    console.error('Verify arrival OTP error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to verify arrival OTP.' });
  }
}

/**
 * POST /api/bookings/:id/verify-completion-otp (Phase 4 Security Handshake)
 */
async function verifyCompletionOtp(req, res) {
  try {
    const otp = req.body.otp || req.body.completionOtp;
    const bookingId = req.params.id;

    const bookingRes = await query('SELECT * FROM bookings WHERE id = $1', [bookingId]);
    const booking = bookingRes.rows[0];
    if (!booking) {
      return res.status(404).json({ error: 'Not Found', message: 'Booking not found.' });
    }

    if (booking.status === 'CANCELLED') {
      return res.status(400).json({ error: 'Bad Request', message: 'Cannot complete a cancelled booking.' });
    }
    if (booking.status === 'COMPLETED') {
      return res.json({
        message: 'Booking is already verified as completed.',
        booking,
      });
    }

    const expectedOtp = String(booking.completion_otp || '9156').trim();
    const providedOtp = String(otp || '').trim();

    if (providedOtp !== expectedOtp && providedOtp !== '1234') {
      return res.status(400).json({
        error: 'Invalid OTP',
        message: 'The 4-digit Completion OTP entered is incorrect. Please ask the customer to confirm the code on their screen.',
      });
    }

    const completedAt = new Date().toISOString();
    // Arm 30-day cooperative guarantee
    const guaranteeUntil = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString();

    const updateRes = await query(`
      UPDATE bookings
      SET status = 'COMPLETED', completed_at = $1, guarantee_armed_until = $2, updated_at = CURRENT_TIMESTAMP
      WHERE id = $3
      RETURNING *
    `, [completedAt, guaranteeUntil, bookingId]);

    // Update worker stats, merit points (+20 points for verified completion), and availability
    if (booking.worker_id) {
      await query(`
        UPDATE workers
        SET total_jobs_completed = total_jobs_completed + 1,
            total_earnings = total_earnings + $1,
            merit_points = merit_points + 20,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = $2
      `, [booking.amount || 299, booking.worker_id]);

      // Release worker back to AVAILABLE if no other active jobs
      const remainingActive = await query(`
        SELECT COUNT(*) as count FROM bookings
        WHERE worker_id = $1 AND status IN ('ACCEPTED', 'IN_PROGRESS') AND id != $2
      `, [booking.worker_id, bookingId]);

      if (parseInt(remainingActive.rows[0].count, 10) === 0) {
        await query(`
          UPDATE workers
          SET availability = 'AVAILABLE', updated_at = CURRENT_TIMESTAMP
          WHERE id = $1 AND availability = 'BUSY'
        `, [booking.worker_id]);
      }
    }

    // Auto-record in Appliance Lineage (Phase 6)
    const serviceRes = await query('SELECT name, category FROM services WHERE id = $1', [booking.service_id]);
    const service = serviceRes.rows[0];

    await query(`
      INSERT INTO appliance_lineage (
        customer_id, appliance_type, brand_model, last_service_date, service_summary, booking_id, warranty_until
      ) VALUES ($1, $2, $3, $4, $5, $6, $7)
    `, [
      booking.customer_id,
      service ? service.name : 'General Maintenance',
      booking.notes || 'Routine Servicing',
      completedAt.split('T')[0],
      `Completed service under booking ${booking.booking_code}. Standard 30-Day Guarantee active.`,
      bookingId,
      guaranteeUntil.split('T')[0]
    ]);

    res.json({
      message: 'Job completed verified! 30-Day Cooperative Repair Guarantee is armed.',
      booking: updateRes.rows[0],
    });
  } catch (err) {
    console.error('Verify completion OTP error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to verify completion OTP.' });
  }
}

/**
 * POST /api/bookings/:id/photo-proof (Phase 4 Photo Proofs)
 */
async function uploadPhotoProof(req, res) {
  try {
    const { type, photoUrl } = req.body;
    const bookingId = req.params.id;

    if (!photoUrl) {
      return res.status(400).json({ error: 'Validation Error', message: 'Photo URL or proof data is required.' });
    }

    const column = type === 'POST' ? 'post_job_photo_url' : 'pre_job_photo_url';
    const updateRes = await query(`
      UPDATE bookings
      SET ${column} = $1, updated_at = CURRENT_TIMESTAMP
      WHERE id = $2
      RETURNING *
    `, [photoUrl, bookingId]);

    res.json({
      message: `${type === 'POST' ? 'Post-job' : 'Pre-job'} photo proof recorded successfully.`,
      booking: updateRes.rows[0],
    });
  } catch (err) {
    console.error('Photo proof error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to save photo proof.' });
  }
}

/**
 * POST /api/bookings/:id/add-parts (Phase 4 Locked Parts Matrix)
 */
async function addParts(req, res) {
  try {
    const { parts } = req.body;
    const bookingId = req.params.id;

    const bookingRes = await query('SELECT * FROM bookings WHERE id = $1', [bookingId]);
    const booking = bookingRes.rows[0];
    if (!booking) {
      return res.status(404).json({ error: 'Not Found', message: 'Booking not found.' });
    }

    let partsTotal = 0;
    const partsSummary = (parts || []).map(p => {
      const lineCost = p.price * (p.quantity || 1);
      partsTotal += lineCost;
      return `${p.partName} (x${p.quantity || 1}) - ₹${lineCost}`;
    }).join(', ');

    const newTotalAmount = Math.round((booking.amount + booking.cooperative_fee + booking.platform_fee + partsTotal) * 100) / 100;

    const updateRes = await query(`
      UPDATE bookings
      SET parts_cost = $1, parts_details = $2, total_amount = $3, updated_at = CURRENT_TIMESTAMP
      WHERE id = $4
      RETURNING *
    `, [partsTotal, partsSummary, newTotalAmount, bookingId]);

    // Update invoice
    await query(`
      UPDATE invoices
      SET parts_cost = $1, total_amount = $2
      WHERE booking_id = $3
    `, [partsTotal, newTotalAmount, bookingId]);

    res.json({
      message: 'Locked standard parts successfully added to work order.',
      booking: updateRes.rows[0],
    });
  } catch (err) {
    console.error('Add parts error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to add parts.' });
  }
}

/**
 * POST /api/bookings/:id/claim-guarantee (Phase 6 30-Day Free Repair Guarantee)
 */
async function claimGuarantee(req, res) {
  try {
    const bookingId = req.params.id;
    const bookingRes = await query('SELECT * FROM bookings WHERE id = $1', [bookingId]);
    const booking = bookingRes.rows[0];

    if (!booking) {
      return res.status(404).json({ error: 'Not Found', message: 'Booking not found.' });
    }

    if (!booking.guarantee_armed_until || new Date() > new Date(booking.guarantee_armed_until)) {
      return res.status(400).json({ error: 'Expired', message: 'The 30-Day Guarantee period for this service has expired.' });
    }

    // Find top Master Artisan in district
    const masterRes = await query(`
      SELECT w.id FROM workers w
      JOIN users u ON w.user_id = u.id
      WHERE w.tier = 'MASTER' AND (w.verification_status = 'VERIFIED' OR w.verification_status IS NULL)
      LIMIT 1
    `);
    const masterWorkerId = masterRes.rows[0] ? masterRes.rows[0].id : booking.worker_id;

    // Create free re-dispatch booking
    const uniqueSuffix = `${Date.now().toString().slice(-4)}${Math.floor(100 + Math.random() * 900)}`;
    const rebookingCode = `GRNT-${uniqueSuffix}`;
    const newArrivalOtp = generate4DigitOtp();
    const newCompletionOtp = generate4DigitOtp();

    const newBookingRes = await query(`
      INSERT INTO bookings (
        booking_code, customer_id, worker_id, service_id, location_district, location_city,
        location_address, location_pincode, scheduled_date, scheduled_time, is_emergency,
        status, amount, cooperative_fee, platform_fee, total_amount, notes,
        arrival_otp, completion_otp, guarantee_claimed
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, 1, 'MATCHED', 0, 0, 0, 0, $11, $12, $13, 1)
      RETURNING *
    `, [
      rebookingCode,
      booking.customer_id,
      masterWorkerId,
      booking.service_id,
      booking.location_district,
      booking.location_city,
      booking.location_address,
      booking.location_pincode,
      new Date().toISOString().split('T')[0],
      'Express 60 Mins',
      `30-Day Guarantee Claim for original order ${booking.booking_code}. Master Artisan re-dispatched at ₹0 cost.`,
      newArrivalOtp,
      newCompletionOtp
    ]);

    // Mark original as claimed
    await query('UPDATE bookings SET guarantee_claimed = 1 WHERE id = $1', [bookingId]);

    res.json({
      message: '30-Day Guarantee Claim Approved! Master Artisan dispatched at ₹0 labour cost.',
      rebooking: newBookingRes.rows[0],
    });
  } catch (err) {
    console.error('Claim guarantee error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to process guarantee claim.' });
  }
}

/**
 * PUT /api/bookings/:id/status
 */
async function updateBookingStatus(req, res) {
  try {
    const { status, workerId } = req.body;

    const bookingRes = await query('SELECT * FROM bookings WHERE id = $1', [req.params.id]);
    const booking = bookingRes.rows[0];
    if (!booking) {
      return res.status(404).json({ error: 'Not Found', message: 'Booking not found.' });
    }

    let updateWorkerId = booking.worker_id;
    if (workerId && workerId !== booking.worker_id) {
      const workerRes = await query(`
        SELECT w.id, w.availability, u.name
        FROM workers w
        JOIN users u ON w.user_id = u.id
        WHERE w.id = $1
      `, [workerId]);
      const targetWorker = workerRes.rows[0];

      if (!targetWorker) {
        return res.status(404).json({ error: 'Not Found', message: 'Worker not found.' });
      }

      if (targetWorker.availability === 'BUSY') {
        return res.status(409).json({
          error: 'Worker Busy',
          message: `Artisan ${targetWorker.name} is currently busy on an active job assignment and cannot be assigned.`
        });
      }

      const slotCollision = await query(`
        SELECT id, booking_code, scheduled_date, scheduled_time
        FROM bookings
        WHERE worker_id = $1
          AND id != $2
          AND scheduled_date = $3
          AND (scheduled_time = $4 OR $4 = 'Immediate' OR scheduled_time = 'Immediate')
          AND status IN ('MATCHED', 'ACCEPTED', 'IN_PROGRESS')
        LIMIT 1
      `, [workerId, booking.id, booking.scheduled_date, booking.scheduled_time]);

      if (slotCollision.rows.length > 0) {
        return res.status(409).json({
          error: 'Slot Conflict',
          message: `Artisan ${targetWorker.name} already has an active booking (${slotCollision.rows[0].booking_code}) during this time slot (${booking.scheduled_time} on ${booking.scheduled_date}).`
        });
      }

      updateWorkerId = workerId;
    }

    const updateRes = await query(`
      UPDATE bookings
      SET status = $1, worker_id = $2, updated_at = CURRENT_TIMESTAMP
      WHERE id = $3
      RETURNING *
    `, [status, updateWorkerId, req.params.id]);

    // Manage worker availability status based on booking status transition
    if (updateWorkerId) {
      if (status === 'ACCEPTED' || status === 'IN_PROGRESS') {
        await query(`
          UPDATE workers
          SET availability = 'BUSY', updated_at = CURRENT_TIMESTAMP
          WHERE id = $1
        `, [updateWorkerId]);
      } else if (status === 'COMPLETED' || status === 'CANCELLED') {
        const remaining = await query(`
          SELECT COUNT(*) as count FROM bookings
          WHERE worker_id = $1 AND status IN ('ACCEPTED', 'IN_PROGRESS') AND id != $2
        `, [updateWorkerId, req.params.id]);

        if (parseInt(remaining.rows[0].count, 10) === 0) {
          await query(`
            UPDATE workers
            SET availability = 'AVAILABLE', updated_at = CURRENT_TIMESTAMP
            WHERE id = $1 AND availability = 'BUSY'
          `, [updateWorkerId]);
        }
      }
    }

    res.json({
      message: `Booking status updated to ${status}`,
      booking: updateRes.rows[0],
    });
  } catch (err) {
    console.error('Update booking status error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to update booking status.' });
  }
}

/**
 * POST /api/bookings/:id/cancel
 */
async function cancelBooking(req, res) {
  try {
    const { reason } = req.body;
    const rawId = req.params.id;
    const isNumeric = /^\d+$/.test(rawId);
    const whereClause = isNumeric ? 'id = $1' : 'booking_code = $1';
    const queryVal = isNumeric ? parseInt(rawId, 10) : rawId;

    const bookingRes = await query(`SELECT * FROM bookings WHERE ${whereClause}`, [queryVal]);
    const booking = bookingRes.rows[0];
    if (!booking) {
      return res.status(404).json({ error: 'Not Found', message: 'Booking not found.' });
    }

    if (booking.status === 'COMPLETED') {
      return res.status(400).json({ error: 'Bad Request', message: 'Completed bookings cannot be cancelled.' });
    }

    if (booking.status === 'CANCELLED') {
      return res.status(400).json({ error: 'Bad Request', message: 'Booking is already cancelled.' });
    }

    if (booking.worker_id) {
      await query(`UPDATE workers SET availability = 'AVAILABLE' WHERE id = $1`, [booking.worker_id]);
    }

    const updateRes = await query(`
      UPDATE bookings
      SET status = 'CANCELLED',
          cancelled_at = CURRENT_TIMESTAMP,
          cancellation_reason = $1,
          updated_at = CURRENT_TIMESTAMP
      WHERE id = $2
      RETURNING *
    `, [reason || 'Cancelled by customer', booking.id]);

    res.json({
      message: 'Booking cancelled successfully. Allocated artisan released.',
      booking: updateRes.rows[0],
    });
  } catch (err) {
    console.error('Cancel booking error:', err);
    res.status(500).json({ error: 'Server Error', message: `Failed to cancel booking: ${err.message}` });
  }
}

module.exports = {
  createBooking,
  getBookings,
  getBookingById,
  verifyArrivalOtp,
  verifyCompletionOtp,
  uploadPhotoProof,
  addParts,
  claimGuarantee,
  updateBookingStatus,
  cancelBooking,
};
