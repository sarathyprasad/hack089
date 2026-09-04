const express = require('express');
const router = express.Router();
const {
  registerSociety,
  getSocietyByTrackingId,
  getSocietiesList,
  updateSocietyTimelineStage,
} = require('../controllers/societyController');

// Public society registration & tracking
router.post('/register', registerSociety);
router.get('/track/:trackingId', getSocietyByTrackingId);
router.get('/', getSocietiesList);
router.patch('/:id/timeline', updateSocietyTimelineStage);

module.exports = router;
