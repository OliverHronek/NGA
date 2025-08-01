import 'package:flutter/material.dart'; 

class DashboardStats {
  final int totalUsers;
  final int totalPolls;
  final int activePolls;
  final int totalVotes;
  final int totalCategories;
  final int totalPosts;
  final int engagementRate;

  DashboardStats({
    required this.totalUsers,
    required this.totalPolls,
    required this.activePolls,
    required this.totalVotes,
    required this.totalCategories,
    required this.totalPosts,
    required this.engagementRate,
  });

factory DashboardStats.fromJson(Map<String, dynamic> json) {
  return DashboardStats(
    totalUsers: int.tryParse(json['totalUsers'].toString()) ?? 0,
    totalPolls: int.tryParse(json['totalPolls'].toString()) ?? 0,
    activePolls: int.tryParse(json['activePolls'].toString()) ?? 0,
    totalVotes: int.tryParse(json['totalVotes'].toString()) ?? 0,
    totalCategories: int.tryParse(json['totalCategories'].toString()) ?? 0,
    totalPosts: int.tryParse(json['totalPosts'].toString()) ?? 0,
    engagementRate: int.tryParse(json['engagementRate'].toString()) ?? 0,
  );
}

  String get participationText {
    if (engagementRate >= 80) return 'Sehr aktiv! 🔥';
    if (engagementRate >= 60) return 'Gut dabei! 👍';
    if (engagementRate >= 40) return 'Wächst stetig 📈';
    if (engagementRate >= 20) return 'Am wachsen 🌱';
    return 'Gerade gestartet ✨';
  }

  Color get participationColor {
    if (engagementRate >= 80) return const Color(0xFF4CAF50); // Grün
    if (engagementRate >= 60) return const Color(0xFF8BC34A); // Hellgrün
    if (engagementRate >= 40) return const Color(0xFFFF9800); // Orange
    if (engagementRate >= 20) return const Color(0xFFFF5722); // Rot-Orange
    return const Color(0xFF9E9E9E); // Grau
  }
}

class TrendingPoll {
  final int id;
  final String title;
  final int totalVotes;
  final String creatorName;

  TrendingPoll({
    required this.id,
    required this.title,
    required this.totalVotes,
    required this.creatorName,
  });

factory TrendingPoll.fromJson(Map<String, dynamic> json) {
  return TrendingPoll(
    id: int.tryParse(json['id'].toString()) ?? 0,
    title: json['title'] ?? '',
    totalVotes: int.tryParse(json['total_votes'].toString()) ?? 0,
    creatorName: json['creator_name'] ?? 'Unbekannt',
  );
}
}