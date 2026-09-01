const express = require('express');
const router = express.Router();
const {
  getDemandForecast,
  getWorkforceAllocation,
  approveMutualAid,
} = require('../controllers/smartFeaturesController');
const { authenticate, authorize } = require('../middleware/auth');

// Smart analytics can be viewed by ADMIN or authenticated users
router.use(authenticate);

router.get('/forecast', getDemandForecast);
router.get('/allocation', getWorkforceAllocation);
router.post('/mutual-aid/:id/approve', authorize('COOPERATIVE_ADMIN'), approveMutualAid);

module.exports = router;
