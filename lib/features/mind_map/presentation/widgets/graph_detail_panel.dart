import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/graph_node.dart';
import '../services/graph_ai_service.dart';

/// Google NotebookLM-style Glassmorphic popup modal (Desktop) and bottom sheet (Mobile)
///
/// Features:
/// - Topic / Subtopic Name
/// - Overview (AI explanation grounded in student notes)
/// - Key Concepts (• bullet points)
/// - Detailed Explanation (teacher-style clarity)
/// - Examples (practical & real-world)
/// - Exam Points (high yield points & exam questions)
/// - Related Subtopics (interactive navigation chips)
/// - Action shortcuts (Flashcards, Quiz, Summary)
/// - Glassmorphism blur background with smooth animations
class GraphDetailPanel extends ConsumerStatefulWidget {
  final GraphNode node;
  final GraphAiService aiService;
  final VoidCallback onClose;
  final String? subjectName;
  final String? topicName;
  final String? resolvedNotes;
  final List<String> relatedSubtopics;
  final void Function(String subtopicLabel)? onSelectSubtopic;
  final VoidCallback? onAiExpand;
  final void Function(String route, String nodeId)? onNavigateTool;

  const GraphDetailPanel({
    required this.node,
    required this.aiService,
    required this.onClose,
    super.key,
    this.subjectName,
    this.topicName,
    this.resolvedNotes,
    this.relatedSubtopics = const [],
    this.onSelectSubtopic,
    this.onAiExpand,
    this.onNavigateTool,
  });

  @override
  ConsumerState<GraphDetailPanel> createState() => _GraphDetailPanelState();
}

