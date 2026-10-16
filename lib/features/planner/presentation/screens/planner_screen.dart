import 'package:flutter/material.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Study Planner')),
      body: const Center(child: Text('Study Planner — Coming soon', style: TextStyle(color: Colors.white70))),
    );
  }
}
