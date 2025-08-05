const { pool } = require('../config/database');

const pollsController = {
  // Alle öffentlichen Abstimmungen abrufen
  getAllPolls: async (req, res) => {
    try {
      const result = await pool.query(`
        SELECT p.*, u.username as creator_name,
               COUNT(uv.id) as total_votes
        FROM polls p 
        LEFT JOIN users u ON p.creator_id = u.id
        LEFT JOIN user_votes uv ON p.id = uv.poll_id
        WHERE p.is_public = true AND p.is_active = true
        GROUP BY p.id, u.username
        ORDER BY p.created_at DESC
      `);

      res.json({
        polls: result.rows,
        count: result.rows.length
      });
    } catch (error) {
      console.error('Polls abrufen Fehler:', error);
      res.status(500).json({ error: 'Fehler beim Abrufen der Abstimmungen' });
    }
  },

  // Einzelne Abstimmung mit Optionen abrufen
  getPollById: async (req, res) => {
    try {
      const { id } = req.params;
      
      // Poll-Details abrufen
      const pollResult = await pool.query(`
        SELECT p.*, u.username as creator_name
        FROM polls p 
        LEFT JOIN users u ON p.creator_id = u.id
        WHERE p.id = $1
      `, [id]);

      if (pollResult.rows.length === 0) {
        return res.status(404).json({ error: 'Abstimmung nicht gefunden' });
      }

      // Poll-Optionen abrufen
      const optionsResult = await pool.query(`
        SELECT po.*, COUNT(uv.id) as vote_count
        FROM poll_options po
        LEFT JOIN user_votes uv ON po.id = uv.option_id
        WHERE po.poll_id = $1
        GROUP BY po.id
        ORDER BY po.option_order
      `, [id]);

      // Prüfen ob aktueller Benutzer bereits abgestimmt hat
      let userVote = null;
      if (req.user) {
        const voteResult = await pool.query(
          'SELECT option_id FROM user_votes WHERE user_id = $1 AND poll_id = $2',
          [req.user.id, id]
        );
        userVote = voteResult.rows.length > 0 ? voteResult.rows[0].option_id : null;
      }

      res.json({
        poll: pollResult.rows[0],
        options: optionsResult.rows,
        userVote: userVote,
        totalVotes: optionsResult.rows.reduce((sum, option) => sum + parseInt(option.vote_count), 0)
      });
    } catch (error) {
      console.error('Poll abrufen Fehler:', error);
      res.status(500).json({ error: 'Fehler beim Abrufen der Abstimmung' });
    }
  },

  // Neue Abstimmung erstellen
  createPoll: async (req, res) => {
    const client = await pool.connect();
    
    try {
      await client.query('BEGIN');
      
      const { title, description, options, pollType = 'multiple_choice', endDate, isPublic = true } = req.body;

      // Input Validation
      if (!title || !options || options.length < 2) {
        return res.status(400).json({ 
          error: 'Titel und mindestens 2 Optionen sind erforderlich' 
        });
      }

      // Poll erstellen
      const pollResult = await client.query(`
        INSERT INTO polls (title, description, creator_id, poll_type, end_date, is_public)
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING *
      `, [title, description, req.user.id, pollType, endDate, isPublic]);

      const newPoll = pollResult.rows[0];

      // Poll-Optionen erstellen
      const optionPromises = options.map((option, index) => 
        client.query(
          'INSERT INTO poll_options (poll_id, option_text, option_order) VALUES ($1, $2, $3) RETURNING *',
          [newPoll.id, option.text || option, index]
        )
      );

      const optionResults = await Promise.all(optionPromises);
      
      await client.query('COMMIT');

      res.status(201).json({
        message: 'Abstimmung erfolgreich erstellt',
        poll: newPoll,
        options: optionResults.map(result => result.rows[0])
      });

    } catch (error) {
      await client.query('ROLLBACK');
      console.error('Poll erstellen Fehler:', error);
      res.status(500).json({ error: 'Fehler beim Erstellen der Abstimmung' });
    } finally {
      client.release();
    }
  },

  // Abstimmen
  vote: async (req, res) => {
    try {
      const { id } = req.params; // poll_id
      const { optionId } = req.body;

      // Prüfen ob Poll existiert und aktiv ist
      const pollResult = await pool.query(
        'SELECT * FROM polls WHERE id = $1 AND is_active = true',
        [id]
      );

      if (pollResult.rows.length === 0) {
        return res.status(404).json({ error: 'Abstimmung nicht gefunden oder nicht aktiv' });
      }

      const poll = pollResult.rows[0];

      // Prüfen ob Poll noch läuft
      if (poll.end_date && new Date() > new Date(poll.end_date)) {
        return res.status(400).json({ error: 'Abstimmung ist bereits beendet' });
      }

      // Prüfen ob Option existiert
      const optionResult = await pool.query(
        'SELECT * FROM poll_options WHERE id = $1 AND poll_id = $2',
        [optionId, id]
      );

      if (optionResult.rows.length === 0) {
        return res.status(400).json({ error: 'Ungültige Abstimmungsoption' });
      }

      // Prüfen ob Benutzer bereits abgestimmt hat
      const existingVote = await pool.query(
        'SELECT * FROM user_votes WHERE user_id = $1 AND poll_id = $2',
        [req.user.id, id]
      );

      if (existingVote.rows.length > 0) {
        return res.status(400).json({ error: 'Sie haben bereits bei dieser Abstimmung teilgenommen' });
      }

      // Vote speichern
      const voteResult = await pool.query(
        'INSERT INTO user_votes (user_id, poll_id, option_id) VALUES ($1, $2, $3) RETURNING *',
        [req.user.id, id, optionId]
      );

      res.json({
        message: 'Stimme erfolgreich abgegeben',
        vote: voteResult.rows[0]
      });

    } catch (error) {
      console.error('Abstimmen Fehler:', error);
      res.status(500).json({ error: 'Fehler beim Abstimmen' });
    }
  },

  // Abstimmungsergebnisse abrufen
  getPollResults: async (req, res) => {
    try {
      const { id } = req.params;

      const result = await pool.query(`
        SELECT 
          po.id,
          po.option_text,
          po.option_order,
          COUNT(uv.id) as vote_count,
          ROUND(COUNT(uv.id) * 100.0 / NULLIF(total_votes.total, 0), 2) as percentage
        FROM poll_options po
        LEFT JOIN user_votes uv ON po.id = uv.option_id
        CROSS JOIN (
          SELECT COUNT(*) as total 
          FROM user_votes 
          WHERE poll_id = $1
        ) as total_votes
        WHERE po.poll_id = $1
        GROUP BY po.id, po.option_text, po.option_order, total_votes.total
        ORDER BY po.option_order
      `, [id]);

      const totalVotes = result.rows.reduce((sum, option) => sum + parseInt(option.vote_count), 0);

      res.json({
        results: result.rows,
        totalVotes: totalVotes,
        timestamp: new Date().toISOString()
      });

    } catch (error) {
      console.error('Ergebnisse abrufen Fehler:', error);
      res.status(500).json({ error: 'Fehler beim Abrufen der Ergebnisse' });
    }
  },

  // Benutzer's eigene Abstimmungen
  getMyPolls: async (req, res) => {
    try {
      const result = await pool.query(`
        SELECT p.*, COUNT(uv.id) as total_votes
        FROM polls p 
        LEFT JOIN user_votes uv ON p.id = uv.poll_id
        WHERE p.creator_id = $1
        GROUP BY p.id
        ORDER BY p.created_at DESC
      `, [req.user.id]);

      res.json({
        polls: result.rows,
        count: result.rows.length
      });
    } catch (error) {
      console.error('Meine Polls Fehler:', error);
      res.status(500).json({ error: 'Fehler beim Abrufen der eigenen Abstimmungen' });
    }
  }
};

module.exports = pollsController;
