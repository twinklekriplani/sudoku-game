import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'routes/app_routes.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize storage
  await StorageService.init();
  
  // Determine starting route
  final bool hasPlayer = await StorageService.hasPlayer();
  final String initialRoute = hasPlayer ? AppRoutes.home : AppRoutes.welcome;

  runApp(SudokuQuestApp(initialRoute: initialRoute));
}

class SudokuQuestApp extends StatelessWidget {
  final String initialRoute;

  const SudokuQuestApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku Quest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: initialRoute,
      routes: AppRoutes.routes,
    );
  }
}
