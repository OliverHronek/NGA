const express = require('express');
const router = express.Router();
const pollsController = require('../controllers/pollsController');
const { authenticateToken } = require('../middleware/auth');

// Öffentliche Routes (ohne Login)
// Alle öffentlichen Abstimmungen abrufen
router.get('/', pollsController.getAllPolls);

// Einzelne Abstimmung abrufen (mit optionaler Authentifizierung)
router.get('/:id', (req, res, next) => {
  // Optionale Authentifizierung - wenn Token vorhanden, Benutzer laden
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (token) {
    authenticateToken(req, res, (err) => {
      if (err) {
        // Bei ungültigem Token trotzdem fortfahren, nur ohne Benutzerinfo
        req.user = null;
      }
      next();
    });
  } else {
    next();
  }
}, pollsController.getPollById);

// Abstimmungsergebnisse abrufen (öffentlich)
router.get('/:id/results', pollsController.getPollResults);

// Geschützte Routes (Login erforderlich)
// Neue Abstimmung erstellen
router.post('/', authenticateToken, pollsController.createPoll);

// Abstimmen
router.post('/:id/vote', authenticateToken, pollsController.vote);

// Eigene Abstimmungen abrufen
router.get('/my/polls', authenticateToken, pollsController.getMyPolls);

// Poll bearbeiten (nur Creator)
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, isActive } = req.body;

    // Prüfen ob Benutzer der Creator ist
    const { pool } = require('../config/database');
    const pollCheck = await pool.query(
      'SELECT creator_id FROM polls WHERE id = $1',
      [id]
    );

    if (pollCheck.rows.length === 0) {
      return res.status(404).json({ error: 'Abstimmung nicht gefunden' });
    }

    if (pollCheck.rows[0].creator_id !== req.user.id) {
      return res.status(403).json({ error: 'Nicht berechtigt, diese Abstimmung zu bearbeiten' });
    }

    // Poll aktualisieren
    const result = await pool.query(`
      UPDATE polls 
      SET title = COALESCE($1, title), 
          description = COALESCE($2, description),
          is_active = COALESCE($3, is_active),
          updated_at = CURRENT_TIMESTAMP
      WHERE id = $4 
      RETURNING *
    `, [title, description, isActive, id]);

    res.json({
      message: 'Abstimmung erfolgreich aktualisiert',
      poll: result.rows[0]
    });

  } catch (error) {
    console.error('Poll bearbeiten Fehler:', error);
    res.status(500).json({ error: 'Fehler beim Bearbeiten der Abstimmung' });
  }
});

// Poll löschen (nur Creator)
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    // Prüfen ob Benutzer der Creator ist
    const { pool } = require('../config/database');
    const pollCheck = await pool.query(
      'SELECT creator_id FROM polls WHERE id = $1',
      [id]
    );

    if (pollCheck.rows.length === 0) {
      return res.status(404).json({ error: 'Abstimmung nicht gefunden' });
    }

    if (pollCheck.rows[0].creator_id !== req.user.id) {
      return res.status(403).json({ error: 'Nicht berechtigt, diese Abstimmung zu löschen' });
    }

    // Poll löschen (CASCADE löscht automatisch Optionen und Votes)
    await pool.query('DELETE FROM polls WHERE id = $1', [id]);

    res.json({ message: 'Abstimmung erfolgreich gelöscht' });

  } catch (error) {
    console.error('Poll löschen Fehler:', error);
    res.status(500).json({ error: 'Fehler beim Löschen der Abstimmung' });
  }
});

module.exports = router;
