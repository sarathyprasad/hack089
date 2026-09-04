const { query } = require('../db/connection');

/**
 * GET /api/worker-portal/dashboard
 * Aggregated dashboard metrics for the logged-in worker.
 */
async function getWorkerDashboard(req, res) {
  try {
    const userId = req.user.id;

    // Find worker record
    const workerRes = await query(`
      SELECT w.*, u.name, u.email, u.phone, u.district, u.city, u.address, u.pincode,
             c.name as cooperative_name, c.registration_number as cooperative_reg, c.contact_phone as cooperative_phone
      FROM workers w
      JOIN users u ON w.user_id = u.id
      JOIN cooperatives c ON w.cooperative_id = c.id
      WHERE w.user_id = $1
    `, [userId]);

    const worker = workerRes.rows[0];
    if (!worker) {
      return res.status(404).json({ error: 'Not Found', message: 'Worker profile not found for this account.' });
    }

    // Worker skills
    const skillsRes = await query(`
      SELECT s.id, s.name, s.category, ws.proficiency_level
      FROM worker_skills ws
      JOIN skills s ON ws.skill_id = s.id
      WHERE ws.worker_id = $1
    `, [worker.id]);
    const skills = skillsRes.rows;

    // Worker certifications
    const certsRes = await query(`
      SELECT * FROM certifications WHERE worker_id = $1 ORDER BY issue_date DESC
    `, [worker.id]);
    const certifications = certsRes.rows;

    // Incoming requests (REQUESTED for worker's trade category and district/city, OR MATCHED to this worker)
    const incomingRes = await query(`
      SELECT b.*, s.name as service_name, s.category as service_category, s.icon as service_icon,
             u.name as customer_name, u.phone as customer_phone
      FROM bookings b
      JOIN services s ON b.service_id = s.id
      JOIN users u ON b.customer_id = u.id
      WHERE (b.worker_id = $1 AND b.status = 'MATCHED')
         OR (
              b.worker_id IS NULL 
              AND b.status = 'REQUESTED' 
              AND (b.declined_worker_ids IS NULL OR b.declined_worker_ids NOT LIKE '%,' || $1 || ',%')
              AND (
                b.location_district = $2 
                OR $2 IS NULL 
                OR b.location_district IS NULL 
                OR b.location_city = $4
              )
              AND (
                $3 = '' OR $3 IS NULL
                OR $3 ILIKE '%' || s.category || '%'
                OR s.category ILIKE '%' || $3 || '%'
                OR s.category = 'Emergency Services'
                OR EXISTS (
                  SELECT 1 FROM worker_skills ws
                  JOIN skills sk ON ws.skill_id = sk.id
                  WHERE ws.worker_id = $1
                    AND (sk.category ILIKE s.category OR s.category ILIKE '%' || sk.category || '%' OR sk.name ILIKE '%' || s.name || '%')
                )
              )
            )
      ORDER BY b.is_emergency DESC, b.id DESC
      LIMIT 15
    `, [worker.id, worker.district || 'Khordha', worker.primary_trade || '', worker.city || 'Bhubaneswar']);
    const incomingJobs = incomingRes.rows;

    // Active Jobs (ACCEPTED or IN_PROGRESS)
    const activeRes = await query(`
      SELECT b.*, s.name as service_name, s.category as service_category, s.icon as service_icon,
             u.name as customer_name, u.phone as customer_phone
      FROM bookings b
      JOIN services s ON b.service_id = s.id
      JOIN users u ON b.customer_id = u.id
      WHERE b.worker_id = $1 AND b.status IN ('ACCEPTED', 'IN_PROGRESS')
      ORDER BY b.id DESC
    `, [worker.id]);
    const activeJobs = activeRes.rows;

    // Completed Jobs
    const completedRes = await query(`
      SELECT b.*, s.name as service_name, s.category as service_category,
             u.name as customer_name,
             p.status as payment_status,
             r.rating as review_rating, r.comment as review_comment
      FROM bookings b
      JOIN services s ON b.service_id = s.id
      JOIN users u ON b.customer_id = u.id
      LEFT JOIN payments p ON p.booking_id = b.id
      LEFT JOIN reviews r ON r.booking_id = b.id
      WHERE b.worker_id = $1 AND b.status = 'COMPLETED'
      ORDER BY b.id DESC
      LIMIT 20
    `, [worker.id]);
    const completedJobs = completedRes.rows;

    // Recent reviews
    const reviewsRes = await query(`
      SELECT r.*, u.name as customer_name, b.service_id, s.name as service_name
      FROM reviews r
      JOIN users u ON r.customer_id = u.id
      JOIN bookings b ON r.booking_id = b.id
      JOIN services s ON b.service_id = s.id
      WHERE r.worker_id = $1
      ORDER BY r.created_at DESC
      LIMIT 10
    `, [worker.id]);
    const reviews = reviewsRes.rows;

    // Welfare enrolled count
    const welfareCountRes = await query(`
      SELECT COUNT(*) as count FROM worker_welfare
      WHERE worker_id = $1 AND status = 'ENROLLED'
    `, [worker.id]);
    const welfareCount = parseInt(welfareCountRes.rows[0].count, 10);

    res.json({
      worker,
      skills,
      certifications,
      stats: {
        totalEarnings: worker.total_earnings || 0,
        totalJobsCompleted: worker.total_jobs_completed || 0,
        activeJobsCount: activeJobs.length,
        incomingJobsCount: incomingJobs.length,
        rating: worker.rating || 0,
        totalReviews: worker.total_reviews || 0,
        welfareEnrolledCount: welfareCount,
      },
      incomingJobs,
      activeJobs,
      completedJobs,
      reviews,
    });
  } catch (err) {
    console.error('Worker dashboard error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to fetch worker dashboard data.' });
  }
}

