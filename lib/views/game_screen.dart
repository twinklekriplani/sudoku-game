import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import '../theme/app_theme.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late GameController _controller;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = GameController();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final int? level = ModalRoute.of(context)?.settings.arguments as int?;
      _controller.initializeGame(level ?? 1);
      _fadeController.forward();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _showRestartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Restart Puzzle?'),
        content: const Text('Your current progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.restartGame();
            },
            child: const Text('RESTART', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          _controller.stopTimer();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _controller.stopTimer();
              Navigator.pop(context);
            },
          ),
          title: ValueListenableBuilder<GameState?>(
            valueListenable: _controller.gameState,
            builder: (context, state, child) {
              if (state == null) return const SizedBox();
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer_outlined, size: 20, color: AppTheme.accent),
                  const SizedBox(width: 8),
                  Text(
                    _controller.formatTime(state.timeElapsed),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 20,
                    ),
                  ),
                ],
              );
            },
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ValueListenableBuilder<GameState?>(
              valueListenable: _controller.gameState,
              builder: (context, state, child) {
                if (state == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        children: [
                          // Level & Difficulty Header
                          Text(
                            'LEVEL ${_controller.currentLevelData.level}',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _controller.currentLevelData.difficulty,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Sudoku Board
                          _buildBoard(constraints.maxWidth, state),
                          const SizedBox(height: 32),

                          // Number Pad
                          _buildNumberPad(context),
                          const SizedBox(height: 32),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _showRestartDialog,
                                  icon: const Icon(Icons.refresh, size: 20),
                                  label: const Text('RESTART'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    foregroundColor: AppTheme.textSecondary,
                                    side: const BorderSide(color: AppTheme.textSecondary),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  onPressed: () => _controller.checkSolution(context),
                                  icon: const Icon(Icons.check, size: 20),
                                  label: const Text('CHECK SOLUTION'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  }
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBoard(double maxWidth, GameState state) {
    // Keep board square, but bound it to max screen width minus padding
    final double boardSize = maxWidth > 500 ? 500 : maxWidth - 32;
    // Account for the 2px border on all 4 sides (total 4px width and 4px height)
    final double cellSize = (boardSize - 4) / 9;

    return Container(
      width: boardSize,
      height: boardSize,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: List.generate(9, (r) {
          return Row(
            children: List.generate(9, (c) {
              return _buildCell(state, r, c, cellSize);
            }),
          );
        }),
      ),
    );
  }

  Widget _buildCell(GameState state, int r, int c, double size) {
    final cell = state.board[r][c];
    final isSelected = state.selectedCell == cell;
    
    // Determine borders for 3x3 blocks
    final bool isRightBlock = (c + 1) % 3 == 0 && c != 8;
    final bool isBottomBlock = (r + 1) % 3 == 0 && r != 8;

    Color bgColor = Colors.transparent;
    if (isSelected) {
      bgColor = AppTheme.primary.withValues(alpha: 0.4);
    } else if (cell.isPrefilled) {
      bgColor = Colors.white.withValues(alpha: 0.05);
    }

    Color textColor = AppTheme.textMain;
    if (cell.isError) {
      textColor = AppTheme.error;
    } else if (!cell.isPrefilled) {
      textColor = AppTheme.accent;
    }

    return GestureDetector(
      onTap: () => _controller.selectCell(r, c),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            right: BorderSide(
              color: isRightBlock ? AppTheme.primary : AppTheme.textSecondary.withValues(alpha: 0.2),
              width: isRightBlock ? 2.0 : 1.0,
            ),
            bottom: BorderSide(
              color: isBottomBlock ? AppTheme.primary : AppTheme.textSecondary.withValues(alpha: 0.2),
              width: isBottomBlock ? 2.0 : 1.0,
            ),
          ),
        ),
        child: Center(
          child: Text(
            cell.currentValue == 0 ? '' : cell.currentValue.toString(),
            style: TextStyle(
              fontSize: size * 0.45,
              fontWeight: cell.isPrefilled ? FontWeight.bold : FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) => _buildNumButton(context, index + 1)),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ...List.generate(4, (index) => _buildNumButton(context, index + 6)),
            _buildClearButton(context),
          ],
        ),
      ],
    );
  }

  Widget _buildNumButton(BuildContext context, int number) {
    return InkWell(
      onTap: () => _controller.enterNumber(context, number),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textMain),
          ),
        ),
      ),
    );
  }

  Widget _buildClearButton(BuildContext context) {
    return InkWell(
      onTap: () => _controller.removeNumber(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.error.withValues(alpha: 0.5)),
        ),
        child: const Center(
          child: Icon(Icons.backspace_outlined, color: AppTheme.error, size: 22),
        ),
      ),
    );
  }
}
