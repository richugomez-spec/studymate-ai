import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/graph_node.dart';
import '../services/graph_ai_service.dart';

/// Side panel / bottom sheet shown when a graph node is selected.
/// On desktop: slides in from right. On mobile: bottom sheet.
class GraphDetailPanel extends StatefulWidget {
  final GraphNode node;
  final String? subjectName;
  final String? topicName;
  final GraphAiService aiService;
  final VoidCallback? onAiExpand;
  final VoidCallback onClose;
  final void Function(String route, String nodeId)? onNavigateTool;

  const GraphDetailPanel({
    super.key,
    required this.node,
    required this.aiService,
    required this.onClose,
    this.subjectName,
    this.topicName,
    this.onAiExpand,
    this.onNavigateTool,
  });

  @override
  State<GraphDetailPanel> createState() => _GraphDetailPanelState();
}

class _GraphDetailPanelState extends State<GraphDetailPanel> {
  NodeExplanation? _explanation;
  bool _loading = false;
  String? _error;
  int _selectedTab = 0;

  static const _tabs = [
    'Overview',
    'Key Concepts',
    'Explanation',
    'Examples',
    'Q&A',
    'Memory',
  ];

  @override
  void initState() {
    super.initState();
    _loadExplanation();
  }

  @override
  void didUpdateWidget(GraphDetailPanel old) {
    super.didUpdateWidget(old);
    if (old.node.id != widget.node.id) {
      _explanation = null;
      _selectedTab = 0;
      _loadExplanation();
    }
  }

  Future<void> _loadExplanation() async {
    if (widget.node.type == GraphNodeType.subject) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final explanation = await widget.aiService.explainNode(
        nodeLabel: widget.node.label,
        nodeType: widget.node.type,
        subjectName: widget.subjectName,
        topicName: widget.topicName,
      );
      if (mounted) setState(() => _explanation = explanation);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width > 900;

    if (isDesktop) {
      return _buildDesktopPanel(isDark);
    }
    return _buildMobileSheet(isDark);
  }

  Widget _buildDesktopPanel(bool isDark) {
    return Container(
      width: 380,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          left: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: _panelContent(isDark),
    );
  }

