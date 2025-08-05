import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/poll_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/poll_model.dart';


class PollDetailScreen extends StatefulWidget {
  final int pollId;

  const PollDetailScreen({
    super.key,
    required this.pollId,
  });

  @override
  State<PollDetailScreen> createState() => _PollDetailScreenState();
}

class _PollDetailScreenState extends State<PollDetailScreen> {
  int? selectedOptionId;

  @override
  void initState() {
    super.initState();
    // Poll Details laden
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PollProvider>().loadPollById(widget.pollId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Abstimmung'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PollProvider>().loadPollById(widget.pollId);
            },
          ),
        ],
      ),
      body: Consumer<PollProvider>(
        builder: (context, pollProvider, child) {
          if (pollProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Lade Abstimmung...'),
                ],
              ),
            );
          }

          if (pollProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(pollProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      pollProvider.clearError();
                      pollProvider.loadPollById(widget.pollId);
                    },
                    child: const Text('Erneut versuchen'),
                  ),
                ],
              ),
            );
          }

          final poll = pollProvider.currentPoll;
          if (poll == null) {
            return const Center(child: Text('Abstimmung nicht gefunden'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poll Info Card
                _buildPollInfoCard(poll),
                
                const SizedBox(height: 24),
                
                // Voting Section or Results
                if (poll.hasUserVoted || poll.hasEnded)
                  _buildResultsSection(poll)
                else if (poll.canVote)
                  _buildVotingSection(poll, pollProvider)
                else
                  _buildNotVotableSection(poll),
                
                const SizedBox(height: 24),
                
                // Chart Section
                if (poll.totalVotes > 0 && (poll.hasUserVoted || poll.hasEnded))
                  _buildChartSection(poll),
                
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPollInfoCard(Poll poll) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              poll.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            if (poll.description != null && poll.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                poll.description!,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Stats Row
            Row(
              children: [
                _buildStatItem(Icons.person, 'Erstellt von', poll.creatorName ?? 'Unbekannt'),
                const SizedBox(width: 24),
                _buildStatItem(Icons.poll, 'Stimmen', '${poll.totalVotes}'),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: poll.canVote 
                  ? AppColors.accent.withOpacity(0.1) 
                  : AppColors.textHint.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: poll.canVote 
                    ? AppColors.accent.withOpacity(0.3) 
                    : AppColors.textHint.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    poll.canVote ? Icons.how_to_vote : Icons.block,
                    size: 16,
                    color: poll.canVote ? AppColors.accent : AppColors.textHint,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    poll.statusText,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: poll.canVote ? AppColors.accent : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVotingSection(Poll poll, PollProvider pollProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.how_to_vote, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Deine Stimme abgeben',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Voting Options
            ...poll.options.map((option) => _buildVotingOption(option)),
            
            const SizedBox(height: 20),
            
            // Vote Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedOptionId != null
                    ? () => _submitVote(pollProvider, poll.id, selectedOptionId!)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: pollProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white, 
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Stimme abgeben',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVotingOption(PollOption option) {
    final isSelected = selectedOptionId == option.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedOptionId = option.id;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.textHint,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected ? AppColors.primary.withOpacity(0.05) : null,
          ),
          child: Row(
            children: [
              Radio<int>(
                value: option.id,
                groupValue: selectedOptionId,
                onChanged: (value) {
                  setState(() {
                    selectedOptionId = value;
                  });
                },
                activeColor: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option.optionText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitVote(PollProvider pollProvider, int pollId, int optionId) async {
    final success = await pollProvider.vote(pollId, optionId);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Stimme erfolgreich abgegeben!'),
          backgroundColor: AppColors.accent,
        ),
      );
      setState(() {
        selectedOptionId = null;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${pollProvider.error ?? "Fehler beim Abstimmen"}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildResultsSection(Poll poll) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: AppColors.secondary),
                const SizedBox(width: 8),
                const Text(
                  'Ergebnisse',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
                    child: const Text(
                      '✓ Du hast abgestimmt',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Results Bars
            ...poll.options.map((option) => _buildResultBar(option, poll.totalVotes)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBar(PollOption option, int totalVotes) {
    final percentage = totalVotes > 0 ? (option.voteCount / totalVotes * 100) : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  option.optionText,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${option.voteCount} (${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: totalVotes > 0 ? (option.voteCount / totalVotes) : 0,
            backgroundColor: AppColors.textHint.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.pollColors[option.optionOrder % AppColors.pollColors.length],
            ),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildNotVotableSection(Poll poll) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              poll.hasEnded ? Icons.timer_off : Icons.block,
              size: 48,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 12),
            Text(
              poll.hasEnded ? 'Abstimmung beendet' : 'Abstimmung nicht verfügbar',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              poll.hasEnded 
                ? 'Diese Abstimmung ist bereits beendet.'
                : 'Diese Abstimmung ist derzeit nicht aktiv.',
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(Poll poll) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.pie_chart, color: AppColors.secondary),
                SizedBox(width: 8),
                Text(
                  'Verteilung der Stimmen',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Pie Chart
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: poll.options.map((option) {
                    final percentage = poll.totalVotes > 0 
                      ? (option.voteCount / poll.totalVotes * 100) 
                      : 0.0;
                    
                    return PieChartSectionData(
                      value: option.voteCount.toDouble(),
                      title: '${percentage.toStringAsFixed(1)}%',
                      color: AppColors.pollColors[option.optionOrder % AppColors.pollColors.length],
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  centerSpaceRadius: 0,
                  sectionsSpace: 2,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: poll.options.map((option) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.pollColors[option.optionOrder % AppColors.pollColors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      option.optionText,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}