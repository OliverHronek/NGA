import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/forum_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/forum_model.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Post Details laden
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ForumProvider>().loadPostById(widget.postId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('💬 Diskussion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ForumProvider>().loadPostById(widget.postId);
            },
          ),
        ],
      ),
      body: Consumer<ForumProvider>(
        builder: (context, forumProvider, child) {
          if (forumProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Lade Post...'),
                ],
              ),
            );
          }

          if (forumProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(forumProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      forumProvider.clearError();
                      forumProvider.loadPostById(widget.postId);
                    },
                    child: const Text('Erneut versuchen'),
                  ),
                ],
              ),
            );
          }

          final post = forumProvider.currentPost;
          if (post == null) {
            return const Center(child: Text('Post nicht gefunden'));
          }

          return Column(
            children: [
              // Post Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post Card
                      _buildPostCard(post, forumProvider),
                      
                      const SizedBox(height: 24),
                      
                      // Comments Section
                      _buildCommentsSection(forumProvider),
                    ],
                  ),
                ),
              ),
              
              // Comment Input
              _buildCommentInput(forumProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPostCard(ForumPost post, ForumProvider forumProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    // Always use current user's name if post belongs to them
                    String displayName;
                    if (authProvider.user != null && authProvider.user!.id == post.userId) {
                      displayName = authProvider.user!.displayName;
                    } else {
                      displayName = post.authorName != 'Unbekannt' ? post.authorName : 'Unbekannter Benutzer';
                    }
                    
                    return CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName.substring(0, 1).toUpperCase()
                            : 'A',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          // Always use current user's name if post belongs to them
                          String displayName;
                          if (authProvider.user != null && authProvider.user!.id == post.userId) {
                            displayName = authProvider.user!.displayName;
                          } else {
                            displayName = post.authorName != 'Unbekannt' ? post.authorName : 'Unbekannter Benutzer';
                          }
                          
                          return Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      Text(
                        post.timeAgo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (post.isPinned)
                  Icon(Icons.push_pin, size: 20, color: AppColors.accent),
                if (post.isLocked)
                  Icon(Icons.lock, size: 20, color: AppColors.textHint),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Title
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Content
            Text(
              post.content,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Stats and Actions Row
            Row(
              children: [
                _buildStatItem(Icons.visibility, post.viewsCount),
                const SizedBox(width: 16),
                _buildStatItem(Icons.comment, post.commentCount),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _togglePostLike(forumProvider, post.id),
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 16,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        post.likeCount.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'in ${post.categoryName ?? 'Unbekannt'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection(ForumProvider forumProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.comment, color: AppColors.secondary),
                const SizedBox(width: 8),
                Text(
                  'Kommentare (${forumProvider.comments.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (forumProvider.comments.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        size: 48,
                        color: AppColors.textHint,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Noch keine Kommentare',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Sei der erste, der kommentiert!',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...forumProvider.comments.map((comment) => _buildCommentCard(comment, forumProvider)),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentCard(ForumComment comment, ForumProvider forumProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textHint.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment Header
          Row(
            children: [
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  // Always use current user's initial if comment belongs to them
                  String displayName;
                  if (authProvider.user != null && authProvider.user!.id == comment.userId) {
                    displayName = authProvider.user!.displayName;
                  } else {
                    displayName = comment.authorName != 'Unbekannt' ? comment.authorName : 'Unbekannter Benutzer';
                  }
                  
                  return CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName.substring(0, 1).toUpperCase()
                          : 'A',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  // Always use current user's name if comment belongs to them
                  String displayName;
                  if (authProvider.user != null && authProvider.user!.id == comment.userId) {
                    displayName = authProvider.user!.displayName;
                  } else {
                    displayName = comment.authorName != 'Unbekannt' ? comment.authorName : 'Unbekannter Benutzer';
                  }
                  
                  return Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                comment.timeAgo,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _toggleCommentLike(forumProvider, comment.id),
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      comment.likeCount.toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Comment Content
          Text(
            comment.content,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(ForumProvider forumProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.textHint.withValues(alpha: 0.2)),
        ),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Schreibe einen Kommentar...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  maxLines: null,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Kommentar darf nicht leer sein';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _addComment(forumProvider),
                icon: const Icon(Icons.send, color: AppColors.primary),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addComment(ForumProvider forumProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final commentRequest = CreateCommentRequest(
      content: _commentController.text.trim(),
    );

    final success = await forumProvider.addComment(widget.postId, commentRequest);

    if (success) {
      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('💬 Kommentar hinzugefügt!'),
          backgroundColor: AppColors.accent,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${forumProvider.error ?? "Fehler beim Kommentieren"}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _togglePostLike(ForumProvider forumProvider, int postId) async {
    await forumProvider.toggleReaction(
      targetType: 'post',
      targetId: postId,
      reactionType: 'like',
    );
  }

  Future<void> _toggleCommentLike(ForumProvider forumProvider, int commentId) async {
    await forumProvider.toggleReaction(
      targetType: 'comment',
      targetId: commentId,
      reactionType: 'like',
    );
  }
}
