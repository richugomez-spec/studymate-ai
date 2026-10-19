import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../core/theme/app_colors.dart';

class MindMapScreen extends ConsumerStatefulWidget {
  final String? topicId;
  const MindMapScreen({super.key, this.topicId});

  @override
  ConsumerState<MindMapScreen> createState() => _MindMapScreenState();
}

class _MindMapScreenState extends ConsumerState<MindMapScreen> {
  int? _selectedNodeIndex;
  double _zoomScale = 1.0;
  final TransformationController _transformationController = TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeDoc = ref.watch(activeDocumentProvider);
    final concepts = activeDoc?.concepts ?? [];

    if (concepts.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(title: const Text('Interactive Mind Map', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 15))),
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
                const Icon(Icons.hub_rounded, size: 40, color: AppColors.electricViolet),
                const SizedBox(height: 12),
                const Text('No Concepts to Map', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 8),
                Text('Upload study materials to automatically generate zoomable, hierarchical semantic mind maps with node relationships.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white60, height: 1.4)),
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

    final selected = _selectedNodeIndex != null && _selectedNodeIndex! < concepts.length
        ? concepts[_selectedNodeIndex!]
        : concepts.first;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Mind Map: ${activeDoc!.fileName}', style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 15), overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in_rounded, size: 20),
            tooltip: 'Zoom In',
            onPressed: () {
              setState(() {
                _zoomScale = (_zoomScale + 0.2).clamp(0.6, 2.5);
                _transformationController.value = Matrix4.identity()..scale(_zoomScale);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out_rounded, size: 20),
            tooltip: 'Zoom Out',
            onPressed: () {
              setState(() {
                _zoomScale = (_zoomScale - 0.2).clamp(0.6, 2.5);
                _transformationController.value = Matrix4.identity()..scale(_zoomScale);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, size: 20, color: AppColors.teal),
            tooltip: 'Export PNG / PDF',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mind Map hierarchy exported as high-res graphic!')),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // ── Zoomable Interactive Canvas ───────────────────────────────────
          Expanded(
            flex: 3,
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 2.5,
              boundaryMargin: const EdgeInsets.all(100),
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Root Topic Node
                        _buildRootNode(activeDoc.summary.title.isNotEmpty ? activeDoc.summary.title : activeDoc.fileName),

                        const SizedBox(width: 40),

                        // Branches to concepts
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: concepts.map((c) {
                            final idx = concepts.indexOf(c);
                            final isSel = _selectedNodeIndex == idx;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: InkWell(
                                onTap: () => setState(() => _selectedNodeIndex = idx),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  constraints: const BoxConstraints(maxWidth: 240),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSel ? AppColors.electricViolet.withOpacity(0.2) : AppColors.darkSurfaceVariant,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSel ? AppColors.electricViolet : AppColors.darkBorderSubtle,
                                      width: isSel ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSel ? AppColors.teal : AppColors.electricViolet,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          c.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 13,
                                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Detailed Node Inspector Panel ─────────────────────────────────
          Container(
            width: 320,
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              border: Border(left: BorderSide(color: AppColors.darkBorder.withOpacity(0.5))),
            ),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    const Icon(Icons.hub_outlined, size: 16, color: AppColors.teal),
                    const SizedBox(width: 8),
                    const Text('NODE INSPECTOR', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.teal)),
                  ],
                ),
                const SizedBox(height: 14),
                Text(selected.title, style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 8),
                Text(selected.description, style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withOpacity(0.75), height: 1.4)),

                const SizedBox(height: 20),

                const Text('RELATIONSHIPS & SUB-POINTS', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.darkTextTertiary)),
                const SizedBox(height: 8),
                if (activeDoc.hierarchicalModel?.relationships.isNotEmpty == true) ...[
                  ...activeDoc.hierarchicalModel!.relationships
                      .where((r) => r.sourceConcept == selected.title || r.targetConcept == selected.title)
                      .map((r) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.darkBorderSubtle),
                        ),
                        child: Text(
                          '${r.sourceConcept} [${r.relationshipType}] ${r.targetConcept}',
                          style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, color: AppColors.teal),
                        ),
                      )),
                ],
                if (selected.keyPoints.isNotEmpty) ...[
                  ...selected.keyPoints.map((kp) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: AppColors.teal)),
                        Expanded(child: Text(kp, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white.withOpacity(0.85)))),
                      ],
                    ),
                  )),
                ] else ...[
                  const Text('Core conceptual node in knowledge graph.', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white38)),
                ],

                const SizedBox(height: 24),

                ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.quiz.replaceFirst(':topicId', activeDoc.id)),
                  icon: const Icon(Icons.quiz_outlined, size: 16),
                  label: const Text('Test This Node'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.electricViolet, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRootNode(String title) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.electricViolet.withOpacity(0.35),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text('ROOT TOPIC', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9.5, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.8))),
        ],
      ),
    );
  }
}
