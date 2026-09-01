const { query } = require('../db/connection');

/**
 * GET /api/services
 * List all active services, grouped by category.
 */
async function getServices(req, res) {
  try {
    const result = await query(`
      SELECT s.*, 
        CAST(
          (SELECT COUNT(DISTINCT ws.worker_id) 
           FROM worker_skills ws 
           JOIN skills sk ON ws.skill_id = sk.id 
           JOIN workers w ON ws.worker_id = w.id
           WHERE sk.category = s.category 
           AND w.verification_status = 'VERIFIED'
           AND w.availability IN ('AVAILABLE', 'BUSY')
          ) AS INTEGER
        ) as available_workers
      FROM services s
      WHERE s.is_active = 1
      ORDER BY s.category, s.name
    `);

    res.json({ services: result.rows });
  } catch (err) {
    console.error('Get services error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to fetch services.' });
  }
}

/**
 * GET /api/services/:id
 * Get service detail with available workers.
 */
async function getServiceById(req, res) {
  try {
    const serviceRes = await query('SELECT * FROM services WHERE id = $1', [req.params.id]);
    const service = serviceRes.rows[0];

    if (!service) {
      return res.status(404).json({ error: 'Not Found', message: 'Service not found.' });
    }

    // Get workers who have skills in this service category
    const workersRes = await query(`
      SELECT DISTINCT w.id, w.worker_code, w.experience_years, w.service_area, 
             w.verification_status, w.availability, w.rating, w.total_reviews,
             w.total_jobs_completed, w.bio,
             u.name, u.phone, u.district, u.city,
             c.name as cooperative_name
      FROM workers w
      JOIN users u ON w.user_id = u.id
      JOIN cooperatives c ON w.cooperative_id = c.id
      JOIN worker_skills ws ON ws.worker_id = w.id
      JOIN skills sk ON ws.skill_id = sk.id
      WHERE sk.category = $1
      AND w.verification_status = 'VERIFIED'
      AND u.is_active = 1
      ORDER BY w.rating DESC, w.total_jobs_completed DESC
    `, [service.category]);

    res.json({ service, workers: workersRes.rows });
  } catch (err) {
    console.error('Get service detail error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to fetch service details.' });
  }
}

module.exports = { getServices, getServiceById };
