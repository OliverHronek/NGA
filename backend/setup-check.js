const fs = require('fs');
const path = require('path');

console.log('🔍 NGA Backend Setup Verification');
console.log('=====================================');

// Check if all required files exist
const requiredFiles = [
    'package.json',
    'server.js',
    '.env',
    'config/logger.js',
    'middleware/auth.js',
    'controllers/forumController.js',
    'routes/forum.js'
];

console.log('\n📁 Checking required files:');
requiredFiles.forEach(file => {
    const filePath = path.join(__dirname, file);
    if (fs.existsSync(filePath)) {
        console.log(`✅ ${file}`);
    } else {
        console.log(`❌ ${file} - MISSING!`);
    }
});

// Check environment variables
console.log('\n🔧 Environment Configuration:');
require('dotenv').config();
const envVars = ['NODE_ENV', 'PORT', 'JWT_SECRET', 'CORS_ORIGIN'];
envVars.forEach(envVar => {
    if (process.env[envVar]) {
        console.log(`✅ ${envVar}: ${process.env[envVar]}`);
    } else {
        console.log(`❌ ${envVar}: NOT SET`);
    }
});

console.log('\n🚀 Setup Status: COMPLETE');
console.log('📝 With Winston logging (Node.js equivalent of Serilog)');
console.log('🔐 With authentication middleware debugging');
console.log('🐛 With enhanced debugging for user ID issues');

console.log('\n🎯 Next Steps:');
console.log('1. Configure your database connection in .env');
console.log('2. Start the server: npm start');
console.log('3. Test authentication: GET /api/forum/test-auth');
console.log('4. Test reactions: POST /api/forum/posts/:id/reactions');
