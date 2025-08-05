require('dotenv').config();
const express = require('express');
const cors = require('cors');
const logger = require('./config/logger');

const app = express();
const PORT = process.env.PORT || 3000;

// Basic middleware
app.use(express.json());
app.use(cors({
    origin: 'http://localhost:8080',
    credentials: true
}));

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'OK', message: 'Server is running' });
});

// Try loading auth routes first
try {
    console.log('Loading auth routes...');
    const authRoutes = require('./routes/auth');
    app.use('/api/auth', authRoutes);
    console.log('✅ Auth routes loaded successfully');
} catch (error) {
    console.error('❌ Error loading auth routes:', error.message);
}

// Try loading forum routes
try {
    console.log('Loading forum routes...');
    const forumRoutes = require('./routes/forum');
    app.use('/api/forum', forumRoutes);
    console.log('✅ Forum routes loaded successfully');
} catch (error) {
    console.error('❌ Error loading forum routes:', error.message);
}

app.listen(PORT, () => {
    console.log(`✅ Server running on port ${PORT}`);
    logger.info(`Server running on port ${PORT}`);
});