/**
 * PUT /api/worker-portal/availability
 * Update worker availability status (AVAILABLE, BUSY, OFFLINE).
 */
async function updateAvailability(req, res) {
  try {
    const { availability } = req.body;
    const userId = req.user.id;

    const allowed = ['AVAILABLE', 'BUSY', 'OFFLINE'];
    if (!allowed.includes(availability)) {
      return res.status(400).json({ error: 'Validation Error', message: 'Invalid availability status.' });
    }

    await query(`
      UPDATE workers SET availability = $1, updated_at = CURRENT_TIMESTAMP
      WHERE user_id = $2
    `, [availability, userId]);

    res.json({ message: `Availability status updated to ${availability}`, availability });
  } catch (err) {
    console.error('Update availability error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to update availability.' });
  }
}

/**
 * PUT /api/worker-portal/jobs/:id/action
 * Handle worker dispatch action: ACCEPT, DECLINE, START, COMPLETE.
 */
async function handleJobAction(req, res) {
  try {
    const { action } = req.body;
    const bookingId = req.params.id;
    const userId = req.user.id;

    const workerRes = await query('SELECT id FROM workers WHERE user_id = $1', [userId]);
    const worker = workerRes.rows[0];
    if (!worker) {
      return res.status(404).json({ error: 'Not Found', message: 'Worker profile not found.' });
    }

    const bookingRes = await query('SELECT * FROM bookings WHERE id = $1', [bookingId]);
    const booking = bookingRes.rows[0];
    if (!booking) {
      return res.status(404).json({ error: 'Not Found', message: 'Booking not found.' });
    }

    if (action === 'ACCEPT') {
      // First-to-Accept atomic claim: only claim if booking is still REQUESTED & unassigned (or MATCHED to this worker)
      const claimRes = await query(`
        UPDATE bookings
        SET status = 'ACCEPTED', worker_id = $1, updated_at = CURRENT_TIMESTAMP
        WHERE id = $2
          AND (
            (status = 'REQUESTED' AND worker_id IS NULL)
            OR (status = 'MATCHED' AND worker_id = $1)
          )
        RETURNING *
      `, [worker.id, bookingId]);

      if (claimRes.rows.length === 0) {
        return res.status(409).json({
          error: 'Order Already Claimed',
          message: 'This job request has already been accepted by another nearby artisan and is no longer available in the dispatch pool.'
        });
      }

      // Automatically change the worker status to BUSY in schedule slot
      await query(`
        UPDATE workers
        SET availability = 'BUSY', updated_at = CURRENT_TIMESTAMP
        WHERE id = $1
      `, [worker.id]);

      // Also update invoice with worker name and cooperative affiliation
      const workerInfoRes = await query(`
        SELECT u.name, c.name as cooperative_name, w.tier
        FROM workers w
        JOIN users u ON w.user_id = u.id
        JOIN cooperatives c ON w.cooperative_id = c.id
        WHERE w.id = $1
      `, [worker.id]);
      if (workerInfoRes.rows[0]) {
        const wInfo = workerInfoRes.rows[0];
        await query(`
          UPDATE invoices
          SET worker_name = $1, cooperative_name = $2
          WHERE booking_id = $3
        `, [`${wInfo.name} (${wInfo.tier} Artisan)`, wInfo.cooperative_name, bookingId]);
      }
    } else if (action === 'DECLINE') {
      await query(`
        UPDATE bookings
        SET status = 'REQUESTED',
            worker_id = NULL,
            declined_worker_ids = CASE 
              WHEN declined_worker_ids IS NULL OR declined_worker_ids = '' THEN ',' || $2 || ','
              WHEN declined_worker_ids NOT LIKE '%,' || $2 || ',%' THEN declined_worker_ids || $2 || ','
              ELSE declined_worker_ids
            END,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = $1
      `, [bookingId, worker.id]);

      // If worker has no remaining active jobs, restore to AVAILABLE
      const remainingActive = await query(`
        SELECT COUNT(*) as count FROM bookings
        WHERE worker_id = $1 AND status IN ('ACCEPTED', 'IN_PROGRESS') AND id != $2
      `, [worker.id, bookingId]);

      if (parseInt(remainingActive.rows[0].count, 10) === 0) {
        await query(`
          UPDATE workers
          SET availability = 'AVAILABLE', updated_at = CURRENT_TIMESTAMP
          WHERE id = $1 AND availability = 'BUSY'
        `, [worker.id]);
      }
    } else if (action === 'START') {
      await query(`
        UPDATE bookings
        SET status = 'IN_PROGRESS', updated_at = CURRENT_TIMESTAMP
        WHERE id = $1
      `, [bookingId]);

      // Ensure worker status is BUSY while on-site
      await query(`
        UPDATE workers
        SET availability = 'BUSY', updated_at = CURRENT_TIMESTAMP
        WHERE id = $1
      `, [worker.id]);
    } else if (action === 'COMPLETE') {
      if (booking.status === 'COMPLETED') {
        return res.json({ message: 'Booking is already completed', booking });
      }
      const completedAt = new Date().toISOString();
      const guaranteeUntil = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString();
      await query(`
        UPDATE bookings
        SET status = 'COMPLETED', completed_at = $1, guarantee_armed_until = $2, updated_at = CURRENT_TIMESTAMP
        WHERE id = $3
      `, [completedAt, guaranteeUntil, bookingId]);

      // Update worker stats
      await query(`
        UPDATE workers
        SET total_jobs_completed = total_jobs_completed + 1,
            total_earnings = total_earnings + $1,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = $2
      `, [booking.amount || 299, worker.id]);

      // If worker has no other active jobs, restore to AVAILABLE
      const remainingActive = await query(`
        SELECT COUNT(*) as count FROM bookings
        WHERE worker_id = $1 AND status IN ('ACCEPTED', 'IN_PROGRESS') AND id != $2
      `, [worker.id, bookingId]);

      if (parseInt(remainingActive.rows[0].count, 10) === 0) {
        await query(`
          UPDATE workers
          SET availability = 'AVAILABLE', updated_at = CURRENT_TIMESTAMP
          WHERE id = $1 AND availability = 'BUSY'
        `, [worker.id]);
      }

      // Update invoice
      await query(`
        UPDATE invoices SET payment_status = 'PAID' WHERE booking_id = $1
      `, [bookingId]);
    } else {
      return res.status(400).json({ error: 'Validation Error', message: 'Invalid action.' });
    }

    const updatedRes = await query('SELECT * FROM bookings WHERE id = $1', [bookingId]);
    res.json({ message: `Job action ${action} processed successfully`, booking: updatedRes.rows[0] });
  } catch (err) {
    console.error('Job action error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to process job action.' });
  }
}

