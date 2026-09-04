const express = require('express');
const router = express.Router();
const {
  createBooking,
  getBookings,
  getBookingById,
  verifyArrivalOtp,
  verifyCompletionOtp,
  uploadPhotoProof,
  addParts,
  claimGuarantee,
  updateBookingStatus,
  cancelBooking,
} = require('../controllers/bookingController');
const { authenticate, authorize } = require('../middleware/auth');

router.use(authenticate);

// Citizens only can create new service orders
router.post('/', authorize('CUSTOMER'), createBooking);
// Customers and admins only can list customer bookings (workers use /api/worker-portal/dashboard)
router.get('/', authorize('CUSTOMER', 'COOPERATIVE_ADMIN'), getBookings);
router.get('/:id', getBookingById);
router.put('/:id/status', updateBookingStatus);
router.post('/:id/cancel', cancelBooking);

// 7-Phase Workflow Handshakes
router.post('/:id/verify-arrival-otp', verifyArrivalOtp);
router.post('/:id/verify-completion-otp', verifyCompletionOtp);
router.post('/:id/photo-proof', uploadPhotoProof);
router.post('/:id/add-parts', addParts);
router.post('/:id/claim-guarantee', claimGuarantee);

module.exports = router;
