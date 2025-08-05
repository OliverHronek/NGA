import 'package:flutter/material.dart';
import '../../../data/models/forum_model.dart';
import '../../../core/constants/app_colors.dart';

class PostCard extends StatelessWidget {
  final ForumPost post;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Pinned Icon
                  if (post.isPinned) ...[
                    Icon(
                      Icons.push_pin,
                      size: 16,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 8),
                  ],
                  
                  // Title
                  Expanded(
                    child: Text(
                      post.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: post.isPinned ? FontWeight.bold : FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Locked Icon
                  if (post.isLocked)
                    Icon(
                      Icons.lock,
                      size: 16,
                      color: AppColors.textHint,
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Content Preview
              Text(
                post.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Footer Row
              Row(
                children: [
                  // Author
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      post.authorName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    post.authorName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Stats
                  _buildStatItem(Icons.visibility, post.viewsCount),
                  const SizedBox(width: 12),
                  _buildStatItem(Icons.comment, post.commentCount),
                  const SizedBox(width: 12),
                  _buildStatItem(Icons.favorite, post.likeCount),
                  const SizedBox(width: 12),
                  
                  // Time
                  Text(
                    post.timeAgo,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 2),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}