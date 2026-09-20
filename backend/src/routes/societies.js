const express = require('express');
const router = express.Router();
const {
  registerSociety,
  getSocietyByTrackingId,
  getSocietiesList,
  getFederationsOverview,
  updateSocietyTimelineStage,
  getPendingSocietiesForDco,
  dcoReviewSociety,
  updateSocietyAudit,
  updateSocietyGovernance,
  createOrUpdateInquiry,
} = require('../controllers/societyController');

const { authenticate, authorize } = require('../middleware/auth');

// Public society registration & tracking
router.post('/register', registerSociety);
router.get('/track/:trackingId', getSocietyByTrackingId);
router.get('/', getSocietiesList);

// Federation & District Overview
router.get('/federation-overview', authenticate, authorize('COOPERATIVE_ADMIN'), getFederationsOverview);

// DCO Registrar review & statutory regulatory endpoints
router.get('/pending/dco', authenticate, authorize('COOPERATIVE_ADMIN'), getPendingSocietiesForDco);
router.post('/:id/dco-review', authenticate, authorize('COOPERATIVE_ADMIN'), dcoReviewSociety);
router.patch('/:id/audit', authenticate, authorize('COOPERATIVE_ADMIN'), updateSocietyAudit);
router.patch('/:id/governance', authenticate, authorize('COOPERATIVE_ADMIN'), updateSocietyGovernance);
router.post('/inquiries', authenticate, authorize('COOPERATIVE_ADMIN'), createOrUpdateInquiry);

// Statutory Timeline Advancement (Restricted: COOPERATIVE_ADMIN only)
router.patch('/:id/timeline', authenticate, authorize('COOPERATIVE_ADMIN'), updateSocietyTimelineStage);

module.exports = router;
