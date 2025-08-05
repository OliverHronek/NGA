require('dotenv').config();
const express = require('express');
const logger = require('./config/logger');

const app = express();
const PORT = process.env.PORT || 3000;

// Basic middleware
app.use(express.json());

// Simple test route
app.get('/health', (req, res) => {
    res.json({ status: 'OK', message: 'Basic server working' });
});

// Start server
app.listen(PORT, () => {
    logger.info(`Basic test server running on port ${PORT}`);
    console.log(`Basic test server running on port ${PORT}`);
});
