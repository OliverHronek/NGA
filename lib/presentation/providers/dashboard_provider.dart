import 'package:flutter/material.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/services/dashboard_service.dart';

class DashboardProvider with ChangeNotifier {
  DashboardStats? _stats;
  List<TrendingPoll> _trendingPolls = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  DashboardStats? get stats => _stats;
  List<TrendingPoll> get trendingPolls => _trendingPolls;
  bool get isLoading => _isLoading;
  String? get error => _error;

Future<void> loadDashboardData() async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    print('🚀 Starting dashboard data load...'); // Debug
    
    // Stats laden
    final statsResult = await DashboardService.getDashboardStats();
    print('📊 Stats Result: $statsResult'); // Debug
    
    if (statsResult['success']) {
      _stats = DashboardStats.fromJson(statsResult['stats']);
      print('✅ Stats loaded successfully'); // Debug
    } else {
      _error = statsResult['error'];
      print('❌ Stats error: ${statsResult['error']}'); // Debug
    }

    // Trending Content laden
    final trendingResult = await DashboardService.getTrendingContent();
    print('🔥 Trending Result: $trendingResult'); // Debug
    
    if (trendingResult['success']) {
      final trendingData = trendingResult['trending'] as List;
      print('🔥 Trending Data Count: ${trendingData.length}'); // Debug
      print('🔥 First Trending Item: ${trendingData.isNotEmpty ? trendingData[0] : 'none'}'); // Debug
      
      _trendingPolls = trendingData
          .map((poll) => TrendingPoll.fromJson(poll))
          .toList();
          
      print('✅ Trending Polls Created: ${_trendingPolls.length}'); // Debug
      if (_trendingPolls.isNotEmpty) {
        print('🔥 First Trending Poll: ${_trendingPolls[0].title} (${_trendingPolls[0].totalVotes} votes)'); // Debug
      }
    } else {
      print('❌ Trending error: ${trendingResult['error']}'); // Debug
    }

  } catch (e) {
    print('💥 Provider Error: $e'); // Debug
    _error = 'Fehler beim Laden der Dashboard-Daten: $e';
  }

  _isLoading = false;
  notifyListeners();
}

  // Daten aktualisieren
  Future<void> refreshData() async {
    await loadDashboardData();
  }

  // Error zurücksetzen
  void clearError() {
    _error = null;
    notifyListeners();
  }
}