const express = require('express');
const router = express.Router();
const { getServices, getServiceById, getRateCard, getServiceLocations } = require('../controllers/serviceController');

router.get('/', getServices);
router.get('/locations', getServiceLocations);
router.get('/rate-card', getRateCard);
router.get('/:id', getServiceById);

module.exports = router;
