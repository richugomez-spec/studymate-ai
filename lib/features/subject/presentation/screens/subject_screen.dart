import 'package:flutter/material.dart';

class SubjectScreen extends StatelessWidget {
  final String subjectId;
  const SubjectScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Subject')),
      body: const Center(child: Text('Subject — Coming soon', style: TextStyle(color: Colors.white70))),
    );
  }
}