  Widget _buildMobileSheet(bool isDark) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: _panelContent(isDark),
    );
  }

  Widget _panelContent(bool isDark) {
    final node = widget.node;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 12, 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _nodeTypeBadge(node.type, isDark),
                  const Spacer(),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                      size: 20,
                    ),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(32, 32),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                node.label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              // Breadcrumb
              if (widget.subjectName != null || widget.topicName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _breadcrumb(),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ── Quick Action Buttons ─────────────────────────────────────────────
        if (node.type != GraphNodeType.subject)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: _quickActions(isDark),
          ),

        // ── Tab Bar ─────────────────────────────────────────────────────────
        if (node.type != GraphNodeType.subject)
          Container(
            margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) => _tabChip(i, isDark),
            ),
          ),

        // ── Content ─────────────────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _tabContent(isDark),
          ),
        ),
      ],
    );
  }

  Widget _quickActions(bool isDark) {
    final node = widget.node;
    final nodeId = node.topicId ?? node.id;
    final actions = [
      (Icons.style_rounded, 'Flashcards', AppColors.brandAccent,
          () => widget.onNavigateTool?.call('flashcards', nodeId)),
      (Icons.quiz_rounded, 'Quiz', AppColors.success,
          () => widget.onNavigateTool?.call('quiz', nodeId)),
      (Icons.summarize_rounded, 'Summary', AppColors.amber,
          () => widget.onNavigateTool?.call('summary', nodeId)),
      (Icons.auto_awesome_rounded, 'Expand AI', AppColors.teal,
          widget.onAiExpand),
    ];

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final (icon, label, color, action) = actions[i];
          return _ActionChip(
            icon: icon,
            label: label,
            color: color,
            isDark: isDark,
            onTap: action,
          );
        },
      ),
    );
  }


  Widget _tabChip(int index, bool isDark) {
    final selected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.brandAccent
              : (isDark
                  ? AppColors.darkCard
                  : AppColors.lightSurfaceVariant),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.brandAccent
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Text(
          _tabs[index],
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }

  Widget _tabContent(bool isDark) {
    final node = widget.node;

    // Subject node — show subject overview
    if (node.type == GraphNodeType.subject) {
      return _SectionContent(
        title: 'Knowledge Graph',
        content:
            'This is the root of your knowledge graph for "${node.label}".\n\n'
            'Click any Topic or Subtopic node to explore AI-powered explanations.\n\n'
            '• Pan: Drag the canvas\n'
            '• Zoom: Scroll or pinch\n'
            '• Expand/Collapse: Arrow button on Topic nodes\n'
            '• AI Expand: Add AI-generated child nodes\n'
            '• Double-click: Center the view',
        isDark: isDark,
      );
    }

    if (_loading) {
      return const _LoadingPlaceholder();
    }
    if (_error != null) {
      return _ErrorView(error: _error!, onRetry: _loadExplanation);
    }
    if (_explanation == null) {
      return const _LoadingPlaceholder();
    }

    final exp = _explanation!;
    switch (_selectedTab) {
      case 0:
        return _SectionContent(
          title: 'Overview',
          content: exp.overview,
          isDark: isDark,
        );
      case 1:
        return _SectionContent(
          title: 'Key Concepts',
          content: exp.keyConcepts,
          isDark: isDark,
          isBulletList: true,
        );
      case 2:
        return _SectionContent(
          title: 'Detailed Explanation',
          content: exp.detailedExplanation,
          isDark: isDark,
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionContent(
              title: 'Examples',
              content: exp.examples,
              isDark: isDark,
            ),
            if (exp.formulas.isNotEmpty) ...[
              const SizedBox(height: 12),
              _SectionContent(
                title: 'Formulas',
                content: exp.formulas,
                isDark: isDark,
                isCode: true,
              ),
            ],
          ],
        );
      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionContent(
              title: 'Interview Questions',
              content: exp.interviewQuestions,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _SectionContent(
              title: 'Exam Questions',
              content: exp.examQuestions,
              isDark: isDark,
            ),
          ],
        );
      case 5:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionContent(
              title: 'Memory Tricks',
              content: exp.memoryTricks,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _SectionContent(
              title: 'Summary',
              content: exp.summary,
              isDark: isDark,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _breadcrumb() {
    final parts = <String>[];
    if (widget.subjectName != null) parts.add(widget.subjectName!);
    if (widget.topicName != null && widget.topicName != widget.node.label) {
      parts.add(widget.topicName!);
    }
    if (widget.node.type == GraphNodeType.subtopic ||
        widget.node.type == GraphNodeType.aiExpanded) {
      parts.add(widget.node.label);
    }
    return parts.join(' › ');
  }

  Widget _nodeTypeBadge(GraphNodeType type, bool isDark) {
    final (label, color) = switch (type) {
      GraphNodeType.subject => ('Subject', AppColors.brandAccent),
      GraphNodeType.topic => ('Topic', AppColors.brandAccent),
      GraphNodeType.subtopic => ('Subtopic', AppColors.success),
      GraphNodeType.aiExpanded => ('AI Expanded', AppColors.teal),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Supporting Widgets ────────────────────────────────────────────────────────

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback? onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionContent extends StatelessWidget {
  final String title;
  final String content;
  final bool isDark;
  final bool isBulletList;
  final bool isCode;

  const _SectionContent({
    required this.title,
    required this.content,
    required this.isDark,
    this.isBulletList = false,
    this.isCode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: AppColors.brandAccent,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkCard
                : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: isCode
              ? Text(
                  content,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                )
              : Text(
                  content,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    height: 1.55,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
        ),
      ],
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.brandAccent,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'AI is generating explanation…',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5,
                color: AppColors.brandAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _shimmerBox(180),
        const SizedBox(height: 8),
        _shimmerBox(120),
        const SizedBox(height: 8),
        _shimmerBox(150),
      ],
    );
  }

  Widget _shimmerBox(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.error_outline_rounded,
            color: AppColors.error, size: 32),
        const SizedBox(height: 8),
        Text(
          'Could not load explanation',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text('Retry'),
        ),
      ],
    );
  }
}