/**
 * GET /api/worker-portal/welfare
 * Get worker welfare and social security information.
 */
async function getWorkerWelfare(req, res) {
  try {
    const userId = req.user.id;

    const workerRes = await query(`
      SELECT w.id, w.worker_code, w.total_earnings, w.total_jobs_completed,
             c.name as cooperative_name
      FROM workers w
      JOIN cooperatives c ON w.cooperative_id = c.id
      WHERE w.user_id = $1
    `, [userId]);

    const worker = workerRes.rows[0];
    if (!worker) {
      return res.status(404).json({ error: 'Not Found', message: 'Worker profile not found.' });
    }

    const welfareRes = await query(`
      SELECT * FROM worker_welfare WHERE worker_id = $1 ORDER BY id ASC
    `, [worker.id]);

    const availableSchemes = [
      {
        benefit_type: 'Insurance',
        benefit_name: 'ESIC Group Accident Insurance',
        provider: 'Employees State Insurance Corp',
        details: '₹2,00,000 accidental coverage + disability support',
      },
      {
        benefit_type: 'Health',
        benefit_name: 'Cooperative Health Support & Annual Checkup',
        provider: 'Cooperative Labour Welfare Fund',
        details: 'Free annual health checkup + subsidized family diagnostics',
      },
      {
        benefit_type: 'Training',
        benefit_name: 'NSDC Advanced Trade Upskilling Workshop',
        provider: 'National Skill Development Corp / ITI Network',
        details: 'Certified 2-week advanced appliance & green energy skill training',
      },
      {
        benefit_type: 'Pension',
        benefit_name: 'EPFO Social Security & Pension Scheme',
        provider: 'Employees Provident Fund Organisation',
        details: 'Monthly cooperative retirement corpus & pension contribution',
      },
      {
        benefit_type: 'Emergency',
        benefit_name: 'Cooperative Emergency Family Assistance',
        provider: 'District Labour Cooperative Federation Fund',
        details: 'Interest-free emergency assistance up to ₹25,000 for medical/disaster needs',
      },
    ];

    res.json({
      worker,
      welfareRecords: welfareRes.rows,
      availableSchemes,
      cooperativeLevyShare: '5% of every completed booking fee is directly credited to your PF & Insurance (Cooperative Welfare) Account',
      pocNotice: 'POC Welfare Integration: Real-world claim processing requires integration with authorized ESIC/EPFO digital portals and physical verification.',
    });
  } catch (err) {
    console.error('Get welfare error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to fetch welfare records.' });
  }
}

