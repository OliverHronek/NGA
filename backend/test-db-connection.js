require('dotenv').config();
const { testConnection } = require('./config/database');

console.log('=== DATABASE CONNECTION TEST ===');
console.log('Host:', process.env.DB_HOST);
console.log('Port:', process.env.DB_PORT);
console.log('Database:', process.env.DB_NAME);
console.log('User:', process.env.DB_USER);
console.log('SSL:', process.env.DB_HOST !== 'localhost' ? 'Enabled (ignore certificates)' : 'Disabled');
console.log('================================');

testConnection()
  .then(success => {
    if (success) {
      console.log('✅ Database connection test PASSED');
      process.exit(0);
    } else {
      console.log('❌ Database connection test FAILED');
      process.exit(1);
    }
  })
  .catch(error => {
    console.error('❌ Database connection test ERROR:', error.message);
    process.exit(1);
  });
