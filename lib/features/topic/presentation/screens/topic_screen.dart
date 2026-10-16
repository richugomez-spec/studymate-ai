import 'package:flutter/material.dart';

class TopicScreen extends StatelessWidget {
  final String topicId;
  const TopicScreen({super.key, required this.topicId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Topic')),
      body: const Center(child: Text('Topic — Coming soon', style: TextStyle(color: Colors.white70))),
    );
  }
}
