const { Pool } = require('pg');
const logger = require('../config/logger');

// Database connection
const pool = new Pool({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    database: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
});

const forumController = {
    // Get all forum posts
    async getPosts(req, res) {
        try {
            logger.debug('Getting forum posts', { userId: req.user?.id });
            
            const query = `
                SELECT 
                    fp.*,
                    u.username,
                    u.first_name,
                    u.last_name,
                    (SELECT COUNT(*) FROM forum_reactions fr WHERE fr.post_id = fp.id AND fr.type = 'like') as like_count,
                    (SELECT COUNT(*) FROM forum_comments fc WHERE fc.post_id = fp.id) as comment_count
                FROM forum_posts fp
                JOIN users u ON fp.user_id = u.id
                ORDER BY fp.created_at DESC
            `;
            
            const result = await pool.query(query);
            logger.info(`Retrieved ${result.rows.length} forum posts`);
            
            res.json(result.rows);
        } catch (error) {
            logger.error('Error getting forum posts', { error: error.message, stack: error.stack });
            res.status(500).json({ error: 'Internal server error' });
        }
    },

    // Get single post with comments
    async getPost(req, res) {
        try {
            const { id } = req.params;
            logger.debug('Getting forum post', { postId: id, userId: req.user?.id });
            
            // Get post
            const postQuery = `
                SELECT 
                    fp.*,
                    u.username,
                    u.first_name,
                    u.last_name,
                    (SELECT COUNT(*) FROM forum_reactions fr WHERE fr.post_id = fp.id AND fr.type = 'like') as like_count
                FROM forum_posts fp
                JOIN users u ON fp.user_id = u.id
                WHERE fp.id = $1
            `;
            
            const postResult = await pool.query(postQuery, [id]);
            
            if (postResult.rows.length === 0) {
                return res.status(404).json({ error: 'Post not found' });
            }
            
            // Get comments
            const commentsQuery = `
                SELECT 
                    fc.*,
                    u.username,
                    u.first_name,
                    u.last_name
                FROM forum_comments fc
                JOIN users u ON fc.user_id = u.id
                WHERE fc.post_id = $1
                ORDER BY fc.created_at ASC
            `;
            
            const commentsResult = await pool.query(commentsQuery, [id]);
            
            const post = postResult.rows[0];
            post.comments = commentsResult.rows;
            
            logger.info('Retrieved forum post with comments', { 
                postId: id, 
                commentCount: commentsResult.rows.length 
            });
            
            res.json(post);
        } catch (error) {
            logger.error('Error getting forum post', { 
                error: error.message, 
                stack: error.stack,
                postId: req.params.id 
            });
            res.status(500).json({ error: 'Internal server error' });
        }
    },

    // Toggle reaction (like/unlike)
    async toggleReaction(req, res) {
        try {
            const { postId } = req.params;
            const userId = req.user.id;
            const { type = 'like' } = req.body;
            
            logger.debug('Toggle reaction attempt', {
                postId: postId,
                userId: userId,
                type: type,
                userObject: req.user,
                requestBody: req.body,
                headers: req.headers
            });

            // Check if reaction already exists
            const existingQuery = `
                SELECT id FROM forum_reactions 
                WHERE post_id = $1 AND user_id = $2 AND type = $3
            `;
            
            const existingResult = await pool.query(existingQuery, [postId, userId, type]);
            
            logger.debug('Existing reaction check', {
                postId: postId,
                userId: userId,
                existingCount: existingResult.rows.length,
                existingReaction: existingResult.rows[0]
            });

            if (existingResult.rows.length > 0) {
                // Remove existing reaction
                const deleteQuery = `
                    DELETE FROM forum_reactions 
                    WHERE post_id = $1 AND user_id = $2 AND type = $3
                `;
                
                await pool.query(deleteQuery, [postId, userId, type]);
                
                logger.info('Reaction removed', {
                    postId: postId,
                    userId: userId,
                    type: type,
                    action: 'removed'
                });
                
                res.json({ 
                    success: true, 
                    action: 'removed',
                    postId: postId,
                    userId: userId
                });
            } else {
                // Add new reaction
                const insertQuery = `
                    INSERT INTO forum_reactions (post_id, user_id, type, created_at)
                    VALUES ($1, $2, $3, NOW())
                    RETURNING id, created_at
                `;
                
                const insertResult = await pool.query(insertQuery, [postId, userId, type]);
                
                logger.info('Reaction added', {
                    postId: postId,
                    userId: userId,
                    type: type,
                    action: 'added',
                    reactionId: insertResult.rows[0].id
                });
                
                res.json({ 
                    success: true, 
                    action: 'added',
                    postId: postId,
                    userId: userId,
                    reactionId: insertResult.rows[0].id
                });
            }
        } catch (error) {
            logger.error('Error toggling reaction', {
                error: error.message,
                stack: error.stack,
                postId: req.params.postId,
                userId: req.user?.id,
                requestBody: req.body
            });
            res.status(500).json({ error: 'Internal server error' });
        }
    },

    // Add comment
    async addComment(req, res) {
        try {
            const { postId } = req.params;
            const { content } = req.body;
            const userId = req.user.id;
            
            logger.debug('Adding comment', {
                postId: postId,
                userId: userId,
                contentLength: content?.length
            });
            
            if (!content || content.trim().length === 0) {
                return res.status(400).json({ error: 'Content is required' });
            }
            
            const query = `
                INSERT INTO forum_comments (post_id, user_id, content, created_at)
                VALUES ($1, $2, $3, NOW())
                RETURNING id, created_at
            `;
            
            const result = await pool.query(query, [postId, userId, content.trim()]);
            
            logger.info('Comment added successfully', {
                commentId: result.rows[0].id,
                postId: postId,
                userId: userId
            });
            
            res.json({
                success: true,
                commentId: result.rows[0].id,
                createdAt: result.rows[0].created_at
            });
        } catch (error) {
            logger.error('Error adding comment', {
                error: error.message,
                stack: error.stack,
                postId: req.params.postId,
                userId: req.user?.id
            });
            res.status(500).json({ error: 'Internal server error' });
        }
    }
};

module.exports = forumController;
