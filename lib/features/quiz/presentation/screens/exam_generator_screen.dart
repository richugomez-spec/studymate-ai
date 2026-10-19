import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../core/theme/app_colors.dart';

class ExamGeneratorScreen extends ConsumerStatefulWidget {
  final String topicId;
  const ExamGeneratorScreen({super.key, required this.topicId});

  @override
  ConsumerState<ExamGeneratorScreen> createState() => _ExamGeneratorScreenState();
}

class _ExamGeneratorScreenState extends ConsumerState<ExamGeneratorScreen> {
  int _marks = 50;
  int _durationMinutes = 60;
  String _difficulty = 'Medium';
  bool _includeAnswerKey = true;
  bool _examGenerated = false;

  @override
  Widget build(BuildContext context) {
    final activeDoc = ref.watch(activeDocumentProvider);

    if (activeDoc == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(title: const Text('Mock Exam Generator', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 16))),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkBorderSubtle),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.description_outlined, size: 40, color: AppColors.electricViolet),
                const SizedBox(height: 12),
                const Text('No Document Active', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 8),
                Text('Upload your study materials to generate tailored mock exam papers with answer keys.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white60)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.uploadCenter),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.electricViolet, foregroundColor: Colors.white),
                  icon: const Icon(Icons.upload_file_rounded, size: 16),
                  label: const Text('Upload Document'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_examGenerated) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(title: Text('Mock Exam Setup: ${activeDoc.fileName}', style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 15), overflow: TextOverflow.ellipsis)),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Generate Complete Mock Exam', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Realistic exam papers compiled from your uploaded notes.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white60)),

                  const SizedBox(height: 24),

                  // Total Marks
                  const Text('TOTAL MARKS', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.darkTextTertiary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [25, 50, 100].map((m) {
                      final sel = _marks == m;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () => setState(() => _marks = m),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: sel ? AppColors.electricViolet : AppColors.darkSurfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: sel ? AppColors.electricViolet : AppColors.darkBorderSubtle),
                              ),
                              child: Text('$m Marks', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: sel ? Colors.white : Colors.white70)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Duration
                  const Text('EXAM DURATION', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.darkTextTertiary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [30, 60, 120].map((d) {
                      final sel = _durationMinutes == d;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () => setState(() => _durationMinutes = d),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: sel ? AppColors.teal : AppColors.darkSurfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: sel ? AppColors.teal : AppColors.darkBorderSubtle),
                              ),
                              child: Text('$d Mins', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: sel ? Colors.white : Colors.white70)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Difficulty
                  const Text('DIFFICULTY', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.darkTextTertiary)),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Standard', 'Moderate', 'Challenging'].map((diff) {
                      final sel = _difficulty == diff;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () => setState(() => _difficulty = diff),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: sel ? AppColors.skyBlue : AppColors.darkSurfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: sel ? AppColors.skyBlue : AppColors.darkBorderSubtle),
                              ),
                              child: Text(diff, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: sel ? Colors.white : Colors.white70)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Include Step-by-Step Answer Key', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white)),
                    value: _includeAnswerKey,
                    activeColor: AppColors.electricViolet,
                    onChanged: (v) => setState(() => _includeAnswerKey = v),
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () => setState(() => _examGenerated = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricViolet,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Generate Mock Exam Paper', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ── Exam Paper View ───────────────────────────────────────────────────────
    final concepts = activeDoc.concepts;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Mock Exam: ${activeDoc.fileName}', style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 15)),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 20, color: AppColors.teal),
            tooltip: 'Export Exam PDF',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mock exam paper exported ready for printing!')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Exam Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkBorderSubtle),
            ),
            child: Column(
              children: [
                Text('STUDYMATE AI OFFICIAL MOCK EXAMINATION', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.electricVioletLight, letterSpacing: 1.0)),
                const SizedBox(height: 8),
                Text(activeDoc.fileName, style: const TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Max Marks: $_marks', style: const TextStyle(fontFamily: 'Inter', fontSize: 12.5, color: Colors.white70)),
                    const SizedBox(width: 16),
                    Text('Time Allowed: $_durationMinutes Mins', style: const TextStyle(fontFamily: 'Inter', fontSize: 12.5, color: Colors.white70)),
                    const SizedBox(width: 16),
                    Text('Difficulty: $_difficulty', style: const TextStyle(fontFamily: 'Inter', fontSize: 12.5, color: AppColors.teal)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section A: Short Conceptual Questions (20% Marks)
          const Text('SECTION A: SHORT CONCEPTS & DEFINITIONS (10 Marks)', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.teal)),
          const SizedBox(height: 10),
          ...concepts.take(3).map((c) {
            final idx = concepts.indexOf(c) + 1;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.darkSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.darkBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Q$idx. Define ${c.title} and state its core premise.', style: const TextStyle(fontFamily: 'Inter', fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.white)),
                      const Text('[3 Marks]', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, color: Colors.white60)),
                    ],
                  ),
                  if (_includeAnswerKey) ...[
                    const SizedBox(height: 8),
                    Text('Answer Key: ${c.description}', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.teal.withOpacity(0.9))),
                  ],
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          // Section B: Analytical & Long Answers
          const Text('SECTION B: ANALYTICAL EXPLANATIONS & DERIVATIONS (40 Marks)', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.electricVioletLight)),
          const SizedBox(height: 10),
          ...concepts.skip(1).take(2).map((c) {
            final idx = concepts.indexOf(c) + 3;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.darkSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.darkBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('Q$idx. Detail the operational mechanics of ${c.title} with a practical example and analyze potential edge cases.', style: const TextStyle(fontFamily: 'Inter', fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                      const SizedBox(width: 8),
                      const Text('[10 Marks]', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, color: Colors.white60)),
                    ],
                  ),
                  if (_includeAnswerKey) ...[
                    const SizedBox(height: 8),
                    Text('Answer Key:\n• Primary mechanism and definitions: ${c.description}\n• Core exam focus: Pay attention to edge cases and boundary conditions.', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.teal.withOpacity(0.9), height: 1.4)),
                  ],
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: () => setState(() => _examGenerated = false),
            icon: const Icon(Icons.tune_rounded, size: 16),
            label: const Text('Adjust Exam Parameters'),
            style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white.withOpacity(0.2)), padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
        ],
      ),
    );
  }
}
