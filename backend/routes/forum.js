const express = require('express');
const router = express.Router();
const forumController = require('../controllers/forumController'); // Use real controller
const { authenticateToken } = require('../middleware/auth');
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
router.get('/categories', forumController.getCategories);
router.get('/categories/:categoryId/posts', forumController.getPostsByCategory);
router.get('/posts/:id', forumController.getPostById);

// Protected routes (authentication required)
router.post('/categories', authenticateToken, forumController.createCategory);
router.post('/posts', authenticateToken, forumController.createPost);
router.post('/posts/:id/comments', authenticateToken, forumController.addComment);
router.post('/react', authenticateToken, forumController.toggleReaction);

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
