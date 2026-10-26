import 'package:flutter/material.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Achievements')),
      body: const Center(child: Text('Achievements — Coming soon', style: TextStyle(color: Colors.white70))),
    );
  }
}
