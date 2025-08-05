const jwt = require('jsonwebtoken');
const logger = require('../config/logger');
const { pool } = require('../config/database');

// Real authentication middleware with database integration
const authenticateToken = async (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN
  
  if (!token) {
    logger.debug('No token provided');
    return res.status(401).json({ error: 'Access Token erforderlich' });
  }
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    logger.debug('Token decoded successfully', { decoded });
    
    // Fetch user from database
    const userResult = await pool.query(
      'SELECT id, username, email, first_name, last_name, is_verified FROM users WHERE id = $1',
      [decoded.id || decoded.userId]
    );
    
    if (userResult.rows.length === 0) {
      logger.debug('User not found in database', { userId: decoded.id || decoded.userId });
      return res.status(403).json({ error: 'Benutzer nicht gefunden' });
    }
    
    const user = userResult.rows[0];
    
    req.user = {
      id: user.id,
      userId: user.id,
      username: user.username,
      email: user.email,
      firstName: user.first_name,
      lastName: user.last_name,
      isVerified: user.is_verified
    };
    
    logger.debug('User authenticated successfully', { user: req.user });
    
    next();
  } catch (error) {
    logger.debug('Token verification failed', { error: error.message });
    return res.status(403).json({ error: 'Ungültiger Token' });
  }
};

module.exports = { authenticateToken };
