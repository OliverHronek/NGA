const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { Pool } = require('pg');
const router = express.Router();
const logger = require('../config/logger');
const { authenticateToken } = require('../middleware/auth');

// Database connection
const pool = new Pool({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    database: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
});

// Login endpoint
router.post('/login', async (req, res) => {
    try {
        const { username, password } = req.body;
        
        logger.debug('Login attempt', {
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

        // Find user in database
        const userQuery = `
            SELECT id, username, email, password_hash, first_name, last_name, is_active
            FROM users 
            WHERE username = $1 OR email = $1
        `;
        
        const userResult = await pool.query(userQuery, [username]);
        
        if (userResult.rows.length === 0) {
            logger.warn('Login failed: User not found', { username });
            return res.status(401).json({
                error: 'Invalid credentials'
            });
        }

        const user = userResult.rows[0];

        // Check if user is active
        if (!user.is_active) {
            logger.warn('Login failed: User inactive', { username, userId: user.id });
            return res.status(401).json({
                error: 'Account is inactive'
            });
        }

        // Verify password
        const isPasswordValid = await bcrypt.compare(password, user.password_hash);
        
        if (!isPasswordValid) {
            logger.warn('Login failed: Invalid password', { username, userId: user.id });
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

        // Update last login
        await pool.query(
            'UPDATE users SET last_login = NOW() WHERE id = $1',
            [user.id]
        );

        logger.info('Login successful', {
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
                firstName: user.first_name,
                lastName: user.last_name
            }
        });

    } catch (error) {
        logger.error('Login error', {
            error: error.message,
            stack: error.stack,
            username: req.body?.username
        });
        
        res.status(500).json({
            error: 'Internal server error'
        });
    }
});

// Register endpoint
router.post('/register', async (req, res) => {
    try {
        const { username, email, password, firstName, lastName } = req.body;
        
        logger.debug('Registration attempt', {
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
        const existingUserQuery = `
            SELECT id FROM users 
            WHERE username = $1 OR email = $2
        `;
        
        const existingUser = await pool.query(existingUserQuery, [username, email]);
        
        if (existingUser.rows.length > 0) {
            logger.warn('Registration failed: User already exists', { username, email });
            return res.status(400).json({
                error: 'Username or email already exists'
            });
        }

        // Hash password
        const saltRounds = 12;
        const passwordHash = await bcrypt.hash(password, saltRounds);

        // Insert new user
        const insertUserQuery = `
            INSERT INTO users (username, email, password_hash, first_name, last_name, created_at, is_active)
            VALUES ($1, $2, $3, $4, $5, NOW(), true)
            RETURNING id, username, email, first_name, last_name
        `;
        
        const newUser = await pool.query(insertUserQuery, [
            username,
            email,
            passwordHash,
            firstName || null,
            lastName || null
        ]);

        const user = newUser.rows[0];

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

        logger.info('Registration successful', {
            userId: user.id,
            username: user.username,
            email: user.email
        });

        // Return success response
        res.status(201).json({
            success: true,
            token: token,
            user: {
                id: user.id,
                username: user.username,
                email: user.email,
                firstName: user.first_name,
                lastName: user.last_name
            }
        });

    } catch (error) {
        logger.error('Registration error', {
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

// Profile endpoint (protected)
router.get('/profile', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.id;
        
        logger.debug('Profile request', { userId });

        // Get user profile
        const userQuery = `
            SELECT id, username, email, first_name, last_name, created_at, last_login
            FROM users 
            WHERE id = $1 AND is_active = true
        `;
        
        const userResult = await pool.query(userQuery, [userId]);
        
        if (userResult.rows.length === 0) {
            return res.status(404).json({
                error: 'User not found'
            });
        }

        const user = userResult.rows[0];

        logger.info('Profile retrieved', { userId });

        res.json({
            success: true,
            user: {
                id: user.id,
                username: user.username,
                email: user.email,
                firstName: user.first_name,
                lastName: user.last_name,
                createdAt: user.created_at,
                lastLogin: user.last_login
            }
        });

    } catch (error) {
        logger.error('Profile error', {
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
