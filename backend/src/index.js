const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');
const fs = require('fs');

// Load environment variables
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

// Database
const { query } = require('./db/connection');
const { migrate } = require('./db/migrate');

const app = express();
const PORT = process.env.PORT || 5000;

// ---------------------
// Middleware
// ---------------------
app.use(helmet({
  contentSecurityPolicy: false, // Allows external maps (Google Maps / Leaflet tiles) to load without CSP blocking
  crossOriginResourcePolicy: { policy: 'cross-origin' },
  crossOriginOpenerPolicy: false,
  crossOriginEmbedderPolicy: false,
}));

// CORS configured for Localhost, LAN IP, and ngrok tunnels
const allowedOrigins = [
  'http://localhost:5173',
  'http://127.0.0.1:5173',
  'http://localhost:3000',
  process.env.CORS_ORIGIN,
].filter(Boolean);

app.use(cors({
  origin: (origin, callback) => {
    if (!origin) return callback(null, true);
    
    if (
      allowedOrigins.includes(origin) ||
      origin.includes('ngrok') ||
      origin.includes('loca.lt') ||
      origin.startsWith('http://localhost:') ||
      origin.startsWith('http://127.0.0.1:') ||
      origin.startsWith('http://192.168.') ||
      process.env.CORS_ALLOW_ALL === 'true'
    ) {
      return callback(null, true);
    }
    
    callback(null, true);
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'ngrok-skip-browser-warning', 'x-requested-with'],
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging - only in development
if (process.env.NODE_ENV !== 'production') {
  app.use(morgan('dev'));
}

// ---------------------
// Routes
// ---------------------
const authRoutes = require('./routes/auth');
const servicesRoutes = require('./routes/services');
const workersRoutes = require('./routes/workers');
const matchingRoutes = require('./routes/matching');
const bookingsRoutes = require('./routes/bookings');
const workerPortalRoutes = require('./routes/workerPortal');
const adminRoutes = require('./routes/admin');
const smartFeaturesRoutes = require('./routes/smartFeatures');
const paymentRoutes = require('./routes/payments');
const reviewRoutes = require('./routes/reviews');
const localizationRoutes = require('./routes/localization');
const governanceRoutes = require('./routes/governance');
const societiesRoutes = require('./routes/societies');
const federationRoutes = require('./routes/federation');

app.use('/api/auth', authRoutes);
app.use('/api/services', servicesRoutes);
app.use('/api/workers', workersRoutes);
app.use('/api/matching', matchingRoutes);
app.use('/api/bookings', bookingsRoutes);
app.use('/api/worker-portal', workerPortalRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/smart-features', smartFeaturesRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/reviews', reviewRoutes);
app.use('/api/localization', localizationRoutes);
app.use('/api/governance', governanceRoutes);
app.use('/api/societies', societiesRoutes);
app.use('/api/federation', federationRoutes);

// ---------------------
// Health Check
// ---------------------
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'Shram Setu API is running on PostgreSQL',
    database: 'PostgreSQL',
    environment: process.env.NODE_ENV || 'development',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// ---------------------
// API Info
// ---------------------
app.get('/api', (req, res) => {
  res.json({
    name: 'Shram Setu API',
    description: 'Cooperative Gig Services Platform — Backend API (PostgreSQL + Live Server ready)',
    version: '1.0.0',
    endpoints: {
      health: 'GET /api/health',
      auth: 'POST /api/auth/login, POST /api/auth/register',
      services: 'GET /api/services',
      workers: 'GET /api/workers',
      bookings: 'GET /api/bookings',
      admin: 'GET /api/admin/dashboard',
      stats: 'GET /api/db/stats'
    }
  });
});

// ---------------------
// Database Stats (verification endpoint)
// ---------------------
app.get('/api/db/stats', async (req, res) => {
  try {
    const tables = ['cooperatives', 'users', 'workers', 'skills', 'services', 'bookings', 'payments', 'reviews', 'certifications', 'worker_welfare'];
    const stats = {};
    for (const table of tables) {
      const countRes = await query(`SELECT COUNT(*) as count FROM ${table}`);
      stats[table] = parseInt(countRes.rows[0].count, 10);
    }
    res.json({ status: 'ok', database: 'PostgreSQL connected', stats });
  } catch (err) {
    res.status(500).json({ status: 'error', database: 'PostgreSQL error', message: err.message });
  }
});

// ---------------------
// Static React Hosting (Production)
// ---------------------
const frontendDistPath = path.join(__dirname, '..', '..', 'frontend', 'dist');
if (fs.existsSync(frontendDistPath)) {
  app.use(express.static(frontendDistPath));
}

// ---------------------
// Fallback & 404 Handler (Universal Express 4 & 5 Compatible)
// ---------------------
app.use((req, res) => {
  if (req.originalUrl.startsWith('/api')) {
    return res.status(404).json({
      error: 'Not Found',
      message: `Route ${req.method} ${req.originalUrl} not found`,
      status: 404
    });
  }

  if (fs.existsSync(frontendDistPath)) {
    return res.sendFile(path.join(frontendDistPath, 'index.html'));
  }

  res.status(404).send('Not Found');
});

// ---------------------
// Error Handler
// ---------------------
app.use((err, req, res, next) => {
  console.error('Server Error:', err.message);
  res.status(err.status || 500).json({
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'production'
      ? 'Something went wrong'
      : err.message,
    status: err.status || 500
  });
});

// ---------------------
// Start Server
// ---------------------
async function startServer() {
  try {
    await migrate();
  } catch (err) {
    console.error('⚠️ Database initialization notice:', err.message);
  }

  app.listen(PORT, () => {
    console.log(`\n🏛️  Shram Setu API Server`);
    console.log(`   Database: PostgreSQL`);
    console.log(`   Port: ${PORT}`);
    console.log(`   Health: http://localhost:${PORT}/api/health`);
    console.log(`   Database Stats: http://localhost:${PORT}/api/db/stats`);
    console.log(`   Static SPA: ${fs.existsSync(frontendDistPath) ? 'Enabled (dist found)' : 'Disabled (run npm run build in frontend)'}`);
    console.log(`   Environment: ${process.env.NODE_ENV || 'development'}\n`);
  });
}

startServer();
