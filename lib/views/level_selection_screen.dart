import 'package:flutter/material.dart';
import '../controllers/level_selection_controller.dart';
import '../theme/app_theme.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> with SingleTickerProviderStateMixin {
  final LevelSelectionController _controller = LevelSelectionController();
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

    _controller.loadLevelProgress().then((_) {
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
        title: const Text('SELECT LEVEL'),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Choose your challenge',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    
                    // Progress Summary
                    _buildProgressSummary(context),
                    const SizedBox(height: 40),

                    // Sections
                    _buildSection(context, 'EASY', 'Warm up your brain', 1, 3),
                    const SizedBox(height: 32),
                    
                    _buildSection(context, 'MEDIUM', 'Think a little deeper', 4, 6),
                    const SizedBox(height: 32),
                    
                    _buildSection(context, 'HARD', 'Challenge yourself', 7, 10),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressSummary(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _controller.unlockedLevelsNotifier,
      builder: (context, unlocked, child) {
        final double percentage = unlocked / 10;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR PROGRESS',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$unlocked / 10 Levels Unlocked',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.accent,
                    ),
                  ),
                  Text(
                    '${(percentage * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: 8,
                  backgroundColor: AppTheme.background,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(BuildContext context, String title, String subtitle, int startLevel, int endLevel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 20,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.15,
          ),
          itemCount: endLevel - startLevel + 1,
          itemBuilder: (context, index) {
            final level = startLevel + index;
            return _buildLevelCard(context, level, title);
          },
        ),
      ],
    );
  }

  Widget _buildLevelCard(BuildContext context, int level, String difficulty) {
    return ValueListenableBuilder<int>(
      valueListenable: _controller.unlockedLevelsNotifier,
      builder: (context, unlockedLevels, child) {
        final bool isUnlocked = level <= unlockedLevels;
        final String formattedLevel = level.toString().padLeft(2, '0');

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _controller.onLevelSelected(context, level),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUnlocked ? AppTheme.surface : AppTheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUnlocked 
                      ? AppTheme.primary.withValues(alpha: 0.5) 
                      : Colors.transparent,
                ),
                boxShadow: isUnlocked ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ] : [],
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        formattedLevel,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 28,
                          color: isUnlocked ? AppTheme.textMain : AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'LEVEL $level',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? AppTheme.textMain : AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        difficulty,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: isUnlocked ? AppTheme.accent : AppTheme.textSecondary.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Icon(
                      isUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                      color: isUnlocked ? AppTheme.accent : AppTheme.textSecondary.withValues(alpha: 0.5),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
