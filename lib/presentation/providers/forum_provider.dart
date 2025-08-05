import 'package:flutter/material.dart';
import '../../data/models/forum_model.dart';
import '../../data/services/forum_service.dart';

class ForumProvider with ChangeNotifier {
  List<ForumCategory> _categories = [];
  List<ForumPost> _posts = [];
  List<ForumComment> _comments = [];
  ForumPost? _currentPost;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ForumCategory> get categories => _categories;
  List<ForumPost> get posts => _posts;
  List<ForumComment> get comments => _comments;
  ForumPost? get currentPost => _currentPost;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Kategorien laden
  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ForumService.getCategories();
      
      if (result['success']) {
        _categories = result['categories'];
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _error = 'Fehler beim Laden der Kategorien: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Posts einer Kategorie laden
  Future<void> loadPostsByCategory(int categoryId, {int page = 1}) async {
    if (page == 1) {
      _isLoading = true;
      _error = null;
      _posts.clear();
    }
    notifyListeners();

    try {
      final result = await ForumService.getPostsByCategory(categoryId, page: page);
      
      if (result['success']) {
        if (page == 1) {
          _posts = result['posts'];
        } else {
          _posts.addAll(result['posts']);
        }
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _error = 'Fehler beim Laden der Posts: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Einzelnen Post mit Kommentaren laden
  Future<void> loadPostById(int postId) async {
    _isLoading = true;
    _error = null;
    _currentPost = null;
    _comments.clear();
    notifyListeners();

    try {
      final result = await ForumService.getPostById(postId);
      
      if (result['success']) {
        _currentPost = result['post'];
        _comments = result['comments'];
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _error = 'Fehler beim Laden des Posts: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Neuen Post erstellen
  Future<bool> createPost(CreatePostRequest postRequest) async {
    print('=== DEBUG: ForumProvider.createPost() gestartet ===');
    print('DEBUG: Erhalten postRequest.categoryId = ${postRequest.categoryId}');
    print('DEBUG: Erhalten postRequest.title = "${postRequest.title}"');
    print('DEBUG: Erhalten postRequest.content = "${postRequest.content}"');
    print('DEBUG: Erhalten postRequest.userId = ${postRequest.userId}');
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('DEBUG: Rufe ForumService.createPost auf...');
      final result = await ForumService.createPost(postRequest);
      
      print('DEBUG: ForumService.createPost Ergebnis: $result');
      
      if (result['success']) {
        print('DEBUG: Post erfolgreich erstellt');
        // Neuen Post zur Liste hinzufügen
        _posts.insert(0, result['post']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        print('DEBUG: Post-Erstellung fehlgeschlagen: ${result['error']}');
        _error = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('DEBUG: Exception in createPost: $e');
      _error = 'Fehler beim Erstellen des Posts: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Kommentar hinzufügen
  Future<bool> addComment(int postId, CreateCommentRequest commentRequest) async {
    try {
      final result = await ForumService.addComment(postId, commentRequest);
      
      if (result['success']) {
        // Kommentar zur Liste hinzufügen
        _comments.add(result['comment']);
        
        // Comment Count beim aktuellen Post erhöhen
        if (_currentPost?.id == postId) {
          _currentPost = ForumPost(
            id: _currentPost!.id,
            categoryId: _currentPost!.categoryId,
            userId: _currentPost!.userId,
            title: _currentPost!.title,
            content: _currentPost!.content,
            authorName: _currentPost!.authorName,
            categoryName: _currentPost!.categoryName,
            isPinned: _currentPost!.isPinned,
            isLocked: _currentPost!.isLocked,
            viewsCount: _currentPost!.viewsCount,
            commentCount: _currentPost!.commentCount + 1,
            likeCount: _currentPost!.likeCount,
            createdAt: _currentPost!.createdAt,
            updatedAt: _currentPost!.updatedAt,
          );
        }
        
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Fehler beim Erstellen des Kommentars: $e';
      notifyListeners();
      return false;
    }
  }

  // Reaction toggle
  Future<bool> toggleReaction({
    required String targetType,
    required int targetId,
    String reactionType = 'like',
  }) async {
    try {
      final result = await ForumService.toggleReaction(
        targetType: targetType,
        targetId: targetId,
        reactionType: reactionType,
      );
      
      if (result['success']) {
        // Like Count updaten je nach Action
        final action = result['action'];
        final increment = action == 'added' ? 1 : (action == 'removed' ? -1 : 0);
        
        if (targetType == 'post' && _currentPost?.id == targetId) {
          _currentPost = ForumPost(
            id: _currentPost!.id,
            categoryId: _currentPost!.categoryId,
            userId: _currentPost!.userId,
            title: _currentPost!.title,
            content: _currentPost!.content,
            authorName: _currentPost!.authorName,
            categoryName: _currentPost!.categoryName,
            isPinned: _currentPost!.isPinned,
            isLocked: _currentPost!.isLocked,
            viewsCount: _currentPost!.viewsCount,
            commentCount: _currentPost!.commentCount,
            likeCount: _currentPost!.likeCount + increment,
            createdAt: _currentPost!.createdAt,
            updatedAt: _currentPost!.updatedAt,
          );
        } else if (targetType == 'comment') {
          // Comment Like Count updaten
          final commentIndex = _comments.indexWhere((c) => c.id == targetId);
          if (commentIndex != -1) {
            final comment = _comments[commentIndex];
            _comments[commentIndex] = ForumComment(
              id: comment.id,
              postId: comment.postId,
              userId: comment.userId,
              parentCommentId: comment.parentCommentId,
              content: comment.content,
              authorName: comment.authorName,
              likeCount: comment.likeCount + increment,
              createdAt: comment.createdAt,
              updatedAt: comment.updatedAt,
            );
          }
        }
        
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Fehler bei der Reaction: $e';
      notifyListeners();
      return false;
    }
  }

  // Kategorie erstellen
  Future<bool> createCategory({
    required String name,
    String? description,
    String color = '#007AFF',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ForumService.createCategory(
        name: name,
        description: description,
        color: color,
      );
      
      if (result['success']) {
        // Neue Kategorie zur Liste hinzufügen
        _categories.add(result['category']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Fehler beim Erstellen der Kategorie: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Hilfsmethoden
  ForumCategory? getCategoryById(int categoryId) {
    try {
      return _categories.firstWhere((cat) => cat.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  List<ForumPost> getPostsByCategory(int categoryId) {
    return _posts.where((post) => post.categoryId == categoryId).toList();
  }

  // Error und State zurücksetzen
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearCurrentPost() {
    _currentPost = null;
    _comments.clear();
    notifyListeners();
  }

  void clearPosts() {
    _posts.clear();
    notifyListeners();
  }
}