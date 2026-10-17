import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../core/theme/app_colors.dart';

class MindMapScreen extends ConsumerStatefulWidget {
  final String topicId;
  const MindMapScreen({super.key, required this.topicId});

  @override
  ConsumerState<MindMapScreen> createState() => _MindMapScreenState();
}

class _MindMapScreenState extends ConsumerState<MindMapScreen> {
  int? _selectedNodeIndex;

  @override
  Widget build(BuildContext context) {
    final activeDoc = ref.watch(activeDocumentProvider);

    final concepts = activeDoc?.concepts ?? [];

    if (concepts.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(
            'Semantic Knowledge Graph',
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 15),
          ),
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
                const Icon(Icons.hub_rounded, size: 40, color: AppColors.electricViolet),
                const SizedBox(height: 14),
                const Text(
                  'No Concepts to Map',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload lecture slides, chapters, or notes to automatically extract concepts and construct an interactive semantic graph.',
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

    final selected = _selectedNodeIndex != null && _selectedNodeIndex! < concepts.length
        ? concepts[_selectedNodeIndex!]
        : concepts.first;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          activeDoc != null ? 'Graph: ${activeDoc.fileName}' : 'Semantic Knowledge Graph',
          style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 15),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          // Graph header / legend
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: AppColors.darkSurface,
            child: Row(
              children: [
                _LegendItem(color: AppColors.teal, label: 'Solid (>80%)'),
                const SizedBox(width: 12),
                _LegendItem(color: AppColors.amber, label: 'Decaying (50-80%)'),
                const SizedBox(width: 12),
                _LegendItem(color: AppColors.error, label: 'Critical Gap (<50%)'),
              ],
            ),
          ),

          // Interactive Concept Node Pathway
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: concepts.length,
              itemBuilder: (ctx, i) {
                final c = concepts[i];
                final isSelected = _selectedNodeIndex == i;
                final mastery = c.initialMastery;
                final nodeColor = mastery >= 0.8
                    ? AppColors.teal
                    : mastery >= 0.55
                        ? AppColors.amber
                        : AppColors.error;

                return Column(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _selectedNodeIndex = i),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? nodeColor.withOpacity(0.12) : AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? nodeColor : AppColors.darkBorder,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: nodeColor.withOpacity(0.15),
                                border: Border.all(color: nodeColor, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  '${(mastery * 100).round()}%',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: nodeColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Node ${i + 1}',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: nodeColor,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (i == 0)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.skyBlue.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text('Prerequisite', style: TextStyle(fontSize: 9, color: AppColors.skyBlue, fontWeight: FontWeight.w600)),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    c.title,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.3)),
                          ],
                        ),
                      ),
                    ),
                    if (i < concepts.length - 1)
                      Container(
                        width: 2,
                        height: 24,
                        color: AppColors.electricViolet.withOpacity(0.3),
                      ),
                  ],
                );
              },
            ),
          ),

          // Selected Concept Details Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              border: Border(top: BorderSide(color: AppColors.darkBorder.withOpacity(0.6))),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selected.title,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'Mastery: ${(selected.initialMastery * 100).round()}%',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.teal),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  selected.description,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white.withOpacity(0.7), height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.go(AppRoutes.aiChat),
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                        label: const Text('Drill with AI Coach'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.electricViolet,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/topic/quiz/${activeDoc?.id ?? "c1"}'),
                        icon: const Icon(Icons.quiz_outlined, size: 16),
                        label: const Text('Test Node'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: Colors.white60)),
      ],
    );
  }
}
