import 'package:flutter/material.dart';
import '../controllers/welcome_controller.dart';
import '../services/storage_service.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  final WelcomeController _controller = WelcomeController();
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _submitName() async {
    FocusScope.of(context).unfocus();
    if (_controller.formKey.currentState?.validate() ?? false) {
      final name = _controller.nameController.text.trim();
      final success = await StorageService.savePlayerName(name);
      if (success && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background accents
          _buildBackgroundGraphics(),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Form(
                      key: _controller.formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // App Logo
                          _buildAppLogo(),
                          const SizedBox(height: 24),
                          
                          // App Title
                          const Text(
                            'SUDOKU',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                          _buildGradientText(
                            'QUEST',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Subtitle
                          Text(
                            'Challenge Your Mind',
                            style: TextStyle(
                              color: AppTheme.textSecondary.withValues(alpha: 0.8),
                              fontSize: 16,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 48),
                          
                          // Greeting Section
                          _buildGreetingSection(),
                          const SizedBox(height: 48),
                          
                          // Player Name Input
                          _buildInputField(),
                          const SizedBox(height: 32),
                          
                          // Continue Button
                          _buildContinueButton(),
                          const SizedBox(height: 64),
                          
                          // Bottom Footer
                          _buildFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGraphics() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 400,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.5),
                radius: 1.2,
                colors: [
                  const Color(0xFF2979FF).withValues(alpha: 0.15), // Cyan/Blue glow
                  AppTheme.background,
                ],
              ),
            ),
          ),
        ),
        // Add subtle rotated grids for background decor
        Positioned(
          top: -20,
          left: -40,
          child: Transform.rotate(
            angle: 0.2,
            child: Icon(
              Icons.grid_on,
              size: 150,
              color: AppTheme.primary.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          top: 300,
          right: -40,
          child: Transform.rotate(
            angle: -0.2,
            child: Icon(
              Icons.grid_on,
              size: 120,
              color: AppTheme.primary.withValues(alpha: 0.05),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppLogo() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Image.asset(
          'assets/images/logo_compact.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 14,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'WELCOME TO',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text(
              'Sudoku ',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            _buildGradientText(
              'Quest',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Enter your name to start your\npuzzle journey!',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.accent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.all(1.5), // For gradient border effect
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface, // Inner dark background
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextFormField(
          controller: _controller.nameController,
          validator: _controller.validateName,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submitName(),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Enter your player name',
            hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.8)),
            prefixIcon: const Icon(Icons.person_outline, color: Colors.white),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB388FF), Color(0xFF2979FF)], // Purple to cyan/blue
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2979FF).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: _submitName,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'CONTINUE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 20, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 40, height: 1, color: AppTheme.textSecondary.withValues(alpha: 0.3)),
            const SizedBox(width: 16),
            const Icon(Icons.grid_view_rounded, color: AppTheme.accent, size: 16),
            const SizedBox(width: 16),
            Container(width: 40, height: 1, color: AppTheme.textSecondary.withValues(alpha: 0.3)),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Small Puzzles  •  Big Wins',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildGradientText(String text, {required TextStyle style}) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [AppTheme.accent, AppTheme.primary],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bounds),
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}
