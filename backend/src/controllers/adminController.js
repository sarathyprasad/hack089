const { query } = require('../db/connection');

/**
 * GET /api/admin/dashboard
 * Aggregated administrative metrics, statistics, and cooperative analytics.
 */
async function getAdminDashboard(req, res) {
  try {
    // 1. Statistics
    const totalWorkersRes = await query('SELECT COUNT(*) as c FROM workers');
    const verifiedWorkersRes = await query("SELECT COUNT(*) as c FROM workers WHERE verification_status = 'VERIFIED'");
    const pendingWorkersRes = await query("SELECT COUNT(*) as c FROM workers WHERE verification_status = 'PENDING'");
    const rejectedWorkersRes = await query("SELECT COUNT(*) as c FROM workers WHERE verification_status = 'REJECTED'");

    const totalBookingsRes = await query('SELECT COUNT(*) as c FROM bookings');
    const activeJobsRes = await query("SELECT COUNT(*) as c FROM bookings WHERE status IN ('REQUESTED', 'MATCHED', 'ACCEPTED', 'IN_PROGRESS')");
    const completedJobsRes = await query("SELECT COUNT(*) as c FROM bookings WHERE status = 'COMPLETED'");
    const emergencyRequestsRes = await query('SELECT COUNT(*) as c FROM bookings WHERE is_emergency = 1');

    const totalWorkers = parseInt(totalWorkersRes.rows[0].c, 10);
    const verifiedWorkers = parseInt(verifiedWorkersRes.rows[0].c, 10);
    const pendingWorkers = parseInt(pendingWorkersRes.rows[0].c, 10);
    const rejectedWorkers = parseInt(rejectedWorkersRes.rows[0].c, 10);

    const totalBookings = parseInt(totalBookingsRes.rows[0].c, 10);
    const activeJobs = parseInt(activeJobsRes.rows[0].c, 10);
    const completedJobs = parseInt(completedJobsRes.rows[0].c, 10);
    const emergencyRequests = parseInt(emergencyRequestsRes.rows[0].c, 10);

    // Worker Earnings & Welfare Pool
    const earningsRes = await query("SELECT SUM(amount) as total_earnings, SUM(cooperative_fee) as total_welfare FROM bookings WHERE status = 'COMPLETED'");
    const totalWorkerEarnings = parseFloat(earningsRes.rows[0].total_earnings || 0);
    const totalWelfareFund = parseFloat(earningsRes.rows[0].total_welfare || 0);

    // 2. Cooperative Analytics: Top Requested Services
    const topServicesRes = await query(`
      SELECT s.name, s.category, 
             COUNT(b.id) as request_count, 
             COALESCE(SUM(b.total_amount), 0) as total_revenue
      FROM services s
      LEFT JOIN bookings b ON b.service_id = s.id
      GROUP BY s.id, s.name, s.category
      ORDER BY request_count DESC
      LIMIT 6
    `);

    // 3. Service Demand by District / Region
    const demandByAreaRes = await query(`
      SELECT 
        COALESCE(location_district, 'Khordha') as area,
        COUNT(*) as total_requests,
        SUM(CASE WHEN is_emergency = 1 THEN 1 ELSE 0 END) as emergency_requests,
        SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) as completed_requests
      FROM bookings
      GROUP BY location_district
      ORDER BY total_requests DESC
    `);

    // 4. Worker Utilization & Capacity by Category
    const workerUtilizationRes = await query(`
      SELECT 
        sk.category,
        COUNT(DISTINCT w.id) as total_workers,
        SUM(CASE WHEN w.availability = 'AVAILABLE' THEN 1 ELSE 0 END) as available_workers,
        SUM(CASE WHEN w.availability = 'BUSY' THEN 1 ELSE 0 END) as busy_workers
      FROM skills sk
      JOIN worker_skills ws ON ws.skill_id = sk.id
      JOIN workers w ON ws.worker_id = w.id
      WHERE w.verification_status = 'VERIFIED'
      GROUP BY sk.category
      ORDER BY total_workers DESC
    `);

    // 5. Recent System Activity Feed
    const recentActivityRes = await query(`
      SELECT b.id, b.booking_code, b.status, b.is_emergency, b.created_at,
             s.name as service_name, u.name as customer_name
      FROM bookings b
      JOIN services s ON b.service_id = s.id
      JOIN users u ON b.customer_id = u.id
      ORDER BY b.id DESC
      LIMIT 8
    `);

    res.json({
      statistics: {
        totalWorkers,
        verifiedWorkers,
        pendingWorkers,
        rejectedWorkers,
        totalBookings,
        activeJobs,
        completedJobs,
        emergencyRequests,
        totalWorkerEarnings,
        totalWelfareFund,
      },
      analytics: {
        topServices: topServicesRes.rows,
        demandByArea: demandByAreaRes.rows,
        workerUtilization: workerUtilizationRes.rows,
        recentActivity: recentActivityRes.rows,
      },
    });
  } catch (err) {
    console.error('Admin dashboard error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to fetch admin dashboard metrics.' });
  }
}

/**
 * GET /api/admin/workers
 * List workers with full administration details and filters.
 */
