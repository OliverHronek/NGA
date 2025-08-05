import '../models/forum_model.dart';
import '../../core/constants/api_constants.dart';
import 'api_service.dart';
import 'auth_service.dart';

class ForumService {
  // Alle Kategorien abrufen
  static Future<Map<String, dynamic>> getCategories() async {
    try {
      final result = await ApiService.get(ApiConstants.forumCategories);
      
      if (result['success']) {
        final categoriesData = result['data']['categories'] as List;
        final categories = categoriesData.map((categoryJson) => 
          ForumCategory.fromJson(categoryJson)).toList();
        
        return {
          'success': true,
          'categories': categories,
          'count': result['data']['count'],
        };
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Fehler beim Laden der Kategorien',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

  // Posts einer Kategorie abrufen
  static Future<Map<String, dynamic>> getPostsByCategory(
    int categoryId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final url = '${ApiConstants.forumPosts(categoryId)}?page=$page&limit=$limit';
      final result = await ApiService.get(url);
      
      if (result['success']) {
        final postsData = result['data']['posts'] as List;
        final posts = postsData.map((postJson) => ForumPost.fromJson(postJson)).toList();
        
        return {
          'success': true,
          'posts': posts,
          'pagination': result['data']['pagination'],
        };
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Fehler beim Laden der Posts',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

  // Einzelnen Post mit Kommentaren abrufen
  static Future<Map<String, dynamic>> getPostById(int postId) async {
    try {
      final token = await AuthService.getToken();
      final result = await ApiService.get(
        '${ApiConstants.baseUrl}/forum/posts/$postId',
        token: token,
      );
      
      if (result['success']) {
        final post = ForumPost.fromJson(result['data']['post']);
        final commentsData = result['data']['comments'] as List;
        final comments = commentsData.map((commentJson) => 
          ForumComment.fromJson(commentJson)).toList();
        
        return {
          'success': true,
          'post': post,
          'comments': comments,
          'reactions': result['data']['reactions'],
          'commentCount': result['data']['commentCount'],
        };
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Post nicht gefunden',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

  // Neuen Post erstellen
  static Future<Map<String, dynamic>> createPost(CreatePostRequest postRequest) async {
    print('=== DEBUG: ForumService.createPost() gestartet ===');
    print('DEBUG: Eingehende postRequest.categoryId = ${postRequest.categoryId}');
    print('DEBUG: Eingehende postRequest.title = "${postRequest.title}"');
    print('DEBUG: Eingehende postRequest.content = "${postRequest.content}"');
    print('DEBUG: Eingehende postRequest.userId = ${postRequest.userId}');
    
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        print('DEBUG: Kein Token gefunden');
        return {
          'success': false,
          'error': 'Nicht angemeldet',
        };
      }
      print('DEBUG: Token gefunden: ${token.substring(0, 20)}...');

      // Admin-Status prüfen
      final user = await AuthService.getUser();
      if (user == null || !user.isAdmin) {
        print('DEBUG: User ist null oder nicht Admin. user: $user, isAdmin: ${user?.isAdmin}');
        return {
          'success': false,
          'error': 'Nur Administratoren können Posts erstellen',
        };
      }
      print('DEBUG: User ist Admin. user.id: ${user.id}, user.isAdmin: ${user.isAdmin}');

      // Create request with user ID explicitly set
      final requestWithUserId = CreatePostRequest(
        categoryId: postRequest.categoryId,
        title: postRequest.title,
        content: postRequest.content,
        userId: user.id, // Explicitly set the user ID
      );

      final requestData = requestWithUserId.toJson();
      print('DEBUG: Finale JSON Daten die an Server gesendet werden:');
      print('Sending post creation request: $requestData');
      print('User ID being sent: ${requestData['user_id']}');
      print('Title being sent: "${requestData['title']}"');
      print('Content being sent: "${requestData['content']}"');
      print('Category ID being sent: ${requestData['category_id']}');

      final result = await ApiService.post(
        ApiConstants.createPost,
        requestData,
        token: token,
      );
      
      print('DEBUG: Server Antwort: $result');
      
      if (result['success']) {
        final post = ForumPost.fromJson(result['data']['post']);
        
        return {
          'success': true,
          'post': post,
          'message': 'Post erfolgreich erstellt!',
        };
      } else {
        print('DEBUG: Server Fehler: ${result['error']}');
        return {
          'success': false,
          'error': result['error'] ?? 'Fehler beim Erstellen des Posts',
        };
      }
    } catch (e) {
      print('DEBUG: Exception in ForumService.createPost: $e');
      return {
        'success': false,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

  // Kommentar hinzufügen
  static Future<Map<String, dynamic>> addComment(
    int postId, 
    CreateCommentRequest commentRequest,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Nicht angemeldet',
        };
      }

      // Get current user for user ID
      final user = await AuthService.getUser();
      if (user == null) {
        return {
          'success': false,
          'error': 'Benutzer nicht gefunden',
        };
      }

      // Create request with user ID
      final requestWithUserId = CreateCommentRequest(
        content: commentRequest.content,
        parentCommentId: commentRequest.parentCommentId,
        userId: user.id, // Include the current user's ID
      );

      final result = await ApiService.post(
        '${ApiConstants.baseUrl}/forum/posts/$postId/comments',
        requestWithUserId.toJson(),
        token: token,
      );
      
      if (result['success']) {
        final comment = ForumComment.fromJson(result['data']['comment']);
        
        return {
          'success': true,
          'comment': comment,
          'message': 'Kommentar erfolgreich hinzugefügt!',
        };
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Fehler beim Erstellen des Kommentars',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

  // Reaction (Like/Dislike) toggle
  static Future<Map<String, dynamic>> toggleReaction({
    required String targetType, // 'post' oder 'comment'
    required int targetId,
    String reactionType = 'like',
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Nicht angemeldet',
        };
      }

      final result = await ApiService.post(
        '${ApiConstants.baseUrl}/forum/react',
        {
          'targetType': targetType,
          'targetId': targetId,
          'reactionType': reactionType,
        },
        token: token,
      );
      
      return {
        'success': result['success'],
        'message': result['success'] ? result['data']['message'] : null,
        'action': result['success'] ? result['data']['action'] : null,
        'error': result['error'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

  // Kategorie erstellen (Admin-Funktion)
  static Future<Map<String, dynamic>> createCategory({
    required String name,
    String? description,
    String color = '#007AFF',
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Nicht angemeldet',
        };
      }

      // Admin-Status prüfen
      final user = await AuthService.getUser();
      if (user == null || !user.isAdmin) {
        return {
          'success': false,
          'error': 'Nur Administratoren können Kategorien erstellen',
        };
      }

      final result = await ApiService.post(
        ApiConstants.forumCategories,
        {
          'name': name,
          'description': description,
          'color': color,
        },
        token: token,
      );
      
      if (result['success']) {
        final category = ForumCategory.fromJson(result['data']['category']);
        
        return {
          'success': true,
          'category': category,
          'message': 'Kategorie erfolgreich erstellt!',
        };
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Fehler beim Erstellen der Kategorie',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }
}