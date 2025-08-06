const express = require('express');
const jwt = require('jsonwebtoken');
const router = express.Router();
const logger = require('../config/logger');
const { authenticateToken } = require('../middleware/auth');

// Mock users database (for development only)
const mockUsers = [
    {
        id: 1,
        username: 'oliver',
        email: 'oliver@nga.at',
        password: 'password123', // In real app, this would be hashed
        firstName: 'Oliver',
        lastName: 'Hronek',
        isActive: true
    },
    {
        id: 2,
        username: 'testuser',
        email: 'test@nga.at',
        password: 'password123',
        firstName: 'Test',
        lastName: 'User',
        isActive: true
    }
];

// Mock forum posts
const mockPosts = [
    {
        id: 1,
        user_id: 1,
        title: 'Welcome to NGA Forum',
        content: 'This is a test post for local development.',
        username: 'oliver',
        first_name: 'Oliver',
        last_name: 'Hronek',
        like_count: 5,
        comment_count: 2,
        created_at: new Date().toISOString()
    }
];

// Login endpoint (mock)
router.post('/login', async (req, res) => {
    try {
        const { username, password } = req.body;
        
        logger.debug('Mock login attempt', {
            username: username,
            hasPassword: !!password,
            ip: req.ip
        });

        // Validate input
        if (!username || !password) {
            return res.status(400).json({
                error: 'Username and password are required'
            });
        }

        // Find user in mock database
        const user = mockUsers.find(u => 
            (u.username === username || u.email === username) && u.isActive
        );
        
        if (!user) {
            logger.warn('Mock login failed: User not found', { username });
            return res.status(401).json({
                error: 'Invalid credentials'
            });
        }

        // Check password (in real app, use bcrypt.compare)
        if (user.password !== password) {
            logger.warn('Mock login failed: Invalid password', { username, userId: user.id });
            return res.status(401).json({
                error: 'Invalid credentials'
            });
        }

        // Generate JWT token
        const token = jwt.sign(
            {
                id: user.id,
                username: user.username,
                email: user.email
            },
            process.env.JWT_SECRET,
            { expiresIn: process.env.JWT_EXPIRES_IN || '24h' }
        );

        logger.info('Mock login successful', {
            userId: user.id,
            username: user.username,
            email: user.email
        });

        // Return success response
        res.json({
            success: true,
            token: token,
            user: {
                id: user.id,
                username: user.username,
                email: user.email,
                firstName: user.firstName,
                lastName: user.lastName
            }
        });

    } catch (error) {
        logger.error('Mock login error', {
            error: error.message,
            stack: error.stack,
            username: req.body?.username
        });
        
        res.status(500).json({
            error: 'Internal server error'
        });
    }
});

// Register endpoint (mock)
router.post('/register', async (req, res) => {
    try {
        const { username, email, password, firstName, lastName } = req.body;
        
        logger.debug('Mock registration attempt', {
            username: username,
            email: email,
            hasPassword: !!password,
            ip: req.ip
        });

        // Validate input
        if (!username || !email || !password) {
            return res.status(400).json({
                error: 'Username, email, and password are required'
            });
        }

        // Check if user already exists
        const existingUser = mockUsers.find(u => 
            u.username === username || u.email === email
        );
        
        if (existingUser) {
            logger.warn('Mock registration failed: User already exists', { username, email });
            return res.status(400).json({
                error: 'Username or email already exists'
            });
        }

        // Create new user
        const newUser = {
            id: mockUsers.length + 1,
            username,
            email,
            password, // In real app, hash this
            firstName: firstName || null,
            lastName: lastName || null,
            isActive: true
        };

        mockUsers.push(newUser);

        // Generate JWT token
        const token = jwt.sign(
            {
                id: newUser.id,
                username: newUser.username,
                email: newUser.email
            },
            process.env.JWT_SECRET,
            { expiresIn: process.env.JWT_EXPIRES_IN || '24h' }
        );

        logger.info('Mock registration successful', {
            userId: newUser.id,
            username: newUser.username,
            email: newUser.email
        });

        // Return success response
        res.status(201).json({
            success: true,
            token: token,
            user: {
                id: newUser.id,
                username: newUser.username,
                email: newUser.email,
                firstName: newUser.firstName,
                lastName: newUser.lastName
            }
        });

    } catch (error) {
        logger.error('Mock registration error', {
            error: error.message,
            stack: error.stack,
            username: req.body?.username,
            email: req.body?.email
        });
        
        res.status(500).json({
            error: 'Internal server error'
        });
    }
});

// Profile endpoint (mock)
router.get('/profile', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.id;
        
        logger.debug('Mock profile request', { userId });

        // Find user in mock database
        const user = mockUsers.find(u => u.id === userId && u.isActive);
        
        if (!user) {
            return res.status(404).json({
                error: 'User not found'
            });
        }

        logger.info('Mock profile retrieved', { userId });

        res.json({
            success: true,
            user: {
                id: user.id,
                username: user.username,
                email: user.email,
                firstName: user.firstName,
                lastName: user.lastName,
                createdAt: new Date().toISOString(),
                lastLogin: new Date().toISOString()
            }
        });

    } catch (error) {
        logger.error('Mock profile error', {
            error: error.message,
            stack: error.stack,
            userId: req.user?.id
        });
        
        res.status(500).json({
            error: 'Internal server error'
        });
    }
});

module.exports = router;
