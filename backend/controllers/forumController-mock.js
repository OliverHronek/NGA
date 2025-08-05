const logger = require('../config/logger');

// Mock forum data
const mockCategories = [
    {
        id: 1,
        name: 'General Discussion',
        description: 'General topics and discussions',
        post_count: 15,
        created_at: new Date('2025-01-01').toISOString()
    },
    {
        id: 2,
        name: 'Technical Support',
        description: 'Get help with technical issues',
        post_count: 8,
        created_at: new Date('2025-01-01').toISOString()
    },
    {
        id: 3,
        name: 'Announcements',
        description: 'Important announcements and news',
        post_count: 3,
        created_at: new Date('2025-01-01').toISOString()
    }
];

const mockPosts = [
    {
        id: 1,
        user_id: 1,
        title: 'Welcome to NGA Forum',
        content: 'This is a test post for local development. You can like and comment on this post to test the functionality.',
        username: 'oliver',
        first_name: 'Oliver',
        last_name: 'Hronek',
        like_count: 5,
        comment_count: 2,
        created_at: new Date('2025-08-01').toISOString()
    },
    {
        id: 2,
        user_id: 2,
        title: 'Forum Features',
        content: 'This forum supports likes, comments, and user authentication. All data is currently mocked for development.',
        username: 'testuser',
        first_name: 'Test',
        last_name: 'User',
        like_count: 3,
        comment_count: 1,
        created_at: new Date('2025-08-02').toISOString()
    }
];

const mockComments = [
    {
        id: 1,
        post_id: 1,
        user_id: 2,
        content: 'Great to see the forum working!',
        username: 'testuser',
        first_name: 'Test',
        last_name: 'User',
        created_at: new Date('2025-08-01T10:00:00').toISOString()
    },
    {
        id: 2,
        post_id: 1,
        user_id: 1,
        content: 'Thanks for testing!',
        username: 'oliver',
        first_name: 'Oliver',
        last_name: 'Hronek',
        created_at: new Date('2025-08-01T10:30:00').toISOString()
    }
];

const mockReactions = [
    { id: 1, post_id: 1, user_id: 1, type: 'like' },
    { id: 2, post_id: 1, user_id: 2, type: 'like' },
    { id: 3, post_id: 2, user_id: 1, type: 'like' }
];

const forumController = {
    // Get all forum categories
    async getCategories(req, res) {
        try {
            logger.debug('Getting mock forum categories', { userId: req.user?.id });
            
            logger.info(`Retrieved ${mockCategories.length} mock forum categories`);
            
            res.json({
                success: true,
                data: {
                    categories: mockCategories
                }
            });
        } catch (error) {
            logger.error('Error getting mock forum categories', { error: error.message, stack: error.stack });
            res.status(500).json({ error: 'Internal server error' });
        }
    },

    // Get all forum posts
    async getPosts(req, res) {
        try {
            logger.debug('Getting mock forum posts', { userId: req.user?.id });
            
            logger.info(`Retrieved ${mockPosts.length} mock forum posts`);
            
            res.json(mockPosts);
        } catch (error) {
            logger.error('Error getting mock forum posts', { error: error.message, stack: error.stack });
            res.status(500).json({ error: 'Internal server error' });
        }
    },

    // Get single post with comments
    async getPost(req, res) {
        try {
            const { id } = req.params;
            const postId = parseInt(id);
            
            logger.debug('Getting mock forum post', { postId: postId, userId: req.user?.id });
            
            // Find post
            const post = mockPosts.find(p => p.id === postId);
            
            if (!post) {
                return res.status(404).json({ error: 'Post not found' });
            }
            
            // Get comments for this post
            const comments = mockComments.filter(c => c.post_id === postId);
            
            const postWithComments = {
                ...post,
                comments: comments
            };
            
            logger.info('Retrieved mock forum post with comments', { 
                postId: postId, 
                commentCount: comments.length 
            });
            
            res.json(postWithComments);
        } catch (error) {
            logger.error('Error getting mock forum post', { 
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
            const postIdInt = parseInt(postId);
            
            logger.debug('Toggle mock reaction attempt', {
                postId: postIdInt,
                userId: userId,
                type: type,
                userObject: req.user,
                requestBody: req.body,
                headers: req.headers
            });

            // Check if reaction already exists
            const existingReactionIndex = mockReactions.findIndex(
                r => r.post_id === postIdInt && r.user_id === userId && r.type === type
            );
            
            logger.debug('Existing mock reaction check', {
                postId: postIdInt,
                userId: userId,
                existingIndex: existingReactionIndex,
                existingReaction: existingReactionIndex !== -1 ? mockReactions[existingReactionIndex] : null
            });

            if (existingReactionIndex !== -1) {
                // Remove existing reaction
                mockReactions.splice(existingReactionIndex, 1);
                
                // Update post like count
                const post = mockPosts.find(p => p.id === postIdInt);
                if (post) {
                    post.like_count = Math.max(0, post.like_count - 1);
                }
                
                logger.info('Mock reaction removed', {
                    postId: postIdInt,
                    userId: userId,
                    type: type,
                    action: 'removed'
                });
                
                res.json({ 
                    success: true, 
                    action: 'removed',
                    postId: postIdInt,
                    userId: userId
                });
            } else {
                // Add new reaction
                const newReaction = {
                    id: mockReactions.length + 1,
                    post_id: postIdInt,
                    user_id: userId,
                    type: type
                };
                
                mockReactions.push(newReaction);
                
                // Update post like count
                const post = mockPosts.find(p => p.id === postIdInt);
                if (post) {
                    post.like_count += 1;
                }
                
                logger.info('Mock reaction added', {
                    postId: postIdInt,
                    userId: userId,
                    type: type,
                    action: 'added',
                    reactionId: newReaction.id
                });
                
                res.json({ 
                    success: true, 
                    action: 'added',
                    postId: postIdInt,
                    userId: userId,
                    reactionId: newReaction.id
                });
            }
        } catch (error) {
            logger.error('Error toggling mock reaction', {
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
            const postIdInt = parseInt(postId);
            
            logger.debug('Adding mock comment', {
                postId: postIdInt,
                userId: userId,
                contentLength: content?.length
            });
            
            if (!content || content.trim().length === 0) {
                return res.status(400).json({ error: 'Content is required' });
            }
            
            // Find user info (mock)
            const userInfo = userId === 1 
                ? { username: 'oliver', first_name: 'Oliver', last_name: 'Hronek' }
                : { username: 'testuser', first_name: 'Test', last_name: 'User' };
            
            const newComment = {
                id: mockComments.length + 1,
                post_id: postIdInt,
                user_id: userId,
                content: content.trim(),
                username: userInfo.username,
                first_name: userInfo.first_name,
                last_name: userInfo.last_name,
                created_at: new Date().toISOString()
            };
            
            mockComments.push(newComment);
            
            // Update post comment count
            const post = mockPosts.find(p => p.id === postIdInt);
            if (post) {
                post.comment_count += 1;
            }
            
            logger.info('Mock comment added successfully', {
                commentId: newComment.id,
                postId: postIdInt,
                userId: userId
            });
            
            res.json({
                success: true,
                commentId: newComment.id,
                createdAt: newComment.created_at
            });
        } catch (error) {
            logger.error('Error adding mock comment', {
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
