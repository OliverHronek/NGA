import 'package:flutter/material.dart';
import '../../../data/models/poll_model.dart';
import '../../../core/constants/app_colors.dart';

class PollCard extends StatelessWidget {
  final Poll poll;
  final VoidCallback? onTap;
  final bool showResults;

  const PollCard({
    super.key,
    required this.poll,
    this.onTap,
    this.showResults = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      poll.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
              
              if (poll.description != null && poll.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  poll.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Stats Row
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    poll.creatorName ?? 'Unbekannt',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.poll, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${poll.totalVotes} Stimmen',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (poll.hasUserVoted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 14, color: AppColors.accent),
                          SizedBox(width: 4),
                          Text(
                            'Abgestimmt',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              // Mini Preview der Top-Optionen
              if (showResults && poll.options.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildMiniResults(),
              ],
              
              const SizedBox(height: 8),
              
              // Action Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      poll.statusText,
                      style: TextStyle(
                        fontSize: 12,
                        color: poll.canVote ? AppColors.accent : AppColors.textHint,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textHint,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color chipColor;
    String chipText = poll.statusText;

    if (!poll.isActive) {
      chipColor = AppColors.textHint;
    } else if (poll.hasEnded) {
      chipColor = AppColors.error;
    } else if (poll.canVote) {
      chipColor = AppColors.accent;
    } else {
      chipColor = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        chipText,
        style: TextStyle(
          fontSize: 11,
          color: chipColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMiniResults() {
    if (poll.options.isEmpty) return const SizedBox.shrink();
    
    // Sortiere Optionen nach Stimmen
    final sortedOptions = List<PollOption>.from(poll.options)
      ..sort((a, b) => b.voteCount.compareTo(a.voteCount));
    
    // Zeige nur die Top 2 Optionen
    final topOptions = sortedOptions.take(2).toList();
    
    return Column(
      children: topOptions.map((option) {
        final percentage = poll.totalVotes > 0 
          ? (option.voteCount / poll.totalVotes * 100) 
          : 0.0;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option.optionText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}