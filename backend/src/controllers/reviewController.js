const { query } = require('../db/connection');

/**
 * POST /api/reviews
 * Submit rating and feedback review for a completed service.
 */
async function submitReview(req, res) {
  try {
    const { bookingId, rating } = req.body;
    const comment = req.body.comment || req.body.reviewText || '';
    const customerId = req.user.id;

    if (!bookingId || !rating) {
      return res.status(400).json({ error: 'Validation Error', message: 'Booking ID and rating (1-5) are required.' });
    }

    const numRating = parseInt(rating, 10);
    if (numRating < 1 || numRating > 5) {
      return res.status(400).json({ error: 'Validation Error', message: 'Rating must be an integer between 1 and 5.' });
    }

    const bookingRes = await query('SELECT * FROM bookings WHERE id = $1', [bookingId]);
    const booking = bookingRes.rows[0];
    if (!booking) {
      return res.status(404).json({ error: 'Not Found', message: 'Booking not found.' });
    }

    if (booking.customer_id !== customerId && req.user.role !== 'COOPERATIVE_ADMIN') {
      return res.status(403).json({ error: 'Forbidden', message: 'You can only rate your own bookings.' });
    }

    if (booking.status !== 'COMPLETED') {
      return res.status(400).json({ error: 'Bad Request', message: 'Reviews can only be submitted for completed bookings.' });
    }

    if (!booking.worker_id) {
      return res.status(400).json({ error: 'Bad Request', message: 'Cannot review a booking without an assigned worker.' });
    }

    // Check if review already exists
    const existingRes = await query('SELECT id FROM reviews WHERE booking_id = $1', [bookingId]);
    const nowStr = new Date().toISOString();

    if (existingRes.rowCount > 0) {
      await query(`
        UPDATE reviews
        SET rating = $1, comment = $2, created_at = $3
        WHERE id = $4
      `, [numRating, comment || '', nowStr, existingRes.rows[0].id]);
    } else {
      await query(`
        INSERT INTO reviews (booking_id, customer_id, worker_id, rating, comment, created_at)
        VALUES ($1, $2, $3, $4, $5, $6)
      `, [bookingId, customerId, booking.worker_id, numRating, comment || '', nowStr]);
    }

    // Recompute worker's average rating and total reviews
    const statsRes = await query(`
      SELECT AVG(rating) as avg_rating, COUNT(*) as count
      FROM reviews
      WHERE worker_id = $1
    `, [booking.worker_id]);

    const stats = statsRes.rows[0];
    const newAvg = stats.avg_rating ? Math.round(parseFloat(stats.avg_rating) * 10) / 10 : numRating;
    const newCount = parseInt(stats.count, 10) || 1;

    await query(`
      UPDATE workers
      SET rating = $1, total_reviews = $2, updated_at = CURRENT_TIMESTAMP
      WHERE id = $3
    `, [newAvg, newCount, booking.worker_id]);

    res.json({
      message: 'Review submitted successfully. Thank you for supporting your labour cooperative!',
      rating: numRating,
      comment: comment || '',
      updatedWorkerRating: newAvg,
      totalWorkerReviews: newCount,
    });
  } catch (err) {
    console.error('Submit review error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to submit review.' });
  }
}

/**
 * GET /api/reviews/worker/:workerId
 * Get all reviews for a worker.
 */
async function getWorkerReviews(req, res) {
  try {
    const { workerId } = req.params;

    const reviewsRes = await query(`
      SELECT r.*, u.name as customer_name, s.name as service_name
      FROM reviews r
      JOIN users u ON r.customer_id = u.id
      JOIN bookings b ON r.booking_id = b.id
      JOIN services s ON b.service_id = s.id
      WHERE r.worker_id = $1
      ORDER BY r.created_at DESC
    `, [workerId]);

    res.json({ reviews: reviewsRes.rows });
  } catch (err) {
    console.error('Get worker reviews error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to fetch reviews.' });
  }
}

module.exports = {
  submitReview,
  getWorkerReviews,
};
