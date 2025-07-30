class ForumCategory {
  final int id;
  final String name;
  final String? description;
  final String color;
  final DateTime createdAt;
  final int postCount;

  ForumCategory({
    required this.id,
    required this.name,
    this.description,
    required this.color,
    required this.createdAt,
    required this.postCount,
  });

  factory ForumCategory.fromJson(Map<String, dynamic> json) {
    return ForumCategory(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      color: json['color']?.toString() ?? '#007AFF',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      postCount: int.tryParse(json['post_count']?.toString() ?? '0') ?? 0,
    );
  }
}

class ForumPost {
  final int id;
  final int categoryId;
  final int userId;
  final String title;
  final String content;
  final String authorName;
  final String? categoryName;
  final bool isPinned;
  final bool isLocked;
  final int viewsCount;
  final int commentCount;
  final int likeCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ForumPost({
    required this.id,
    required this.categoryId,
    required this.userId,
    required this.title,
    required this.content,
    required this.authorName,
    this.categoryName,
    required this.isPinned,
    required this.isLocked,
    required this.viewsCount,
    required this.commentCount,
    required this.likeCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      categoryId: int.tryParse(json['category_id']?.toString() ?? '0') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      authorName: json['author_name']?.toString() ?? 'Unbekannt',
      categoryName: json['category_name']?.toString(),
      isPinned: json['is_pinned'] == true || json['is_pinned']?.toString() == 'true',
      isLocked: json['is_locked'] == true || json['is_locked']?.toString() == 'true',
      viewsCount: int.tryParse(json['views_count']?.toString() ?? '0') ?? 0,
      commentCount: int.tryParse(json['comment_count']?.toString() ?? '0') ?? 0,
      likeCount: int.tryParse(json['like_count']?.toString() ?? '0') ?? 0,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Jetzt';
    }
  }
}

class ForumComment {
  final int id;
  final int postId;
  final int userId;
  final int? parentCommentId;
  final String content;
  final String authorName;
  final int likeCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ForumComment({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentCommentId,
    required this.content,
    required this.authorName,
    required this.likeCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ForumComment.fromJson(Map<String, dynamic> json) {
    return ForumComment(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      postId: int.tryParse(json['post_id']?.toString() ?? '0') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      parentCommentId: json['parent_comment_id'] != null 
        ? int.tryParse(json['parent_comment_id'].toString()) 
        : null,
      content: json['content']?.toString() ?? '',
      authorName: json['author_name']?.toString() ?? 'Unbekannt',
      likeCount: int.tryParse(json['like_count']?.toString() ?? '0') ?? 0,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Jetzt';
    }
  }
}

class CreatePostRequest {
  final int categoryId;
  final String title;
  final String content;

  CreatePostRequest({
    required this.categoryId,
    required this.title,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'title': title,
      'content': content,
    };
  }
}

class CreateCommentRequest {
  final String content;
  final int? parentCommentId;

  CreateCommentRequest({
    required this.content,
    this.parentCommentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'parentCommentId': parentCommentId,
    };
  }
}