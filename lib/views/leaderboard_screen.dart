import 'package:flutter/material.dart';
import '../controllers/leaderboard_controller.dart';
import '../theme/app_theme.dart';
import '../models/score_model.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  final LeaderboardController _controller = LeaderboardController();
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _controller.loadLeaderboard().then((_) {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LEADERBOARD'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: _controller.isLoading,
          builder: (context, isLoading, child) {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
            }

            return FadeTransition(
              opacity: _fadeAnimation,
              child: ValueListenableBuilder<List<ScoreModel>>(
                valueListenable: _controller.leaderboardNotifier,
                builder: (context, scores, child) {
                  if (scores.isEmpty) {
                    return _buildEmptyState();
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '🏆',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Top Sudoku Masters',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            letterSpacing: 1.5,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Top 3 Section
                        if (scores.isNotEmpty) _buildTop3(scores),
                        const SizedBox(height: 32),

                        // Rank List (4-10)
                        if (scores.length > 3)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: scores.length - 3,
                            itemBuilder: (context, index) {
                              final rank = index + 4;
                              final scoreData = scores[index + 3];
                              return _buildListEntry(rank, scoreData);
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 24),
          Text(
            'NO SCORES YET',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 24,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Complete a Sudoku puzzle to appear on the leaderboard.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTop3(List<ScoreModel> scores) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (scores.length > 1) 
          Expanded(child: _buildPodiumEntry(scores[1], 2, '🥈', 110)),
        
        Expanded(child: _buildPodiumEntry(scores[0], 1, '🥇', 140)),
        
        if (scores.length > 2) 
          Expanded(child: _buildPodiumEntry(scores[2], 3, '🥉', 90))
        else if (scores.length > 1)
          const Expanded(child: SizedBox()),
      ],
    );
  }

  Widget _buildPodiumEntry(ScoreModel scoreData, int rank, String medal, double height) {
    final bool isCurrentPlayer = scoreData.playerName == _controller.currentPlayerName;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(medal, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isCurrentPlayer ? AppTheme.primary.withValues(alpha: 0.2) : AppTheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16), bottom: Radius.circular(8)),
            border: Border.all(
              color: isCurrentPlayer ? AppTheme.accent : AppTheme.primary.withValues(alpha: 0.3),
              width: isCurrentPlayer ? 2 : 1,
            ),
            boxShadow: isCurrentPlayer ? [
              BoxShadow(
                color: AppTheme.accent.withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 1,
              )
            ] : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                scoreData.playerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                scoreData.score.toString(),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 20,
                  color: AppTheme.accent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'LEVEL ${scoreData.level}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListEntry(int rank, ScoreModel scoreData) {
    final bool isCurrentPlayer = scoreData.playerName == _controller.currentPlayerName;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPlayer ? AppTheme.accent.withValues(alpha: 0.5) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '#$rank',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 18,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scoreData.playerName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Level ${scoreData.level}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            scoreData.score.toString(),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 20,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
