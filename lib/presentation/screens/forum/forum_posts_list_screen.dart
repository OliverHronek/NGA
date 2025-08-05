import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/forum_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/forum_model.dart';
import 'forum_posts_screen.dart'; // For CreatePostScreen
import 'post_detail_screen.dart';

class ForumPostsListScreen extends StatefulWidget {
  final ForumCategory category;

  const ForumPostsListScreen({
    super.key,
    required this.category,
  });

  @override
  State<ForumPostsListScreen> createState() => _ForumPostsListScreenState();
}

class _ForumPostsListScreenState extends State<ForumPostsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ForumProvider>(context, listen: false)
          .loadPostsByCategory(widget.category.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Color(int.parse(widget.category.color.replaceFirst('#', '0xFF'))),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.category.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // DEBUG: Add refresh user data button
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return IconButton(
                icon: const Icon(Icons.refresh_outlined),
                onPressed: () async {
                  await authProvider.refreshUserData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User data refreshed!')),
                  );
                },
              );
            },
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.canCreateContent()) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    onPressed: () {
                      final navigator = Navigator.of(context);
                      navigator.push(
                        MaterialPageRoute(
                          builder: (context) => CreatePostScreen(
                            categoryId: widget.category.id,
                            categoryName: widget.category.name,
                          ),
                        ),
                      ).then((_) {
                        // Refresh posts after creating new one
                        if (mounted) {
                          Provider.of<ForumProvider>(context, listen: false)
                              .loadPostsByCategory(widget.category.id);
                        }
                      });
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<ForumProvider>(
        builder: (context, forumProvider, child) {
          if (forumProvider.isLoading && forumProvider.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Diskussionen werden geladen...',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          if (forumProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Fehler beim Laden',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          forumProvider.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => forumProvider.loadPostsByCategory(widget.category.id),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Erneut versuchen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (forumProvider.posts.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => forumProvider.loadPostsByCategory(widget.category.id),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: forumProvider.posts.length,
              itemBuilder: (context, index) {
                final post = forumProvider.posts[index];
                return _buildPostCard(post);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.forum_outlined,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Noch keine Diskussionen',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'In "${widget.category.name}" wurden noch keine Diskussionen gestartet.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.canCreateContent()) {
                return ElevatedButton.icon(
                  onPressed: () {
                    final navigator = Navigator.of(context);
                    navigator.push(
                      MaterialPageRoute(
                        builder: (context) => CreatePostScreen(
                          categoryId: widget.category.id,
                          categoryName: widget.category.name,
                        ),
                      ),
                    ).then((_) {
                      if (mounted) {
                        Provider.of<ForumProvider>(context, listen: false)
                            .loadPostsByCategory(widget.category.id);
                      }
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Erste Diskussion starten'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                );
              }
              return const Text(
                'Warten Sie auf die erste Diskussion von einem Administrator.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(ForumPost post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PostDetailScreen(
                postId: post.id,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post header with author and date
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        String displayName;
                        
                        // Check if this post belongs to the current user
                        if (authProvider.user != null && authProvider.user!.id == post.userId) {
                          // Post has correct user_id matching current user - use their display name
                          displayName = authProvider.user!.displayName;
                        } else if (post.userId == 0 && authProvider.user?.isAdmin == true) {
                          // Post has user_id = 0 but current user is admin (likely their post with broken user_id)
                          displayName = authProvider.user!.displayName;
                        } else if (post.authorName == 'oliver' && authProvider.user?.username == 'oliver') {
                          // Server returned username 'oliver' but we have the actual user - use their display name
                          displayName = authProvider.user!.displayName;
                        } else if (post.authorName != 'Unbekannt' && post.authorName.isNotEmpty && post.authorName != 'oliver') {
                          // Use the author name from server if it's not just a username
                          displayName = post.authorName;
                        } else {
                          // Fallback for unknown users
                          displayName = 'Unbekannter Benutzer';
                        }
                        
                        return Center(
                          child: Text(
                            displayName.isNotEmpty
                                ? displayName.substring(0, 1).toUpperCase()
                                : 'A',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            String displayAuthorName;
                            
                            // Check if this post belongs to the current user
                            if (authProvider.user != null && authProvider.user!.id == post.userId) {
                              // Post has correct user_id matching current user
                              displayAuthorName = authProvider.user!.displayName;
                            } else if (post.userId == 0 && authProvider.user?.isAdmin == true) {
                              // Post has user_id = 0 but current user is admin (likely their post with broken user_id)
                              displayAuthorName = authProvider.user!.displayName;
                            } else if (post.authorName == 'oliver' && authProvider.user?.username == 'oliver') {
                              // Server returned username 'oliver' - use known full name
                              displayAuthorName = 'Oliver Hronek';
                            } else if (post.authorName != 'Unbekannt' && post.authorName.isNotEmpty && post.authorName != 'oliver') {
                              // Use the author name from server if it's not just a username
                              displayAuthorName = post.authorName;
                            } else {
                              // Fallback for unknown users
                              displayAuthorName = 'Unbekannter Benutzer';
                            }
                            
                            return Text(
                              displayAuthorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            );
                          },
                        ),
                        Text(
                          _formatDate(post.createdAt),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (post.isPinned)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.push_pin, size: 12, color: Colors.orange),
                          SizedBox(width: 4),
                          Text(
                            'Angepinnt',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Post title
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Post content preview
              Text(
                post.content.length > 150
                    ? '${post.content.substring(0, 150)}...'
                    : post.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Post stats
              Row(
                children: [
                  _buildStatChip(Icons.visibility, post.viewsCount, 'Aufrufe'),
                  const SizedBox(width: 12),
                  _buildStatChip(Icons.comment_outlined, post.commentCount, 'Kommentare'),
                  const SizedBox(width: 12),
                  _buildStatChip(Icons.thumb_up_outlined, post.likeCount, 'Likes'),
                  const Spacer(),
                  if (post.isLocked)
                    const Icon(
                      Icons.lock,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, int count, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}.${date.month}.${date.year}';
    } else if (difference.inDays > 0) {
      return 'vor ${difference.inDays} Tag${difference.inDays == 1 ? '' : 'en'}';
    } else if (difference.inHours > 0) {
      return 'vor ${difference.inHours} Stunde${difference.inHours == 1 ? '' : 'n'}';
    } else if (difference.inMinutes > 0) {
      return 'vor ${difference.inMinutes} Minute${difference.inMinutes == 1 ? '' : 'n'}';
    } else {
      return 'gerade eben';
    }
  }
}
