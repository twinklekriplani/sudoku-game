import 'package:flutter/material.dart';
import '../views/welcome_screen.dart';
import '../views/home_screen_placeholder.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String home = '/home';

  static Map<String, WidgetBuilder> get routes {
    return {
      welcome: (context) => const WelcomeScreen(),
      home: (context) => const HomeScreenPlaceholder(),
    };
  }
}
