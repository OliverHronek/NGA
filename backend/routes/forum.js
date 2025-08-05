const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const forumController = require('../controllers/forumController');
const logger = require('../config/logger');

// Middleware to log all forum route access
router.use((req, res, next) => {
    logger.debug('Forum route accessed', {
        method: req.method,
        url: req.url,
        ip: req.ip,
        userAgent: req.get('User-Agent'),
        hasAuth: !!req.headers.authorization
    });
    next();
});

// Public routes (no authentication required)
router.get('/posts', forumController.getPosts);
router.get('/posts/:id', forumController.getPost);

// Protected routes (authentication required)
router.post('/posts/:postId/reactions', authenticateToken, forumController.toggleReaction);
router.post('/posts/:postId/comments', authenticateToken, forumController.addComment);

// Test route for debugging authentication
router.get('/test-auth', authenticateToken, (req, res) => {
    logger.info('Authentication test successful', {
        user: req.user,
        timestamp: new Date().toISOString()
    });
    
    res.json({
        success: true,
        message: 'Authentication working!',
        user: req.user,
        timestamp: new Date().toISOString()
    });
});

module.exports = router;
