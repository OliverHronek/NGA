import 'api_service.dart';
import '../../core/constants/api_constants.dart';

class DashboardService {
  // Dashboard Statistiken abrufen
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Parallele API-Calls für bessere Performance
      final futures = await Future.wait([
        ApiService.get(ApiConstants.polls),
        ApiService.get(ApiConstants.forumCategories),
        ApiService.get('${ApiConstants.baseUrl}/db-test'), // Für User-Count
      ]);

      final pollsResult = futures[0];
      final forumResult = futures[1];
      final dbResult = futures[2];

      // Daten verarbeiten
      int totalPolls = 0;
      int activePolls = 0;
      int totalVotes = 0;

      if (pollsResult['success'] && pollsResult['data'] != null) {
        final polls = pollsResult['data']['polls'] as List? ?? [];
        totalPolls = polls.length;
        activePolls = polls.where((poll) => poll['is_active'] == true).length;
        totalVotes = polls.fold(0, (sum, poll) => sum + (int.tryParse(poll['total_votes'].toString()) ?? 0));
      }

      int totalCategories = 0;
      int totalPosts = 0;

      if (forumResult['success'] && forumResult['data'] != null) {
        final categories = forumResult['data']['categories'] as List? ?? [];
        totalCategories = categories.length;
        totalPosts = categories.fold(0, (sum, cat) => sum + (int.tryParse(cat['post_count'].toString()) ?? 0));
      }

      int totalUsers = 0;
      if (dbResult['success'] && dbResult['data'] != null) {
        totalUsers = int.tryParse(dbResult['data']['statistics']?['users']?.toString() ?? '0') ?? 0;
      }

      return {
        'success': true,
        'stats': {
          'totalUsers': totalUsers,
          'totalPolls': totalPolls,
          'activePolls': activePolls,
          'totalVotes': totalVotes,
          'totalCategories': totalCategories,
          'totalPosts': totalPosts,
          'engagementRate': totalUsers > 0 ? (totalVotes / totalUsers * 100).round() : 0,
        }
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Fehler beim Laden der Dashboard-Daten: $e',
      };
    }
  }

  // Trending Posts abrufen
static Future<Map<String, dynamic>> getTrendingContent() async {
  try {
    final result = await ApiService.get(ApiConstants.polls);
    //print('🔥 Trending API Result: $result'); // Debug hinzufügen
    
    if (result['success'] && result['data'] != null) {
      final polls = result['data']['polls'] as List? ?? [];
      //print('🔥 Polls from API: $polls'); // Debug hinzufügen
      
      // Sortiere nach total_votes (trending)
      polls.sort((a, b) => (b['total_votes'] ?? 0).compareTo(a['total_votes'] ?? 0));
      
      return {
        'success': true,
        'trending': polls.take(3).toList(), // Top 3
      };
    }

    //print('❌ API call failed or no data'); // Debug
    return {
      'success': false,
      'error': 'Keine Trending-Daten verfügbar',
    };
  } catch (e) {
    //print('💥 Trending Service Error: $e'); // Debug
    return {
      'success': false,
      'error': 'Fehler beim Laden der Trending-Daten: $e',
    };
  }
}
}