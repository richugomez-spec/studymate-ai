import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/graph_node.dart';

/// Interactive node widget rendering NotebookLM-style knowledge tree nodes.
/// Supports 4 node types: Subject (circle), Topic (rectangle + chevron),
/// Subtopic (dark blue card), and AI Expanded (teal badge).
class GraphNodeWidget extends StatefulWidget {
  final GraphNode node;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final VoidCallback? onToggleExpand;

  const GraphNodeWidget({
    required this.node,
    required this.onTap,
    required this.onDoubleTap,
    super.key,
    this.onToggleExpand,
  });

  @override
  State<GraphNodeWidget> createState() => _GraphNodeWidgetState();
}

class _GraphNodeWidgetState extends State<GraphNodeWidget> {
  bool _hovered = false;

  void _handleCardTap() {
    debugPrint('NODE CARD CLICKED ${widget.node.label}');
    widget.onTap();
  }

  // Exact theme colors
  static const Color _subjectGradientStart = Color(0xFF3B82F6);
  static const Color _subjectGradientEnd = Color(0xFF2563EB);
  static const Color _topicColor = Color(0xFF2F6FDD);
  static const Color _subtopicColor = Color(0xFF183B63);
  static const Color _aiNodeColor = Color(0xFF0D9488);
  static const Color _selectedHaloColor = Color(0xFF60A5FA);

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Widget childWidget = switch (node.type) {
      GraphNodeType.subject => _buildSubjectNode(node, isDark),
      GraphNodeType.topic => _buildTopicNode(node, isDark),
      GraphNodeType.subtopic => _buildSubtopicNode(node, isDark),
      GraphNodeType.aiExpanded => _buildAiNode(node, isDark),
    };

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _handleCardTap,
        onDoubleTap: widget.onDoubleTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _hovered ? 1.04 : (node.isSelected ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: childWidget,
        ),
      ),
    );
  }

  // ── 1. Subject Node (Large Circular Gradient) ────────────────────────────────

  Widget _buildSubjectNode(GraphNode node, bool isDark) {
    final isSelected = node.isSelected;
    final isHighlighted = node.isHighlighted;

    return Container(
      width: node.width,
      height: node.height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_subjectGradientStart, _subjectGradientEnd],
        ),
        border: Border.all(
          color: isSelected
              ? _selectedHaloColor
              : isHighlighted
                  ? Colors.amberAccent
                  : Colors.white.withOpacity(0.35),
          width: isSelected ? 3.0 : 2.0,
        ),
        boxShadow: [
          // Soft blue ambient glow
          BoxShadow(
            color: _subjectGradientStart.withOpacity(_hovered ? 0.65 : 0.40),
            blurRadius: _hovered ? 28 : 18,
            spreadRadius: _hovered ? 4 : 2,
          ),
          if (isSelected)
            const BoxShadow(
              color: _selectedHaloColor,
              blurRadius: 20,
              spreadRadius: 3,
            ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.hub_rounded,
              size: 26,
              color: Colors.white,
            ),
            const SizedBox(height: 6),
            Text(
              node.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.2,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 350.ms)
        .scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack);
  }

  // ── 2. Topic Node (Rounded Rectangle with Chevron) ───────────────────────────

  Widget _buildTopicNode(GraphNode node, bool isDark) {
    final isSelected = node.isSelected;
    final isHighlighted = node.isHighlighted;
    final isExpanded = node.isExpanded;
    final hasChildren = node.childCount > 0;

    return Container(
      width: node.width,
      height: node.height,
      decoration: BoxDecoration(
        color: _topicColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? _selectedHaloColor
              : isHighlighted
                  ? Colors.amberAccent
                  : Colors.white.withOpacity(0.25),
          width: isSelected ? 2.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _topicColor.withOpacity(_hovered ? 0.55 : 0.25),
            blurRadius: _hovered ? 16 : 8,
            offset: const Offset(0, 3),
          ),
          if (isSelected)
            const BoxShadow(
              color: _selectedHaloColor,
              blurRadius: 14,
              spreadRadius: 2,
            ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          // Left icon or dot
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.folder_outlined,
              size: 13,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),

          // Label
          Expanded(
            child: Text(
              node.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.1,
                height: 1.2,
              ),
            ),
          ),

          // Expand / Collapse Chevron button
          if (widget.onToggleExpand != null && hasChildren) ...[
            const SizedBox(width: 4),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                debugPrint('CHEVRON CLICKED ${node.label}');
                widget.onToggleExpand?.call();
              },
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: AnimatedRotation(
                  turns: isExpanded ? 0.0 : -0.25, // 0 = down, -0.25 = right
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 250.ms)
        .slideY(begin: 0.1, end: 0.0, curve: Curves.easeOutCubic);
  }

  // ── 3. Subtopic Node (Dark Blue Card with Notes Indicator) ────────────────────

  Widget _buildSubtopicNode(GraphNode node, bool isDark) {
    final isSelected = node.isSelected;
    final isHighlighted = node.isHighlighted;
    final hasNotes = node.notes.isNotEmpty;

    return Container(
      width: node.width,
      height: node.height,
      decoration: BoxDecoration(
        color: _subtopicColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected
              ? _selectedHaloColor
              : isHighlighted
                  ? Colors.amberAccent
                  : const Color(0xFF2F6FDD).withOpacity(0.45),
          width: isSelected ? 2.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_hovered ? 0.35 : 0.18),
            blurRadius: _hovered ? 12 : 6,
            offset: const Offset(0, 2),
          ),
          if (isSelected)
            const BoxShadow(
              color: _selectedHaloColor,
              blurRadius: 12,
              spreadRadius: 1,
            ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          // Dot indicator
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF5EA9FF),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),

          // Label
          Expanded(
            child: Text(
              node.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE2E8F0),
                letterSpacing: -0.1,
                height: 1.2,
              ),
            ),
          ),

          // Notes badge if student notes exist in Firestore
          if (hasNotes) ...[
            const SizedBox(width: 4),
            Tooltip(
              message: '${node.notes.length} saved note(s)',
              child: const Icon(
                Icons.sticky_note_2_rounded,
                size: 13,
                color: Color(0xFF38BDF8),
              ),
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 220.ms)
        .slideY(begin: 0.15, end: 0.0, curve: Curves.easeOutCubic);
  }

  // ── 4. AI Expanded Node (Temporary Teal Card) ────────────────────────────────

  Widget _buildAiNode(GraphNode node, bool isDark) {
    final isSelected = node.isSelected;

    return Container(
      width: node.width,
      height: node.height,
      decoration: BoxDecoration(
        color: _aiNodeColor.withOpacity(0.90),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? Colors.white : const Color(0xFF5EEAD4),
          width: isSelected ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _aiNodeColor.withOpacity(_hovered ? 0.60 : 0.30),
            blurRadius: _hovered ? 14 : 8,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: 13,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              node.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'AI',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 250.ms)
        .scale(begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack);
  }
}
