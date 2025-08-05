const { pool } = require('../config/database');

const forumController = {
  // Alle Forum-Kategorien abrufen
  getCategories: async (req, res) => {
    try {
      const result = await pool.query(`
        SELECT c.*, COUNT(fp.id) as post_count
        FROM forum_categories c
        LEFT JOIN forum_posts fp ON c.id = fp.category_id
        GROUP BY c.id
        ORDER BY c.created_at ASC
      `);

      res.json({
        categories: result.rows,
        count: result.rows.length
      });
    } catch (error) {
      console.error('Kategorien abrufen Fehler:', error);
      res.status(500).json({ error: 'Fehler beim Abrufen der Kategorien' });
    }
  },

  // Posts einer Kategorie abrufen
  getPostsByCategory: async (req, res) => {
    try {
      const { categoryId } = req.params;
      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 20;
      const offset = (page - 1) * limit;

      const result = await pool.query(`
        SELECT 
          fp.*,
          u.username as author_name,
          COUNT(fc.id) as comment_count,
          COUNT(r.id) as like_count
        FROM forum_posts fp
        LEFT JOIN users u ON fp.user_id = u.id
        LEFT JOIN forum_comments fc ON fp.id = fc.post_id
        LEFT JOIN reactions r ON (r.target_type = 'post' AND r.target_id = fp.id AND r.reaction_type = 'like')
        WHERE fp.category_id = $1
        GROUP BY fp.id, u.username
        ORDER BY fp.is_pinned DESC, fp.created_at DESC
        LIMIT $2 OFFSET $3
      `, [categoryId, limit, offset]);

      // Gesamtanzahl für Pagination
      const countResult = await pool.query(
        'SELECT COUNT(*) FROM forum_posts WHERE category_id = $1',
        [categoryId]
      );

      res.json({
        posts: result.rows,
        pagination: {
          page: page,
          limit: limit,
          total: parseInt(countResult.rows[0].count),
          pages: Math.ceil(countResult.rows[0].count / limit)
        }
      });
    } catch (error) {
      console.error('Posts abrufen Fehler:', error);
      res.status(500).json({ error: 'Fehler beim Abrufen der Posts' });
    }
  },

  // Einzelnen Post mit Kommentaren abrufen
  getPostById: async (req, res) => {
    try {
      const { id } = req.params;

      // Post-Details abrufen
      const postResult = await pool.query(`
        SELECT 
          fp.*,
          u.username as author_name,
          fc.name as category_name
        FROM forum_posts fp
        LEFT JOIN users u ON fp.user_id = u.id
        LEFT JOIN forum_categories fc ON fp.category_id = fc.id
        WHERE fp.id = $1
      `, [id]);

      if (postResult.rows.length === 0) {
        return res.status(404).json({ error: 'Post nicht gefunden' });
      }

      // Views erhöhen
      await pool.query(
        'UPDATE forum_posts SET views_count = views_count + 1 WHERE id = $1',
        [id]
      );

      // Kommentare abrufen
      const commentsResult = await pool.query(`
        SELECT 
          fc.*,
          u.username as author_name,
          COUNT(r.id) as like_count
        FROM forum_comments fc
        LEFT JOIN users u ON fc.user_id = u.id
        LEFT JOIN reactions r ON (r.target_type = 'comment' AND r.target_id = fc.id AND r.reaction_type = 'like')
        WHERE fc.post_id = $1
        GROUP BY fc.id, u.username
        ORDER BY fc.created_at ASC
      `, [id]);

      // Reactions für Post
      const postReactionsResult = await pool.query(`
        SELECT reaction_type, COUNT(*) as count
        FROM reactions 
        WHERE target_type = 'post' AND target_id = $1
        GROUP BY reaction_type
      `, [id]);

      const reactions = {};
      postReactionsResult.rows.forEach(row => {
        reactions[row.reaction_type] = parseInt(row.count);
      });

      res.json({
        post: postResult.rows[0],
        comments: commentsResult.rows,
        reactions: reactions,
        commentCount: commentsResult.rows.length
      });
    } catch (error) {
      console.error('Post abrufen Fehler:', error);
      res.status(500).json({ error: 'Fehler beim Abrufen des Posts' });
    }
  },

  // Neuen Post erstellen
  createPost: async (req, res) => {
    try {
      const { categoryId, title, content } = req.body;

      if (!categoryId || !title || !content) {
        return res.status(400).json({ 
          error: 'Kategorie, Titel und Inhalt sind erforderlich' 
        });
      }

      // Prüfen ob Kategorie existiert
      const categoryCheck = await pool.query(
        'SELECT id FROM forum_categories WHERE id = $1',
        [categoryId]
      );

      if (categoryCheck.rows.length === 0) {
        return res.status(400).json({ error: 'Kategorie nicht gefunden' });
      }

      // Post erstellen
      const result = await pool.query(`
        INSERT INTO forum_posts (category_id, user_id, title, content)
        VALUES ($1, $2, $3, $4)
        RETURNING *
      `, [categoryId, req.user.id, title, content]);

      res.status(201).json({
        message: 'Post erfolgreich erstellt',
        post: result.rows[0]
      });

    } catch (error) {
      console.error('Post erstellen Fehler:', error);
      res.status(500).json({ error: 'Fehler beim Erstellen des Posts' });
    }
  },

  // Kommentar zu Post hinzufügen
  addComment: async (req, res) => {
    try {
      const { id } = req.params; // post_id
      const { content, parentCommentId = null } = req.body;

      if (!content) {
        return res.status(400).json({ error: 'Kommentar-Inhalt ist erforderlich' });
      }

      // Prüfen ob Post existiert
      const postCheck = await pool.query(
        'SELECT id FROM forum_posts WHERE id = $1',
        [id]
      );

      if (postCheck.rows.length === 0) {
        return res.status(404).json({ error: 'Post nicht gefunden' });
      }

      // Kommentar erstellen
      const result = await pool.query(`
        INSERT INTO forum_comments (post_id, user_id, content, parent_comment_id)
        VALUES ($1, $2, $3, $4)
        RETURNING *
      `, [id, req.user.id, content, parentCommentId]);

      res.status(201).json({
        message: 'Kommentar erfolgreich hinzugefügt',
        comment: result.rows[0]
      });

    } catch (error) {
      console.error('Kommentar erstellen Fehler:', error);
      res.status(500).json({ error: 'Fehler beim Erstellen des Kommentars' });
    }
  },

  // Reaction hinzufügen/entfernen (Like/Dislike)
  toggleReaction: async (req, res) => {
    try {
		
	console.log('=== DEBUG: toggleReaction Backend ===');
    console.log('DEBUG: req.headers.authorization =', req.headers.authorization);
    console.log('DEBUG: req.user =', req.user);
    console.log('DEBUG: req.body =', req.body);
	console.log('DEBUG: req.userid =', req.user.id);
    
    const { targetType, targetId, reactionType = 'like' } = req.body;

    if (!req.user) {
      console.log('ERROR: req.user is null/undefined');
      return res.status(401).json({ error: 'Not authenticated - req.user missing' });
    }

    console.log('DEBUG: Using user ID from token:', req.user.id);
  
  
      //const { targetType, targetId, reactionType = 'like' } = req.body;

      if (!targetType || !targetId || !['post', 'comment'].includes(targetType)) {
        return res.status(400).json({ error: 'Ungültige Reaction-Parameter' });
      }

      // Prüfen ob bereits eine Reaction existiert
      const existingReaction = await pool.query(
        'SELECT * FROM reactions WHERE user_id = $1 AND target_type = $2 AND target_id = $3',
        [req.user.id, targetType, targetId]
      );

      if (existingReaction.rows.length > 0) {
        // Reaction entfernen wenn gleicher Typ, oder ändern
        const existing = existingReaction.rows[0];
        
        if (existing.reaction_type === reactionType) {
          // Entfernen
          await pool.query(
            'DELETE FROM reactions WHERE id = $1',
            [existing.id]
          );
          
          res.json({ 
            message: 'Reaction entfernt',
            action: 'removed'
          });
        } else {
          // Ändern
          await pool.query(
            'UPDATE reactions SET reaction_type = $1 WHERE id = $2',
            [reactionType, existing.id]
          );
          
          res.json({ 
            message: 'Reaction geändert',
            action: 'changed',
            newType: reactionType
          });
        }
      } else {
        // Neue Reaction hinzufügen
        const result = await pool.query(`
          INSERT INTO reactions (user_id, target_type, target_id, reaction_type)
          VALUES ($1, $2, $3, $4)
          RETURNING *
        `, [req.user.id, targetType, targetId, reactionType]);

        res.json({
          message: 'Reaction hinzugefügt',
          action: 'added',
          reaction: result.rows[0]
        });
      }

    } catch (error) {
      console.error('Reaction Fehler:', error);
      res.status(500).json({ error: 'Fehler beim Verarbeiten der Reaction' });
    }
  },

  // Kategorie erstellen (Admin-Funktion)
  createCategory: async (req, res) => {
    try {
      const { name, description, color = '#007AFF' } = req.body;

      if (!name) {
        return res.status(400).json({ error: 'Kategorie-Name ist erforderlich' });
      }

      const result = await pool.query(`
        INSERT INTO forum_categories (name, description, color)
        VALUES ($1, $2, $3)
        RETURNING *
      `, [name, description, color]);

      res.status(201).json({
        message: 'Kategorie erfolgreich erstellt',
        category: result.rows[0]
      });

    } catch (error) {
      console.error('Kategorie erstellen Fehler:', error);
      res.status(500).json({ error: 'Fehler beim Erstellen der Kategorie' });
    }
  }
};

module.exports = forumController;
