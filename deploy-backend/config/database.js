const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
  ssl: false // Disable SSL for this server
});

// Verbindung testen
pool.on('connect', (client) => {
  console.log('✅ Datenbankverbindung hergestellt');
});

pool.on('error', (err, client) => {
  console.error('❌ Datenbankfehler:', err);
});

// Test-Funktion
const testConnection = async () => {
  try {
    const client = await pool.connect();
    const result = await client.query('SELECT NOW() as current_time, version()');
    console.log('🕐 Datenbankzeit:', result.rows[0].current_time);
    console.log('📊 PostgreSQL Version:', result.rows[0].version.split(' ')[0]);
    client.release();
    return true;
  } catch (err) {
    console.error('❌ Datenbankverbindung fehlgeschlagen:', err.message);
    return false;
  }
};

module.exports = { pool, testConnection };
