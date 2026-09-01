const { Pool, Client } = require('pg');
const path = require('path');

// Ensure .env is loaded
require('dotenv').config({ path: path.join(__dirname, '..', '..', '.env') });

const config = {
  user: process.env.PGUSER || process.env.DB_USER || 'postgres',
  host: process.env.PGHOST || process.env.DB_HOST || 'localhost',
  password: process.env.PGPASSWORD || process.env.DB_PASSWORD || 'postgres',
  database: process.env.PGDATABASE || process.env.DB_NAME || 'sahakari_shramsetu',
  port: parseInt(process.env.PGPORT || process.env.DB_PORT || '5432', 10),
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
};

// If a full DATABASE_URL is provided, use it
if (process.env.DATABASE_URL) {
  config.connectionString = process.env.DATABASE_URL;
}

let pool;

/**
 * Ensure the target PostgreSQL database exists.
 * If not, connects to default 'postgres' database and creates it.
 */
async function ensureDatabaseExists() {
  // If running with a remote managed DATABASE_URL (e.g. Render, Supabase, Neon), skip local DDL
  if (process.env.DATABASE_URL) {
    return;
  }

  const targetDb = config.database;
  const adminClient = new Client({
    user: config.user,
    host: config.host,
    password: config.password,
    port: config.port,
    database: 'postgres', // default maintenance db
  });

  try {
    await adminClient.connect();
    const res = await adminClient.query(
      'SELECT 1 FROM pg_database WHERE datname = $1',
      [targetDb]
    );

    if (res.rowCount === 0) {
      console.log(`🔨 Target database "${targetDb}" not found. Creating it now...`);
      // Database names cannot be parameterized in DDL
      const safeDbName = targetDb.replace(/[^a-zA-Z0-9_]/g, '');
      await adminClient.query(`CREATE DATABASE "${safeDbName}"`);
      console.log(`✅ Database "${safeDbName}" created successfully.`);
    }
  } catch (err) {
    // If user doesn't have permissions or using external managed db, log warning and continue
    console.warn(`ℹ️ Database check notice: ${err.message}`);
  } finally {
    try {
      await adminClient.end();
    } catch (_) {}
  }
}

/**
 * Get or initialize the PostgreSQL connection pool.
 */
function getPool() {
  if (!pool) {
    if (process.env.DATABASE_URL) {
      pool = new Pool({
        connectionString: process.env.DATABASE_URL,
        ssl: { rejectUnauthorized: false },
        max: 20,
        idleTimeoutMillis: 30000,
        connectionTimeoutMillis: 10000,
      });
    } else {
      pool = new Pool({
        user: config.user,
        host: config.host,
        password: config.password,
        database: config.database,
        port: config.port,
        ssl: process.env.PGSSLMODE === 'require' ? { rejectUnauthorized: false } : false,
        max: 20,
        idleTimeoutMillis: 30000,
        connectionTimeoutMillis: 5000,
      });
    }

    pool.on('error', (err) => {
      console.error('⚠️ Unexpected error on idle PostgreSQL client:', err.message);
    });

    console.log(`📦 PostgreSQL Pool initialized for database: ${config.database} @ ${config.host}:${config.port}`);
  }
  return pool;
}

/**
 * Helper to execute a query on the pool.
 * @param {string} text - SQL query string
 * @param {Array} [params] - Query parameters
 * @returns {Promise<import('pg').QueryResult>}
 */
async function query(text, params) {
  const p = getPool();
  const start = Date.now();
  try {
    const res = await p.query(text, params);
    const duration = Date.now() - start;
    if (process.env.DEBUG_SQL === 'true') {
      console.log('Executed query', { text, duration, rows: res.rowCount });
    }
    return res;
  } catch (err) {
    console.error('❌ Database Query Error:', { text, params, error: err.message });
    throw err;
  }
}

/**
 * Gracefully close pool on shutdown.
 */
async function closeDb() {
  if (pool) {
    await pool.end();
    pool = null;
    console.log('📦 PostgreSQL Pool closed');
  }
}

// Graceful shutdown hooks
process.on('SIGINT', async () => {
  await closeDb();
  process.exit(0);
});

process.on('SIGTERM', async () => {
  await closeDb();
  process.exit(0);
});

module.exports = {
  getPool,
  query,
  closeDb,
  ensureDatabaseExists,
  config
};
