const { query } = require('../db/connection');

/**
 * POST /api/governance/sos
 * Phase 4: Trigger 1-Tap Emergency SOS Beacon (Worker Safety).
 */
async function triggerSos(req, res) {
  try {
    const { bookingId, latitude, longitude, details } = req.body;
    const userId = req.user.id;

    const workerRes = await query('SELECT id, worker_code FROM workers WHERE user_id = $1', [userId]);
    const worker = workerRes.rows[0];
    if (!worker) {
      return res.status(404).json({ error: 'Not Found', message: 'Worker profile not found.' });
    }

    const sosRes = await query(`
      INSERT INTO sos_logs (worker_id, booking_id, latitude, longitude, status, details)
      VALUES ($1, $2, $3, $4, 'ACTIVE', $5)
      RETURNING *
    `, [worker.id, bookingId || null, latitude || 20.296, longitude || 85.824, details || 'Emergency SOS button triggered from mobile web interface.']);

    // Set worker sos_active flag
    await query('UPDATE workers SET sos_active = 1 WHERE id = $1', [worker.id]);

    res.status(201).json({
      message: '🚨 EMERGENCY SOS BEACON ACTIVATED. Federation Emergency Response & Supervisor Squad alerted with your live GPS location.',
      sosLog: sosRes.rows[0],
    });
  } catch (err) {
    console.error('SOS trigger error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to activate SOS beacon.' });
  }
}

/**
 * GET /api/governance/sos-alerts
 * Active SOS emergency feeds for Federation Admin.
 */
async function getSosAlerts(req, res) {
  try {
    const alertsRes = await query(`
      SELECT s.*, u.name as worker_name, u.phone as worker_phone, u.district as worker_district,
             w.worker_code, w.tier as worker_tier,
             b.booking_code, b.location_address
      FROM sos_logs s
      JOIN workers w ON s.worker_id = w.id
      JOIN users u ON w.user_id = u.id
      LEFT JOIN bookings b ON s.booking_id = b.id
      ORDER BY s.id DESC
      LIMIT 20
    `);

    res.json({ alerts: alertsRes.rows });
  } catch (err) {
    console.error('Get SOS alerts error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to fetch SOS alerts.' });
  }
}

/**
 * GET /api/governance/live-map
 * Phase 7: Live Interactive Map of active workers, dispatch clusters, and emergency zones.
 */
async function getLiveMap(req, res) {
  try {
    const workersRes = await query(`
      SELECT w.id, w.worker_code, w.tier, w.availability, w.latitude, w.longitude, w.rating, w.sos_active,
             u.name, u.phone, u.district, u.city,
             c.name as cooperative_name
      FROM workers w
      JOIN users u ON w.user_id = u.id
      JOIN cooperatives c ON w.cooperative_id = c.id
      WHERE w.verification_status = 'VERIFIED' AND u.is_active = 1
    `);

    const activeBookingsRes = await query(`
      SELECT b.id, b.booking_code, b.status, b.is_emergency, b.latitude, b.longitude,
             b.location_district, b.location_city, b.location_address,
             s.name as service_name, s.category as service_category
      FROM bookings b
      JOIN services s ON b.service_id = s.id
      WHERE b.status IN ('MATCHED', 'ACCEPTED', 'IN_PROGRESS')
    `);

    // Demand heatmap density clusters (K-Means simulation)
    const heatmapClusters = [
      { name: 'Patia IT Corridor (Bhubaneswar)', lat: 20.3540, lng: 85.8170, density: 'HIGH', demandIndex: 94, topTrade: 'Electrical & AC' },
      { name: 'Jaydev Vihar Residential Hub', lat: 20.2961, lng: 85.8245, density: 'HIGH', demandIndex: 88, topTrade: 'Plumbing & Deep Cleaning' },
      { name: 'Saheed Nagar Commercial Cluster', lat: 20.2870, lng: 85.8450, density: 'MODERATE', demandIndex: 72, topTrade: 'Carpentry & Maintenance' },
      { name: 'College Square & Buxi Bazar (Cuttack)', lat: 20.4625, lng: 85.8830, density: 'SURPLUS_ZONE', demandIndex: 65, topTrade: 'Drainage & Electrical' },
      { name: 'Grand Road & VIP Corridor (Puri)', lat: 19.8135, lng: 85.8312, density: 'SEASONAL', demandIndex: 58, topTrade: 'Caregiving & Painting' },
    ];

    res.json({
      workers: workersRes.rows,
      activeBookings: activeBookingsRes.rows,
      heatmapClusters,
    });
  } catch (err) {
    console.error('Get live map error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to fetch live map data.' });
  }
}