async function getAdminWorkers(req, res) {
  try {
    const { status, district, search } = req.query;

    let baseQuery = `
      SELECT w.*, u.name, u.email, u.phone, u.district, u.city, u.address,
             c.name as cooperative_name, c.registration_number as cooperative_reg
      FROM workers w
      JOIN users u ON w.user_id = u.id
      JOIN cooperatives c ON w.cooperative_id = c.id
    `;

    const where = [];
    const params = [];
    let paramIdx = 1;

    if (status) {
      where.push(`w.verification_status = $${paramIdx}`);
      params.push(status);
      paramIdx++;
    }
    if (district) {
      where.push(`u.district = $${paramIdx}`);
      params.push(district);
      paramIdx++;
    }
    if (search) {
      where.push(`(u.name ILIKE $${paramIdx} OR w.worker_code ILIKE $${paramIdx + 1} OR c.name ILIKE $${paramIdx + 2})`);
      params.push(`%${search}%`, `%${search}%`, `%${search}%`);
      paramIdx += 3;
    }

    if (where.length > 0) {
      baseQuery += ' WHERE ' + where.join(' AND ');
    }

    baseQuery += ' ORDER BY w.id DESC';

    const workersRes = await query(baseQuery, params);
    const workers = workersRes.rows;

    for (const w of workers) {
      const skillsRes = await query(`
        SELECT s.name, s.category, ws.proficiency_level
        FROM worker_skills ws
        JOIN skills s ON ws.skill_id = s.id
        WHERE ws.worker_id = $1
      `, [w.id]);
      w.skills = skillsRes.rows;

      const certsRes = await query(`
        SELECT * FROM certifications WHERE worker_id = $1
      `, [w.id]);
      w.certifications = certsRes.rows;
    }

    res.json({ workers });
  } catch (err) {
    console.error('Admin get workers error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to fetch workers for admin.' });
  }
}

/**
 * PUT /api/admin/workers/:id/verify
 * Update worker verification status (VERIFIED, REJECTED, PENDING).
 */
async function verifyWorker(req, res) {
  try {
    const { status, rejectionReason } = req.body;
    const workerId = req.params.id;
    const adminId = req.user?.id || null;

    const allowed = ['VERIFIED', 'REJECTED', 'PENDING'];
    if (!allowed.includes(status)) {
      return res.status(400).json({ error: 'Validation Error', message: 'Invalid verification status.' });
    }

    const workerRes = await query('SELECT id FROM workers WHERE id = $1', [workerId]);
    if (workerRes.rowCount === 0) {
      return res.status(404).json({ error: 'Not Found', message: 'Worker not found.' });
    }

    if (status === 'VERIFIED') {
      await query(`
        UPDATE workers
        SET verification_status = 'VERIFIED',
            rejection_reason = NULL,
            availability = 'AVAILABLE',
            reviewed_by_admin_id = $1,
            reviewed_at = CURRENT_TIMESTAMP,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = $2
      `, [adminId, workerId]);

      // Also update certifications
      await query(`
        UPDATE certifications
        SET verification_status = 'VERIFIED'
        WHERE worker_id = $1
      `, [workerId]);
    } else if (status === 'REJECTED') {
      await query(`
        UPDATE workers
        SET verification_status = 'REJECTED',
            rejection_reason = $1,
            availability = 'OFFLINE',
            reviewed_by_admin_id = $2,
            reviewed_at = CURRENT_TIMESTAMP,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = $3
      `, [rejectionReason || 'Trade or KYC documents could not be verified by District Officer.', adminId, workerId]);

      await query(`
        UPDATE certifications
        SET verification_status = 'REJECTED'
        WHERE worker_id = $1
      `, [workerId]);
    } else {
      await query(`
        UPDATE workers
        SET verification_status = 'PENDING',
            updated_at = CURRENT_TIMESTAMP
        WHERE id = $1
      `, [workerId]);
    }

    res.json({
      message: `Worker application updated to ${status}`,
      status,
      rejectionReason: status === 'REJECTED' ? rejectionReason : null,
    });
  } catch (err) {
    console.error('Verify worker error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to update verification status.' });
  }
}

/**
 * GET /api/admin/bookings
 * List all bookings across the cooperative federation.
 */
async function getAdminBookings(req, res) {
  try {
    const { status, is_emergency, limit = 100 } = req.query;

    let baseQuery = `
      SELECT b.*,
             s.name as service_name, s.category as service_category,
             u_cust.name as customer_name, u_cust.phone as customer_phone,
             u_work.name as worker_name,
             w.worker_code,
             c.name as cooperative_name,
             p.status as payment_status, p.transaction_id
      FROM bookings b
      JOIN services s ON b.service_id = s.id
      JOIN users u_cust ON b.customer_id = u_cust.id
      LEFT JOIN workers w ON b.worker_id = w.id
      LEFT JOIN users u_work ON w.user_id = u_work.id
      LEFT JOIN cooperatives c ON w.cooperative_id = c.id
      LEFT JOIN payments p ON p.booking_id = b.id
    `;

    const where = [];
    const params = [];
    let paramIdx = 1;

    if (status) {
      where.push(`b.status = $${paramIdx}`);
      params.push(status);
      paramIdx++;
    }
    if (is_emergency === 'true') {
      where.push(`b.is_emergency = 1`);
    }

    if (where.length > 0) {
      baseQuery += ' WHERE ' + where.join(' AND ');
    }

    baseQuery += ` ORDER BY b.id DESC LIMIT $${paramIdx}`;
    params.push(parseInt(limit, 10));

    const bookingsRes = await query(baseQuery, params);

    res.json({ bookings: bookingsRes.rows });
  } catch (err) {
    console.error('Admin get bookings error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to fetch bookings for admin.' });
  }
}

module.exports = {
  getAdminDashboard,
  getAdminWorkers,
  verifyWorker,
  getAdminBookings,
};
