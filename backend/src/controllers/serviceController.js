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

/**
 * GET /api/services/rate-card
 * Regulated 93-2-5 Rate Card with Spare Parts and Capped Labour.
 */
async function getRateCard(req, res) {
  try {
    const rateCard = {
      model: {
        name: 'Cooperative 93-2-5 Statutory Tariff Model',
        artisanShare: 93,
        platformFee: 2,
        welfareFund: 5,
        labourCapNotice: 'Labour Charges are regulated by the Federation and capped at ₹199–₹399 per appliance (vs ₹499 on commercial apps). All prices include standardized ISI spare parts with zero conveyance surcharge.',
        savingsNotice: 'Cooperative tariffs are 20% to 35% more affordable than private aggregator apps because there is zero middleman agency commission or surge pricing.'
      },
      protectionCover: {
        badge: 'Shram Setu Suraksha',
        title: 'End-to-End Service Protection',
        cards: [
          {
            id: 'warranty',
            title: '30-Day Workmanship Warranty',
            subtitle: 'Free repairs if the same issue arises',
            points: [
              'Free re-repairs at ₹0 labour fee if the same issue arises within 30 days',
              'One-click hassle-free dispatch claims directly from your dashboard',
              'Up to ₹10,000 protection cover if anything is damaged during the repair'
            ]
          },
          {
            id: 'verification',
            title: 'Expert Verified Repair Quotes',
            subtitle: 'Pre-validated against statutory locked matrix',
            points: [
              'Every repair quote shared by the professional is strictly verified',
              'Standardized ISI parts price matrix prevents overcharging',
              'If you are still unsure, ask a Senior Master Artisan for a free second opinion'
            ]
          },
          {
            id: 'ratecard',
            title: 'Regulated Fixed Rate Card',
            subtitle: 'Standardized cooperative tariffs with zero surge',
            points: [
              'All tariffs are officially decided based on cooperative statutory standards',
              'Zero surge pricing during rains, emergency hours, or holidays',
              'If you are charged differently from the rate card, reach out to our grievance desk with 1-click refund'
            ]
          }
        ]
      }
    };

    res.json(rateCard);
  } catch (err) {
    console.error('Get rate card error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to fetch rate card.' });
  }
}

module.exports = { getServices, getServiceById, getRateCard };
