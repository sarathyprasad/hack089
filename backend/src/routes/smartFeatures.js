const express = require('express');
const router = express.Router();
const {
  getDemandForecast,
  getWorkforceAllocation,
  approveMutualAid,
} = require('../controllers/smartFeaturesController');
const { handleAIChat } = require('../controllers/aiChatController');
const { authenticate, authorize } = require('../middleware/auth');

// Public AI Chatbot Assistant for citizens, workers, and visitors
router.post('/ai-chat', handleAIChat);

// Protected routes (require authenticated login)
router.use(authenticate);

router.get('/forecast', getDemandForecast);
router.get('/allocation', getWorkforceAllocation);
router.post('/mutual-aid/:id/approve', authorize('COOPERATIVE_ADMIN'), approveMutualAid);

module.exports = router;
