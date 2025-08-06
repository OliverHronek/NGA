class ApiConstants {
  // NGA Server API
  
  static const bool kIsWeb = identical(0, 0.0);
  static const bool isDevelopment = bool.fromEnvironment('dart.vm.product') == false;

  // Use different base URLs for development vs production
  static String get baseUrl {
    if (kIsWeb && isDevelopment) {
      // During development on web, use local backend
      return 'http://localhost:3000';
    }
    // Production URL
    return 'https://nextgenerationaustria.at/political-app-api';
  }


  // Auth Endpoints
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get profile => '$baseUrl/auth/profile';
  
  // ========== NEUE EMAIL-VERIFIZIERUNG ==========
  static String get sendVerification => '$baseUrl/auth/send-verification';
  static String get verifyEmail => '$baseUrl/auth/verify-email';
  static String get updateProfile => '$baseUrl/auth/update-profile';
  static String get changePassword => '$baseUrl/auth/change-password';

  // Polls Endpoints
  static String get polls => '$baseUrl/polls';
  static String pollById(int id) => '$polls/$id';
  static String pollVote(int id) => '$polls/$id/vote';
  static String pollResults(int id) => '$polls/$id/results';
  
  // Forum Endpoints
  static String get forumCategories => '$baseUrl/forum/categories';
  static String forumPosts(int categoryId) => '$baseUrl/forum/categories/$categoryId/posts';
  static String get createPost => '$baseUrl/forum/posts';
  
  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
  };
  
  static Map<String, String> authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
}