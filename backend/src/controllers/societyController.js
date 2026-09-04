const { query } = require('../db/connection');

/**
 * Generate random formatted tracking ID
 */
function generateTrackingId() {
  const year = new Date().getFullYear();
  const rand = Math.floor(1000 + Math.random() * 9000);
  return `SS-SOC-${year}-${rand}`;
}

/**
 * POST /api/societies/register
 * 9-Step Legal Formation Workflow for Newly Formed Societies (Page 1)
 */
async function registerSociety(req, res) {
  try {
    const {
      name,
      registered_email,
      registered_phone,
      district,
      city,
      address,
      pincode,
      objectives,
      initial_capital_balance = 10000,
      bank_account_no,
      cooperative_bank_name,
      bank_ifsc,
      founding_members = [],
      documents = [],
    } = req.body;

    // 1. Validation: Name & Email
    if (!name || !registered_email || !district) {
      return res.status(400).json({ error: 'Society Name, Email, and District are required.' });
    }

    // 2. Minimum 10 Founding Members Validation (Statutory Requirement - Page 1)
    if (!Array.isArray(founding_members) || founding_members.length < 10) {
      return res.status(400).json({
        error: 'Statutory Formation Requirement: At least 10 founding members are required to form and register a new cooperative society.',
        receivedMembersCount: founding_members ? founding_members.length : 0,
      });
    }

    // 3. Minimum Capital Balance Validation (Min ₹10,000 - Page 1)
    const capital = parseFloat(initial_capital_balance) || 0;
    if (capital < 10000) {
      return res.status(400).json({
        error: 'Statutory Capital Requirement: Proof of minimum ₹10,000 initial capital contribution deposited in a cooperative bank is required.',
      });
    }

    // Check if society email already exists
    const existing = await query('SELECT id, tracking_id FROM societies WHERE registered_email = $1', [registered_email]);
    if (existing.rows.length > 0) {
      return res.status(409).json({
        error: 'A society with this registered email address already exists.',
        tracking_id: existing.rows[0].tracking_id,
      });
    }

    const trackingId = generateTrackingId();
    const societyCode = `SOC-${district.substring(0, 3).toUpperCase()}-${Date.now().toString().slice(-6)}`;

    // Insert Society
    const societyResult = await query(
      `INSERT INTO societies (
        society_code, name, status, registered_email, registered_phone,
        district, city, address, pincode, objectives, initial_capital_balance,
        bank_account_no, cooperative_bank_name, bank_ifsc, timeline_stage, tracking_id
      ) VALUES ($1, $2, 'SUBMITTED', $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, 7, $14)
      RETURNING *`,
      [
        societyCode,
        name,
        registered_email,
        registered_phone || '0674-2500000',
        district,
        city || district,
        address || `${district} Main Road`,
        pincode || '751001',
        objectives || 'Labour & artisan welfare cooperative federation',
        capital,
        bank_account_no || 'COOP-ACC-DEFAULT',
        cooperative_bank_name || 'District Central Cooperative Bank',
        bank_ifsc || 'DCCB0001001',
        trackingId,
      ]
    );

    const createdSociety = societyResult.rows[0];

    // Insert 10+ Founding Members
    for (const member of founding_members) {
      await query(
        `INSERT INTO society_founding_members (
          society_id, full_name, occupation, address, phone, aadhaar_number, role_in_society, is_signatory
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
        [
          createdSociety.id,
          member.full_name || 'Founding Member',
          member.occupation || 'Skilled Artisan',
          member.address || createdSociety.address,
          member.phone || '9800000000',
          member.aadhaar_number || '****-****-0000',
          member.role_in_society || 'MEMBER',
          member.is_signatory !== undefined ? (member.is_signatory ? 1 : 0) : 1,
        ]
      );
    }

    // Insert Statutory Documents (Bylaws, Resolution, Bank Cert, Affidavit)
    const defaultDocs = [
      { doc_type: 'APPLICATION_FORM', document_name: 'Form-1 Formation Application (Signed by 10 Members)' },
      { doc_type: 'MEMBER_LIST', document_name: 'Official Founding Member Roster & Identity Proofs' },
      { doc_type: 'BYLAWS', document_name: 'Model Cooperative Bylaws Document' },
      { doc_type: 'RESOLUTION_OF_FORMATION', document_name: 'General Meeting Resolution & Minutes of Formation' },
      { doc_type: 'BANK_CERTIFICATE', document_name: `Cooperative Bank Capital Certificate (₹${capital.toLocaleString()})` },
      { doc_type: 'AFFIDAVIT', document_name: 'Non-Profit Cooperative Compliance Affidavit' },
    ];

    for (const d of defaultDocs) {
      await query(
        `INSERT INTO society_statutory_documents (
          society_id, doc_type, document_name, document_url, verification_status
        ) VALUES ($1, $2, $3, $4, 'PENDING')`,
        [createdSociety.id, d.doc_type, d.document_name, `https://gov.in/docs/${createdSociety.id}_${d.doc_type.toLowerCase()}.pdf`]
      );
    }

    // Record Initial Treasury Deposit
    await query(
      `INSERT INTO society_treasury_ledger (
        society_id, transaction_code, transaction_type, amount, description, balance_after
      ) VALUES ($1, $2, 'TREASURY_DEPOSIT', $3, 'Initial Member Capital Contribution Deposited in Cooperative Bank', $3)`,
      [createdSociety.id, `TXN-INIT-${createdSociety.id}`, capital]
    );

    return res.status(201).json({
      success: true,
      message: 'Society formation application submitted successfully. Unique Tracking ID generated.',
      data: {
        society: createdSociety,
        tracking_id: trackingId,
        members_count: founding_members.length,
        timeline_stage: 7,
        next_step: 'Verification of documents and meeting with District Registrar of Cooperatives.',
      },
    });
  } catch (err) {
    console.error('Register Society Error:', err);
    return res.status(500).json({ error: 'Failed to register society.', details: err.message });
  }
}

