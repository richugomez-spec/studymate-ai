import 'package:flutter/material.dart';

class UnitScreen extends StatelessWidget {
  final String unitId;
  const UnitScreen({super.key, required this.unitId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Unit')),
      body: const Center(child: Text('Unit — Coming soon', style: TextStyle(color: Colors.white70))),
    );
  }
}
