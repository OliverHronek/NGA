class ApiConstants {
  // NGA Server API
  static const String baseUrl = 'http://5.104.107.253:3000/api';
  
  // Auth Endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String profile = '$baseUrl/auth/profile';
  
  // Polls Endpoints
  static const String polls = '$baseUrl/polls';
  static String pollById(int id) => '$polls/$id';
  static String pollVote(int id) => '$polls/$id/vote';
  static String pollResults(int id) => '$polls/$id/results';
  
  // Forum Endpoints
  static const String forumCategories = '$baseUrl/forum/categories';
  static String forumPosts(int categoryId) => '$baseUrl/forum/categories/$categoryId/posts';
  static const String createPost = '$baseUrl/forum/posts';
  
  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
  };
  
  static Map<String, String> authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
}