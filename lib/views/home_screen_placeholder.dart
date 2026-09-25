import 'package:flutter/material.dart';

class HomeScreenPlaceholder extends StatelessWidget {
  const HomeScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku Quest'),
      ),
      body: const Center(
        child: Text(
          'Home Screen Placeholder',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
