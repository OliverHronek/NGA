import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/forum_provider.dart';
import '../../widgets/forum/post_card.dart';
import '../../../core/constants/app_colors.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';

class ForumPostsScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const ForumPostsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<ForumPostsScreen> createState() => _ForumPostsScreenState();
}

class _ForumPostsScreenState extends State<ForumPostsScreen> {
  @override
  void initState() {
    super.initState();
    // Posts laden beim Start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ForumProvider>().loadPostsByCategory(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(widget.categoryName),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CreatePostScreen(
                    categoryId: widget.categoryId,
                    categoryName: widget.categoryName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ForumProvider>(
        builder: (context, forumProvider, child) {
          if (forumProvider.isLoading && forumProvider.posts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Lade Posts...'),
                ],
              ),
            );
          }

          if (forumProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Fehler beim Laden',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    forumProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      forumProvider.clearError();
                      forumProvider.loadPostsByCategory(widget.categoryId);
                    },
                    child: const Text('Erneut versuchen'),
                  ),
                ],
              ),
            );
          }

          final categoryPosts = forumProvider.posts
              .where((post) => post.categoryId == widget.categoryId)
              .toList();

          if (categoryPosts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.article_outlined,
                    size: 64,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Noch keine Posts in ${widget.categoryName}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sei der erste und starte eine Diskussion!',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CreatePostScreen(
                            categoryId: widget.categoryId,
                            categoryName: widget.categoryName,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Ersten Post erstellen'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await forumProvider.loadPostsByCategory(widget.categoryId);
            },
            color: AppColors.primary,
            child: Column(
              children: [
                // Category Info Card
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.forum, color: AppColors.secondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.categoryName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${categoryPosts.length} Posts • Diskutiere mit!',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CreatePostScreen(
                                  categoryId: widget.categoryId,
                                  categoryName: widget.categoryName,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.create, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),

                // Posts List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: categoryPosts.length,
                    itemBuilder: (context, index) {
                      final post = categoryPosts[index];
                      
                      return PostCard(
                        post: post,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PostDetailScreen(
                                postId: post.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreatePostScreen(
                categoryId: widget.categoryId,
                categoryName: widget.categoryName,
              ),
            ),
          );
        },
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.create, color: Colors.white),
      ),
    );
  }
}