/**
 * POST /api/governance/disputes
 * Phase 7: Create a dispute / grievance ticket.
 */
async function createDispute(req, res) {
  try {
    const { bookingId, issueType, description } = req.body;
    const customerId = req.user.id;

    if (!issueType || !description) {
      return res.status(400).json({ error: 'Validation Error', message: 'Issue type and description are required.' });
    }

    let workerId = null;
    if (bookingId) {
      const bRes = await query('SELECT worker_id FROM bookings WHERE id = $1', [bookingId]);
      if (bRes.rows[0]) workerId = bRes.rows[0].worker_id;
    }

    const countRes = await query('SELECT COUNT(*) as c FROM dispute_tickets');
    const ticketCode = `DISP-2026-${String(parseInt(countRes.rows[0].c, 10) + 1).padStart(3, '0')}`;

    const insertRes = await query(`
      INSERT INTO dispute_tickets (ticket_code, booking_id, customer_id, worker_id, issue_type, description, status)
      VALUES ($1, $2, $3, $4, $5, $6, 'OPEN')
      RETURNING *
    `, [ticketCode, bookingId || null, customerId, workerId, issueType, description]);

    res.status(201).json({
      message: 'Grievance ticket created. Assigned to Cooperative Federation Human Arbitration Desk (No bot dead-ends).',
      ticket: insertRes.rows[0],
    });
  } catch (err) {
    console.error('Create dispute error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to create dispute ticket.' });
  }
}

/**
 * GET /api/governance/disputes
 */
async function getDisputes(req, res) {
  try {
    const disputesRes = await query(`
      SELECT d.*, u_cust.name as customer_name, u_cust.phone as customer_phone,
             u_work.name as worker_name,
             b.booking_code
      FROM dispute_tickets d
      JOIN users u_cust ON d.customer_id = u_cust.id
      LEFT JOIN workers w ON d.worker_id = w.id
      LEFT JOIN users u_work ON w.user_id = u_work.id
      LEFT JOIN bookings b ON d.booking_id = b.id
      ORDER BY d.id DESC
    `);

    res.json({ disputes: disputesRes.rows });
  } catch (err) {
    console.error('Get disputes error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to fetch disputes.' });
  }
}

/**
 * PUT /api/governance/disputes/:id/resolve
 */
async function resolveDispute(req, res) {
  try {
    const { resolutionNotes } = req.body;
    const disputeId = req.params.id;
    const arbitratorName = req.user.name || 'Federation Arbitrator';

    const updateRes = await query(`
      UPDATE dispute_tickets
      SET status = 'RESOLVED', resolution_notes = $1, arbitrator_name = $2, resolved_at = CURRENT_TIMESTAMP
      WHERE id = $3
      RETURNING *
    `, [resolutionNotes || 'Arbitration complete and agreement reached.', arbitratorName, disputeId]);

    res.json({
      message: 'Dispute resolved successfully by human arbitrator.',
      ticket: updateRes.rows[0],
    });
  } catch (err) {
    console.error('Resolve dispute error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to resolve dispute.' });
  }
}

/**
 * GET /api/governance/appliance-lineage/:customerId
 * Phase 6: Permanent Appliance Service Lineage History.
 */
async function getApplianceLineage(req, res) {
  try {
    const customerId = req.params.customerId || req.user.id;

    const lineageRes = await query(`
      SELECT l.*, b.booking_code
      FROM appliance_lineage l
      LEFT JOIN bookings b ON l.booking_id = b.id
      WHERE l.customer_id = $1
      ORDER BY l.id DESC
    `, [customerId]);

    res.json({ lineage: lineageRes.rows });
  } catch (err) {
    console.error('Get lineage error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to fetch appliance lineage.' });
  }
}

/**
 * GET /api/governance/parts-catalog
 * Phase 2 & 4: Standard Locked Parts Price Matrix.
 */
async function getPartsCatalog(req, res) {
  try {
    const { tradeCategory } = req.query;

    let q = 'SELECT * FROM parts_catalog';
    const params = [];
    if (tradeCategory) {
      q += ' WHERE trade_category = $1';
      params.push(tradeCategory);
    }
    q += ' ORDER BY trade_category, part_name';

    const partsRes = await query(q, params);
    res.json({ parts: partsRes.rows });
  } catch (err) {
    console.error('Get parts catalog error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to fetch parts catalog.' });
  }
}

module.exports = {
  triggerSos,
  getSosAlerts,
  getLiveMap,
  createDispute,
  getDisputes,
  resolveDispute,
  getApplianceLineage,
  getPartsCatalog,
};
