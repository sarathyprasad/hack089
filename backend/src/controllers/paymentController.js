const { query } = require('../db/connection');

/**
 * POST /api/payments/process
 * Process a simulated payment (UPI, CARD, NET_BANKING).
 */
async function processPayment(req, res) {
  try {
    const { bookingId, paymentMethod, upiId, cardNumber } = req.body;
    const userId = req.user ? req.user.id : 1;

    if (!bookingId) {
      return res.status(400).json({ error: 'Validation Error', message: 'Booking ID is required.' });
    }

    const bookingRes = await query('SELECT * FROM bookings WHERE id = $1', [bookingId]);
    const booking = bookingRes.rows[0];
    if (!booking) {
      return res.status(404).json({ error: 'Not Found', message: 'Booking not found.' });
    }

    const amount = Number(booking.total_amount) || Number(booking.amount) || 299;
    const nowStr = new Date().toISOString();
    const dateCode = nowStr.split('T')[0].replace(/-/g, '');
    const randNum = String(Math.floor(100 + Math.random() * 900));
    const transactionId = `TXN-OD-${dateCode}-${String(booking.id).padStart(3, '0')}${randNum}`;
    const method = paymentMethod || 'UPI';

    // Insert or update payment record
    const existingRes = await query('SELECT id FROM payments WHERE booking_id = $1', [bookingId]);
    let paymentRecord;
    if (existingRes.rowCount > 0) {
      const pUpdate = await query(`
        UPDATE payments
        SET transaction_id = $1, amount = $2, payment_method = $3, status = 'SUCCESS', paid_at = $4
        WHERE id = $5
        RETURNING *
      `, [transactionId, amount, method, nowStr, existingRes.rows[0].id]);
      paymentRecord = pUpdate.rows[0];
    } else {
      const pInsert = await query(`
        INSERT INTO payments (booking_id, transaction_id, amount, payment_method, status, paid_at)
        VALUES ($1, $2, $3, $4, 'SUCCESS', $5)
        RETURNING *
      `, [bookingId, transactionId, amount, method, nowStr]);
      paymentRecord = pInsert.rows[0];
    }

    // Update invoice payment status to PAID
    await query(`
      UPDATE invoices
      SET payment_status = 'PAID', total_amount = $1
      WHERE booking_id = $2
    `, [amount, bookingId]);

    // Retrieve updated records
    const updatedBookingRes = await query('SELECT * FROM bookings WHERE id = $1', [bookingId]);
    const invoiceRes = await query('SELECT * FROM invoices WHERE booking_id = $1', [bookingId]);

    res.json({
      message: 'Payment processed successfully! Form IV Tax Invoice updated to PAID.',
      transactionId,
      amount,
      paymentMethod: method,
      payment: paymentRecord,
      invoice: invoiceRes.rows[0],
      booking: updatedBookingRes.rows[0],
    });
  } catch (err) {
    console.error('Process payment error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to process payment.' });
  }
}

/**
 * GET /api/payments/invoice/:bookingId
 * Get official cooperative tax invoice for a booking.
 */
async function getInvoiceByBookingId(req, res) {
  try {
    const { bookingId } = req.params;

    const invoiceRes = await query(`
      SELECT inv.*,
             b.booking_code, b.status as booking_status, b.scheduled_date, b.scheduled_time,
             b.location_district, b.location_city, b.location_address, b.location_pincode,
             b.is_emergency,
             u_cust.name as customer_name, u_cust.phone as customer_phone, u_cust.email as customer_email,
             u_work.name as worker_name, u_work.phone as worker_phone,
             w.worker_code,
             c.name as cooperative_name, c.registration_number as cooperative_reg,
             c.address as cooperative_address, c.contact_phone as cooperative_phone, c.contact_email as cooperative_email,
             p.transaction_id, p.payment_method, p.paid_at, p.status as payment_record_status
      FROM invoices inv
      JOIN bookings b ON inv.booking_id = b.id
      JOIN users u_cust ON b.customer_id = u_cust.id
      LEFT JOIN workers w ON b.worker_id = w.id
      LEFT JOIN users u_work ON w.user_id = u_work.id
      LEFT JOIN cooperatives c ON w.cooperative_id = c.id
      LEFT JOIN payments p ON p.booking_id = b.id
      WHERE inv.booking_id = $1
    `, [bookingId]);

    const invoice = invoiceRes.rows[0];

    if (!invoice) {
      return res.status(404).json({ error: 'Not Found', message: 'Invoice not found.' });
    }

    res.json({ invoice });
  } catch (err) {
    console.error('Get invoice error:', err);
    res.status(500).json({ error: 'Server Error', message: 'Failed to fetch invoice.' });
  }
}

module.exports = {
  processPayment,
  getInvoiceByBookingId,
};