/**
 * POST /api/worker-portal/welfare/enroll
 * Apply / enroll for a welfare program.
 */
async function enrollWelfare(req, res) {
  try {
    const { benefit_type, benefit_name, provider, details } = req.body;
    const userId = req.user.id;

    const workerRes = await query('SELECT id FROM workers WHERE user_id = $1', [userId]);
    const worker = workerRes.rows[0];
    if (!worker) {
      return res.status(404).json({ error: 'Not Found', message: 'Worker profile not found.' });
    }

    const existingRes = await query(`
      SELECT id FROM worker_welfare
      WHERE worker_id = $1 AND benefit_name = $2
    `, [worker.id, benefit_name]);

    const todayDate = new Date().toISOString().split('T')[0];

    if (existingRes.rowCount > 0) {
      await query(`
        UPDATE worker_welfare
        SET status = 'ENROLLED', enrollment_date = $1
        WHERE id = $2
      `, [todayDate, existingRes.rows[0].id]);
    } else {
      await query(`
        INSERT INTO worker_welfare (worker_id, benefit_type, benefit_name, provider, status, enrollment_date, details)
        VALUES ($1, $2, $3, $4, 'ENROLLED', $5, $6)
      `, [worker.id, benefit_type, benefit_name, provider, todayDate, details]);
    }

    res.json({ message: `Successfully enrolled in ${benefit_name}` });
  } catch (err) {
    console.error('Enroll welfare error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to enroll in welfare scheme.' });
  }
}

module.exports = {
  getWorkerDashboard,
  updateAvailability,
  handleJobAction,
  getWorkerWelfare,
  enrollWelfare,
};