/**
 * GET /api/societies/track/:trackingId
 * Fetch full dossier, founding member list, and timeline progress
 */
async function getSocietyByTrackingId(req, res) {
  try {
    const { trackingId } = req.params;
    const socRes = await query('SELECT * FROM societies WHERE tracking_id = $1 OR society_code = $1', [trackingId]);

    if (socRes.rows.length === 0) {
      return res.status(404).json({ error: 'Society tracking record not found.' });
    }

    const society = socRes.rows[0];
    const membersRes = await query('SELECT * FROM society_founding_members WHERE society_id = $1 ORDER BY id ASC', [society.id]);
    const docsRes = await query('SELECT * FROM society_statutory_documents WHERE society_id = $1 ORDER BY id ASC', [society.id]);

    return res.json({
      success: true,
      data: {
        society,
        founding_members: membersRes.rows,
        statutory_documents: docsRes.rows,
      },
    });
  } catch (err) {
    console.error('Track Society Error:', err);
    return res.status(500).json({ error: 'Failed to retrieve society tracking details.' });
  }
}

/**
 * GET /api/societies
 * Get list of all societies with filter options
 */
async function getSocietiesList(req, res) {
  try {
    const { district, status, nlcf } = req.query;
    let sql = 'SELECT * FROM societies WHERE 1=1';
    const params = [];

    if (district) {
      params.push(district);
      sql += ` AND district = $${params.length}`;
    }
    if (status) {
      params.push(status);
      sql += ` AND status = $${params.length}`;
    }
    if (nlcf !== undefined) {
      params.push(parseInt(nlcf, 10));
      sql += ` AND is_nlcf_affiliated = $${params.length}`;
    }

    sql += ' ORDER BY id ASC';
    const result = await query(sql, params);
    return res.json({ success: true, societies: result.rows });
  } catch (err) {
    console.error('Get Societies Error:', err);
    return res.status(500).json({ error: 'Failed to retrieve societies.' });
  }
}

/**
 * PATCH /api/societies/:id/timeline
 * Advance timeline stage for recognized / formed society (Page 1)
 */
async function updateSocietyTimelineStage(req, res) {
  try {
    const { id } = req.params;
    const { stage, is_nlcf_affiliated, dco_linked, ncct_training_completed, ministry_recognized } = req.body;

    const updates = [];
    const params = [id];

    if (stage !== undefined) {
      params.push(stage);
      updates.push(`timeline_stage = $${params.length}`);
      if (stage === 9) {
        updates.push("status = 'ACTIVE'");
      }
    }
    if (is_nlcf_affiliated !== undefined) {
      params.push(is_nlcf_affiliated ? 1 : 0);
      updates.push(`is_nlcf_affiliated = $${params.length}`);
      if (is_nlcf_affiliated) {
        updates.push("audit_frequency = 'HALF_YEARLY'");
        updates.push("nlcf_certificate_no = 'NLCF-CERT-2026-" + Math.floor(1000 + Math.random() * 9000) + "'");
        updates.push("nlcf_affiliation_date = CURRENT_DATE::text");
      }
    }
    if (dco_linked !== undefined) {
      params.push(dco_linked ? 1 : 0);
      updates.push(`dco_linked = $${params.length}`);
    }
    if (ncct_training_completed !== undefined) {
      params.push(ncct_training_completed ? 1 : 0);
      updates.push(`ncct_training_completed = $${params.length}`);
    }
    if (ministry_recognized !== undefined) {
      params.push(ministry_recognized ? 1 : 0);
      updates.push(`ministry_recognized = $${params.length}`);
    }

    updates.push('updated_at = CURRENT_TIMESTAMP');

    const sql = `UPDATE societies SET ${updates.join(', ')} WHERE id = $1 RETURNING *`;
    const result = await query(sql, params);

    return res.json({
      success: true,
      message: 'Society statutory timeline updated successfully.',
      data: result.rows[0],
    });
  } catch (err) {
    console.error('Update Society Timeline Error:', err);
    return res.status(500).json({ error: 'Failed to update society timeline.' });
  }
}

module.exports = {
  registerSociety,
  getSocietyByTrackingId,
  getSocietiesList,
  updateSocietyTimelineStage,
};
