import 'package:flutter/material.dart';
import '../models/result_data_model.dart';
import '../controllers/result_controller.dart';
import '../theme/app_theme.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  final ResultController _controller = ResultController();
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final ResultData data = ModalRoute.of(context)!.settings.arguments as ResultData;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      const Text(
                        '🎉',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        data.level == 10 
                            ? 'CONGRATULATIONS!\nALL LEVELS COMPLETED' 
                            : 'PUZZLE COMPLETED!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 28,
                          color: AppTheme.accent,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Level Info
                      Text(
                        'LEVEL ${data.level}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.difficulty,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Stats Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildStatRow(context, 'Completion Time', _formatTime(data.timeElapsed)),
                            const Divider(height: 32, color: Colors.white24),
                            _buildStatRow(context, 'Base Score', data.baseScore.toString()),
                            const SizedBox(height: 16),
                            _buildStatRow(
                              context, 
                              'Time Bonus', 
                              '+${data.timeBonus}', 
                              valueColor: Colors.greenAccent
                            ),
                            const SizedBox(height: 16),
                            _buildStatRow(
                              context, 
                              'Wrong Move Penalty', 
                              data.wrongMovePenalty > 0 ? '-${data.wrongMovePenalty}' : '0', 
                              valueColor: data.wrongMovePenalty > 0 ? AppTheme.error : null
                            ),
                            const Divider(height: 32, color: Colors.white24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'FINAL SCORE',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  data.finalScore.toString(),
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: AppTheme.accent,
                                    fontSize: 32,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Actions
                      if (data.level < 10)
                        ElevatedButton(
                          onPressed: () => _controller.onContinuePressed(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('CONTINUE', style: TextStyle(fontSize: 18)),
                        ),
                      if (data.level < 10) const SizedBox(height: 16),
                      
                      OutlinedButton(
                        onPressed: () => _controller.onBackToLevelsPressed(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppTheme.textSecondary),
                          foregroundColor: AppTheme.textMain,
                        ),
                        child: const Text('BACK TO LEVELS', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppTheme.textMain,
          ),
        ),
      ],
    );
  }
}