class _GraphDetailPanelState extends ConsumerState<GraphDetailPanel> {
  NodeExplanation? _explanation;
  bool _loading = false;
  String? _error;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    debugPrint('OPEN DETAIL PANEL ${widget.node.label}');
    _loadExplanation();
  }

  @override
  void didUpdateWidget(GraphDetailPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.node.id != widget.node.id ||
        oldWidget.node.label != widget.node.label ||
        oldWidget.resolvedNotes != widget.resolvedNotes) {
      _loadExplanation();
    }
  }

  Future<void> _loadExplanation() async {
    debugPrint('DETAIL PANEL LOADING ${widget.node.label}');
    final curId = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final explanation = await widget.aiService.explainNodeWithCache(
        nodeKey: widget.node.id,
        nodeLabel: widget.node.label,
        nodeType: widget.node.type,
        notes: widget.resolvedNotes,
        summary: widget.node.description,
        subjectName: widget.subjectName,
        topicName: widget.topicName,
      );

      if (mounted && curId == _requestId) {
        setState(() {
          _explanation = explanation;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted && curId == _requestId) {
        setState(() {
          _error = 'Could not generate explanation: $e';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    if (isDesktop) {
      return _buildDesktopModal();
    }
    return _buildMobileBottomSheet();
  }

  // ── Desktop Floating Glassmorphic Modal ──────────────────────────────────────

  Widget _buildDesktopModal() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 540,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: const Color(0xEE0B192E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF23426E).withOpacity(0.85),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.55),
                blurRadius: 36,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.12),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: _panelContent(),
        ),
      ),
    );
  }

  // ── Mobile Bottom Sheet ──────────────────────────────────────────────────────

  Widget _buildMobileBottomSheet() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.80,
          ),
          decoration: BoxDecoration(
            color: const Color(0xF50B192E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: const Color(0xFF23426E).withOpacity(0.85),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 30,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: _panelContent(),
        ),
      ),
    );
  }

  // ── Unified Content ──────────────────────────────────────────────────────────

  Widget _panelContent() {
    final node = widget.node;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Header: Badge, Title, Breadcrumbs, Close Button ──────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 14, 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF1E3A5F))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _nodeTypeBadge(node.type),
                  const Spacer(),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(32, 32),
                      padding: EdgeInsets.zero,
                    ),
                    tooltip: 'Close popup',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                node.label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: Colors.white,
                ),
              ),
              if (_breadcrumb().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  _breadcrumb(),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ],
          ),
        ),

        // ── Scrollable Body ──────────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            physics: const BouncingScrollPhysics(),
            child: _loading
                ? _buildLoadingState()
                : _error != null
                    ? _buildErrorState()
                    : _buildExplanationSections(),
          ),
        ),
      ],
    );
  }

  // ── Loading Skeleton / Indicator ─────────────────────────────────────────────

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Synthesizing Concept Insights...',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Grounding in syllabus notes & key relationships',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  // ── Error State ──────────────────────────────────────────────────────────────

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: Colors.amberAccent, size: 28),
          const SizedBox(height: 12),
          Text(
            _error ?? 'An unexpected error occurred.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Color(0xFFE2E8F0),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadExplanation,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Explanation Sections (NotebookLM Style) ──────────────────────────────────

  Widget _buildExplanationSections() {
    final exp = _explanation;
    if (exp == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Overview
        if (exp.overview.isNotEmpty) ...[
          _sectionHeader(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Overview',
            color: const Color(0xFF38BDF8),
          ),
          const SizedBox(height: 8),
          _textCard(exp.overview),
          const SizedBox(height: 20),
        ],

        // 2. Key Concepts
        if (exp.keyConcepts.isNotEmpty) ...[
          _sectionHeader(
            icon: Icons.checklist_rounded,
            title: 'Key Concepts',
            color: const Color(0xFF34D399),
          ),
          const SizedBox(height: 8),
          _bulletCard(exp.keyConcepts),
          const SizedBox(height: 20),
        ],

        // 3. Detailed Explanation
        if (exp.detailedExplanation.isNotEmpty) ...[
          _sectionHeader(
            icon: Icons.menu_book_outlined,
            title: 'Detailed Explanation',
            color: const Color(0xFF818CF8),
          ),
          const SizedBox(height: 8),
          _textCard(exp.detailedExplanation),
          const SizedBox(height: 20),
        ],

        // 4. Examples
        if (exp.examples.isNotEmpty || exp.realWorldExample.isNotEmpty) ...[
          _sectionHeader(
            icon: Icons.psychology_outlined,
            title: 'Examples',
            color: const Color(0xFFFBBF24),
          ),
          const SizedBox(height: 8),
          _textCard(
            [
              if (exp.examples.isNotEmpty) exp.examples,
              if (exp.realWorldExample.isNotEmpty)
                'Real-World Application:\n${exp.realWorldExample}',
            ].join('\n\n'),
          ),
          const SizedBox(height: 20),
        ],

        // 5. Exam Points
        if (exp.examQuestions.isNotEmpty || exp.whyMatters.isNotEmpty) ...[
          _sectionHeader(
            icon: Icons.assignment_turned_in_outlined,
            title: 'Exam Points',
            color: const Color(0xFFF472B6),
          ),
          const SizedBox(height: 8),
          _textCard(
            [
              if (exp.examQuestions.isNotEmpty) exp.examQuestions,
              if (exp.whyMatters.isNotEmpty)
                'Exam Significance:\n${exp.whyMatters}',
            ].join('\n\n'),
          ),
          const SizedBox(height: 20),
        ],

        // 6. Related Subtopics
        if (widget.relatedSubtopics.isNotEmpty) ...[
          _sectionHeader(
            icon: Icons.hub_outlined,
            title: 'Related Subtopics',
            color: const Color(0xFF2DD4BF),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.relatedSubtopics.map((subtopic) {
              return ActionChip(
                label: Text(
                  subtopic,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: const Color(0xFF1E3A5F),
                side: const BorderSide(color: Color(0xFF2D5788)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onPressed: () => widget.onSelectSubtopic?.call(subtopic),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // 7. Quick Study Shortcuts
        _quickActionShortcuts(),
      ],
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _textCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x77162C4E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13.5,
          height: 1.55,
          color: Color(0xFFE2E8F0),
        ),
      ),
    );
  }

  Widget _bulletCard(String bulletsText) {
    final lines = bulletsText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x77162C4E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((line) {
          final formattedLine = line.startsWith('•') ||
                  line.startsWith('-') ||
                  line.startsWith('*')
              ? line
              : '• $line';
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              formattedLine,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.5,
                height: 1.45,
                color: Color(0xFFE2E8F0),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _quickActionShortcuts() {
    final node = widget.node;
    final targetId = node.topicId ?? node.id;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x441E3A5F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2D5788)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 6,
        children: [
          TextButton.icon(
            onPressed: () =>
                widget.onNavigateTool?.call('flashcards', targetId),
            icon: const Icon(Icons.style_rounded,
                size: 16, color: Color(0xFF38BDF8)),
            label: const Text(
              'Flashcards',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Color(0xFF38BDF8),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => widget.onNavigateTool?.call('quiz', targetId),
            icon: const Icon(Icons.quiz_rounded,
                size: 16, color: Color(0xFF34D399)),
            label: const Text(
              'Take Quiz',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Color(0xFF34D399),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => widget.onNavigateTool?.call('summary', targetId),
            icon: const Icon(Icons.article_rounded,
                size: 16, color: Color(0xFFFBBF24)),
            label: const Text(
              'Summary',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Color(0xFFFBBF24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _nodeTypeBadge(GraphNodeType type) {
    final (label, color) = switch (type) {
      GraphNodeType.subject => ('SUBJECT', const Color(0xFF3B82F6)),
      GraphNodeType.topic => ('TOPIC', const Color(0xFF2F6FDD)),
      GraphNodeType.subtopic => ('SUBTOPIC', const Color(0xFF38BDF8)),
      GraphNodeType.aiExpanded => ('AI EXPANDED', const Color(0xFF0D9488)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: color,
        ),
      ),
    );
  }

  String _breadcrumb() {
    final parts = <String>[];
    if (widget.subjectName != null && widget.subjectName!.isNotEmpty) {
      parts.add(widget.subjectName!);
    }
    if (widget.topicName != null &&
        widget.topicName!.isNotEmpty &&
        widget.topicName != widget.node.label) {
      parts.add(widget.topicName!);
    }
    return parts.join('  ›  ');
  }
}
