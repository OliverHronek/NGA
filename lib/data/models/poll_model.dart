class Poll {
  final int id;
  final String title;
  final String? description;
  final int creatorId;
  final String? creatorName;
  final String pollType;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final bool isPublic;
  final DateTime createdAt;
  final int totalVotes;
  final List<PollOption> options;
  final int? userVote; // ID der Option für die der User gestimmt hat

  Poll({
    required this.id,
    required this.title,
    this.description,
    required this.creatorId,
    this.creatorName,
    required this.pollType,
    this.startDate,
    this.endDate,
    required this.isActive,
    required this.isPublic,
    required this.createdAt,
    required this.totalVotes,
    required this.options,
    this.userVote,
  });

factory Poll.fromJson(Map<String, dynamic> json) {
  return Poll(
    id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
    title: json['title']?.toString() ?? '',
    description: json['description']?.toString(),
    creatorId: int.tryParse(json['creator_id']?.toString() ?? '0') ?? 0,
    creatorName: json['creator_name']?.toString(),
    pollType: json['poll_type']?.toString() ?? 'multiple_choice',
    startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date']) : null,
    endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date']) : null,
    isActive: json['is_active'] == true || json['is_active']?.toString() == 'true',
    isPublic: json['is_public'] == true || json['is_public']?.toString() == 'true',
    createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    totalVotes: int.tryParse(json['total_votes']?.toString() ?? '0') ?? 0,
    options: json['options'] != null 
      ? (json['options'] as List).map((option) => PollOption.fromJson(option)).toList()
      : [],
    userVote: json['userVote'] != null ? int.tryParse(json['userVote'].toString()) : null,
  );
}

  bool get hasEnded => endDate != null && DateTime.now().isAfter(endDate!);
  bool get canVote => isActive && !hasEnded;
  bool get hasUserVoted => userVote != null;
  
  String get statusText {
    if (!isActive) return 'Inaktiv';
    if (hasEnded) return 'Beendet';
    if (endDate != null) {
      final remaining = endDate!.difference(DateTime.now());
      if (remaining.inDays > 0) return '${remaining.inDays} Tage verbleibend';
      if (remaining.inHours > 0) return '${remaining.inHours} Stunden verbleibend';
      if (remaining.inMinutes > 0) return '${remaining.inMinutes} Minuten verbleibend';
    }
    return 'Aktiv';
  }
}

class PollOption {
  final int id;
  final int pollId;
  final String optionText;
  final int optionOrder;
  final int voteCount;
  final double? percentage;

  PollOption({
    required this.id,
    required this.pollId,
    required this.optionText,
    required this.optionOrder,
    required this.voteCount,
    this.percentage,
  });

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['id'],
      pollId: json['poll_id'],
      optionText: json['option_text'],
      optionOrder: json['option_order'] ?? 0,
      voteCount: int.tryParse(json['vote_count']?.toString() ?? '0') ?? 0,
      percentage: json['percentage']?.toDouble(),
    );
  }
}

class CreatePollRequest {
  final String title;
  final String? description;
  final List<String> options;
  final String pollType;
  final DateTime? endDate;
  final bool isPublic;

  CreatePollRequest({
    required this.title,
    this.description,
    required this.options,
    this.pollType = 'multiple_choice',
    this.endDate,
    this.isPublic = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'options': options.map((opt) => {'text': opt}).toList(),
      'pollType': pollType,
      'endDate': endDate?.toIso8601String(),
      'isPublic': isPublic,
    };
  }
}