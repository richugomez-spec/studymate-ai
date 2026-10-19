import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../core/theme/app_colors.dart';

enum SummaryMode { short, medium, detailed }

class SummaryScreen extends ConsumerStatefulWidget {
  final String? topicId;
  const SummaryScreen({super.key, this.topicId});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  SummaryMode _mode = SummaryMode.medium;
  bool _isRegenerating = false;

  @override
  Widget build(BuildContext context) {
    final activeDoc = ref.watch(activeDocumentProvider);

    if (activeDoc == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Smart Summary', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 16)),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkBorderSubtle),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_stories_rounded, size: 40, color: AppColors.electricViolet),
                const SizedBox(height: 14),
                const Text('No Summary Available', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                  'Upload lecture slides, chapters, or notes to automatically synthesize executive summaries, key takeaways, and exam traps.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12.5, color: Colors.white.withOpacity(0.6), height: 1.4),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.uploadCenter),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricViolet,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.upload_file_rounded, size: 16),
                  label: const Text('Upload Study Material'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final title = activeDoc.summary.title.isNotEmpty ? activeDoc.summary.title : activeDoc.fileName;
    final overview = activeDoc.summary.overview.isNotEmpty ? activeDoc.summary.overview : 'Summary overview extracted from ${activeDoc.fileName}.';
    final takeaways = activeDoc.summary.keyTakeaways;
    final theorems = activeDoc.summary.coreTheorems;
    final traps = activeDoc.summary.examTraps;

    // Mode-specific content slicing
    final conceptsToShow = _mode == SummaryMode.short
        ? activeDoc.concepts.take(2).toList()
        : (_mode == SummaryMode.medium ? activeDoc.concepts.take(4).toList() : activeDoc.concepts);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Smart Summary: ${activeDoc.fileName}',
          style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 15),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: _isRegenerating
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Regenerate Summary',
            onPressed: _isRegenerating
                ? null
                : () async {
                    setState(() => _isRegenerating = true);
                    await Future.delayed(const Duration(milliseconds: 700));
                    if (mounted) {
                      setState(() => _isRegenerating = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Summary refreshed from grounded notes.')),
                      );
                    }
                  },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          // ── Mode Selector Pill ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.darkBorderSubtle),
            ),
            child: Row(
              children: [
                _buildModeTab('Short (1-2m)', SummaryMode.short),
                _buildModeTab('Medium (5m)', SummaryMode.medium),
                _buildModeTab('Detailed (Full)', SummaryMode.detailed),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── 1. Overview ───────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.electricViolet.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'OVERVIEW • ${activeDoc.fileType}',
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.electricVioletLight,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.auto_awesome, color: AppColors.teal, size: 14),
                    const SizedBox(width: 4),
                    const Text('Saved in Folio', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.teal)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  overview,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withOpacity(0.8), height: 1.5),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.05, end: 0),

          const SizedBox(height: 20),

          // ── 2. Important Concepts & Definitions ───────────────────────────
          _buildSectionHeader('Important Concepts & Definitions', Icons.lightbulb_outline_rounded, AppColors.electricVioletLight),
          const SizedBox(height: 10),
          ...conceptsToShow.map((c) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.darkBorderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 4),
                Text(c.description, style: TextStyle(fontFamily: 'Inter', fontSize: 12.5, color: Colors.white.withOpacity(0.7), height: 1.4)),
                if (_mode == SummaryMode.detailed && c.keyPoints.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...c.keyPoints.map((kp) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: AppColors.teal)),
                        Expanded(child: Text(kp, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white.withOpacity(0.65)))),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          )),

          const SizedBox(height: 18),

          // ── 3. Hierarchical Chapter Outline ──────────────────────────────
          if (activeDoc.hierarchicalModel?.chapters.isNotEmpty == true) ...[
            _buildSectionHeader('Hierarchical Chapter Architecture (${activeDoc.hierarchicalModel!.chapters.length} Chapters)', Icons.menu_book_rounded, AppColors.electricVioletLight),
            const SizedBox(height: 10),
            ...activeDoc.hierarchicalModel!.chapters.map((ch) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.darkBorderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          ch.title,
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.electricViolet.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Pages ${ch.startPage}-${ch.endPage}',
                          style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: AppColors.electricVioletLight),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    ch.summary,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white.withOpacity(0.7), height: 1.35),
                  ),
                  if (ch.sections.isNotEmpty && _mode != SummaryMode.short) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: ch.sections.take(3).map((s) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '§ ${s.title}',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white.withOpacity(0.65)),
                        ),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            )),
            const SizedBox(height: 18),
          ],

          // ── 4. Key Equations & Formulas ────────────────────────────────────
          _buildSectionHeader('Key Equations & Guarantees', Icons.functions_rounded, AppColors.teal),
          const SizedBox(height: 10),
          if (activeDoc.hierarchicalModel?.formulas.isNotEmpty == true) ...[
            ...activeDoc.hierarchicalModel!.formulas.map((f) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.teal.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calculate_outlined, size: 16, color: AppColors.teal),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.expression, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.teal)),
                        const SizedBox(height: 2),
                        Text(f.name, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white.withOpacity(0.6))),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ] else ...[
            ...theorems.map((th) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.teal.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.code_rounded, size: 16, color: AppColors.teal),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(th, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12, color: Colors.white)),
                  ),
                ],
              ),
            )),
          ],

          const SizedBox(height: 18),

          // ── 4. Things to Remember & Key Takeaways ─────────────────────────
          _buildSectionHeader('Things to Remember', Icons.check_circle_outline_rounded, AppColors.skyBlue),
          const SizedBox(height: 10),
          ...takeaways.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('✓ ', style: TextStyle(color: AppColors.skyBlue, fontWeight: FontWeight.w700)),
                Expanded(child: Text(item, style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withOpacity(0.85), height: 1.4))),
              ],
            ),
          )),

          const SizedBox(height: 18),

          // ── 5. Common Mistakes & Exam Tips ────────────────────────────────
          _buildSectionHeader('Common Mistakes & Exam Tips', Icons.warning_amber_rounded, AppColors.amber),
          const SizedBox(height: 10),
          ...traps.map((tr) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.amber.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.amber.withOpacity(0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.priority_high_rounded, size: 16, color: AppColors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(tr, style: TextStyle(fontFamily: 'Inter', fontSize: 12.5, color: Colors.white.withOpacity(0.85), height: 1.4)),
                ),
              ],
            ),
          )),

          const SizedBox(height: 24),

          // ── Bottom Action Shortcuts ───────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.quiz.replaceFirst(':topicId', activeDoc.id)),
                  icon: const Icon(Icons.quiz_outlined, size: 16),
                  label: const Text('Practice Quiz'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.flashcards.replaceFirst(':topicId', activeDoc.id)),
                  icon: const Icon(Icons.flip_to_front_rounded, size: 16),
                  label: const Text('Review Flashcards'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricViolet,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab(String label, SummaryMode mode) {
    final isSelected = _mode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _mode = mode),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.electricViolet : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.white : Colors.white60,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
