const jwt = require('jsonwebtoken');
const logger = require('../config/logger');

const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    logger.debug('Authentication attempt', {
        headers: req.headers,
        authHeader: authHeader,
        token: token ? 'TOKEN_PRESENT' : 'NO_TOKEN',
        url: req.url,
        method: req.method
    });

    if (!token) {
        logger.warn('Access denied: No token provided', {
            ip: req.ip,
            userAgent: req.get('User-Agent'),
            url: req.url
        });
        return res.status(401).json({ 
            error: 'Access denied. No token provided.' 
        });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded;
        
        logger.debug('Token verified successfully', {
            userId: decoded.id,
            username: decoded.username,
            email: decoded.email,
            tokenExp: new Date(decoded.exp * 1000),
            url: req.url
        });

        next();
    } catch (error) {
        logger.error('Token verification failed', {
            error: error.message,
            token: token ? 'TOKEN_PRESENT' : 'NO_TOKEN',
            ip: req.ip,
            userAgent: req.get('User-Agent'),
            url: req.url
        });

        if (error.name === 'TokenExpiredError') {
            return res.status(401).json({ 
                error: 'Token expired.' 
            });
        } else if (error.name === 'JsonWebTokenError') {
            return res.status(401).json({ 
                error: 'Invalid token.' 
            });
        } else {
            return res.status(500).json({ 
                error: 'Token verification failed.' 
            });
        }
    }
};

module.exports = {
    authenticateToken
};
