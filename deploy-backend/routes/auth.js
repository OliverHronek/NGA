const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { authenticateToken } = require('../middleware/auth');

// Registrierung
router.post('/register', authController.register);

// Login
router.post('/login', authController.login);

// ========== NEUE EMAIL-VERIFIZIERUNG ==========
// Email-Verifizierung senden
router.post('/send-verification', authenticateToken, authController.sendVerification);

// Email-Verifizierung bestätigen
router.post('/verify-email', authController.verifyEmail);

// Profil aktualisieren
router.put('/update-profile', authenticateToken, authController.updateProfile);

// Passwort ändern
router.put('/change-password', authenticateToken, authController.changePassword);

// Profil abrufen (geschützt)
router.get('/profile', authenticateToken, async (req, res) => {
  try {
    const { pool } = require('../config/database');
    const result = await pool.query(
      `SELECT id, username, email, first_name, last_name, is_verified, email_verified_at, created_at
       FROM users WHERE id = $1`,
      [req.user.userId] // ← KORRIGIERT von req.user.id zu req.user.userId
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Benutzer nicht gefunden' });
    }
    res.json({ user: result.rows[0] });
  } catch (error) {
    console.error('Profil abrufen Fehler:', error);
    res.status(500).json({ error: 'Serverfehler beim Abrufen des Profils' });
  }
});

module.exports = router;
