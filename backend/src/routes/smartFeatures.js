const express = require('express');
const router = express.Router();
const {
  getDemandForecast,
  getWorkforceAllocation,
  approveMutualAid,
} = require('../controllers/smartFeaturesController');
const { handleAIChat } = require('../controllers/aiChatController');
const { authenticate, authorize } = require('../middleware/auth');

const { aiChatLimiter } = require('../middleware/rateLimiter');

// Public AI Chatbot Assistant for citizens, workers, and visitors (rate limited)
router.post('/ai-chat', aiChatLimiter, handleAIChat);

// Protected routes (require authenticated login)
router.use(authenticate);

router.get('/forecast', getDemandForecast);
router.get('/allocation', getWorkforceAllocation);
router.post('/mutual-aid/:id/approve', authorize('COOPERATIVE_ADMIN'), approveMutualAid);

module.exports = router;
