const express = require('express');
const router = express.Router();
const {
  triggerSos,
  getSosAlerts,
  getLiveMap,
  createDispute,
  getDisputes,
  resolveDispute,
  getApplianceLineage,
  getPartsCatalog,
} = require('../controllers/governanceController');
const { authenticate, authorize } = require('../middleware/auth');

// Public or Customer & Worker accessible
router.get('/parts-catalog', getPartsCatalog);

router.use(authenticate);

router.post('/sos', triggerSos);
router.get('/sos-alerts', authorize('COOPERATIVE_ADMIN'), getSosAlerts);
router.get('/live-map', getLiveMap);

router.post('/disputes', createDispute);
router.get('/disputes', getDisputes);
router.put('/disputes/:id/resolve', authorize('COOPERATIVE_ADMIN'), resolveDispute);

// Appliance Lineage routes
router.get('/appliance-lineage', getApplianceLineage);
router.get('/appliance-lineage/:customerId', getApplianceLineage);

module.exports = router;
