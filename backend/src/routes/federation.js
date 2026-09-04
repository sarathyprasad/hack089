const express = require('express');
const router = express.Router();
const {
  getAdminDashboardData,
  getTreasurerDashboardData,
  applyNcctTraining,
  getInstitutionalTenders,
  registerWorkerByFederation,
} = require('../controllers/federationController');

// Federation Admin & Treasurer consoles (Pages 3 & 4)
router.get('/admin-dashboard', getAdminDashboardData);
router.get('/treasurer-dashboard', getTreasurerDashboardData);
router.post('/ncct/apply', applyNcctTraining);
router.get('/tenders', getInstitutionalTenders);
router.post('/workers/register', registerWorkerByFederation);

module.exports = router;
