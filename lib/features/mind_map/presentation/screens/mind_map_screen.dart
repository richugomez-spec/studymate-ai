import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ai/services/gemini_api_key_provider.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/notifications/app_notification.dart';
import '../../../../services/firestore_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../models/graph_layout.dart';
import '../models/graph_node.dart';
import '../services/graph_ai_service.dart';
import '../widgets/graph_canvas.dart';
import '../widgets/graph_detail_panel.dart';

class MindMapScreen extends ConsumerStatefulWidget {
  final String? topicId;
  const MindMapScreen({super.key, this.topicId});

  @override
  ConsumerState<MindMapScreen> createState() => _MindMapScreenState();
}

class _MindMapScreenState extends ConsumerState<MindMapScreen> {
  final GlobalKey<GraphCanvasState> _canvasKey = GlobalKey();
  final TransformationController _transformController =
      TransformationController();
  final TextEditingController _searchController = TextEditingController();

  // Graph data
  List<GraphNode> _nodes = [];
  List<GraphEdge> _edges = [];
  bool _isLoading = true;
  bool _emptyTopics = false;
  String? _error;

  // Selection & UI state
  GraphNode? _selectedNode;
  bool _panelVisible = false;
  String? _subjectName;
  String? _topicName;

  // Search
  bool _searchFocused = false;

  // Breadcrumb
  List<String> _breadcrumb = [];

  // AI state
  bool _aiExpanding = false;
  final Map<String, List<GraphNode>> _aiChildren = {};

  late GraphAiService _aiService;

  @override
  void initState() {
    super.initState();
    _aiService = GraphAiService(
      keyManager: ref.read(apiKeyManagerProvider),
    );
    _loadGraph();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(MindMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topicId != widget.topicId) {
      _loadGraph();
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Data Loading ─────────────────────────────────────────────────────────────

  Future<void> _loadGraph() async {
    setState(() {
      _isLoading = true;
      _emptyTopics = false;
      _error = null;
    });

    try {
      final service = ref.read(firestoreServiceProvider);
      final uid =
          ref.read(currentUserProvider)?.id ?? service.currentUserId ?? '';

      // Get all subjects for this user
      var fetchedSubjects = ref.read(userSubjectsStreamProvider(uid)).asData?.value;
      if (fetchedSubjects == null || fetchedSubjects.isEmpty) {
        fetchedSubjects = await service.streamSubjects(uid).first;
      }

      final subjectList = fetchedSubjects;
      if (subjectList.isEmpty) {
        setState(() {
          _isLoading = false;
          _error = 'No subjects found. Create a subject in the Library first.';
        });
        return;
      }

      final activeSubjectId = ref.read(activeKnowledgeSubjectIdProvider);

      // Determine which subject to display
      Map<String, dynamic> subjectData;
      if (widget.topicId != null &&
          widget.topicId != 'current' &&
          widget.topicId != ':topicId' &&
          widget.topicId!.isNotEmpty) {
        subjectData = subjectList.firstWhere(
          (s) => s['id']?.toString() == widget.topicId,
          orElse: () => subjectList.firstWhere(
            (s) => s['id']?.toString() == activeSubjectId,
            orElse: () => subjectList.first,
          ),
        );
      } else if (activeSubjectId != null && activeSubjectId.isNotEmpty) {
        subjectData = subjectList.firstWhere(
          (s) => s['id']?.toString() == activeSubjectId,
          orElse: () => subjectList.first,
        );
      } else {
        subjectData = subjectList.first;
      }

      final subjectId = subjectData['id']?.toString() ?? '';
      _subjectName = subjectData['name']?.toString() ?? 'Subject';

      // Keep active subject synchronized across providers
      ref.read(activeKnowledgeSubjectIdProvider.notifier).state = subjectId;
      ref.read(activeKnowledgeSubjectNameProvider.notifier).state = _subjectName;

      // Load topic + subtopic hierarchy from Firestore
      List<Map<String, dynamic>> topicsWithSubtopics = [];
      try {
        topicsWithSubtopics =
            await service.getSubjectTopicsWithSubtopics(subjectId);
      } catch (err) {
        debugPrint(
            'getSubjectTopicsWithSubtopics error ($err), falling back to loadSubjectStudyHierarchy');
        final hierarchy = await service.loadSubjectStudyHierarchy(subjectId);
        if (hierarchy != null && hierarchy['topics'] is List) {
          topicsWithSubtopics =
              List<Map<String, dynamic>>.from(hierarchy['topics'] as List);
        }
      }

      if (topicsWithSubtopics.isEmpty) {
        final hierarchy = await service.loadSubjectStudyHierarchy(subjectId);
        if (hierarchy != null && hierarchy['topics'] is List) {
          final hTopics =
              List<Map<String, dynamic>>.from(hierarchy['topics'] as List);
          if (hTopics.isNotEmpty) {
            topicsWithSubtopics = hTopics;
          }
        }
      }

      if (topicsWithSubtopics.isEmpty) {
        debugPrint('Loaded Subject: $_subjectName');
        debugPrint('Topics: 0');
        debugPrint('Subtopics: 0');
        debugPrint('Nodes Built: 0');
        debugPrint('Edges Built: 0');
        if (mounted) {
          setState(() {
            _nodes = [];
            _edges = [];
            _emptyTopics = true;
            _isLoading = false;
          });
        }
        return;
      }

      _buildGraph(
        subjectId: subjectId,
        subjectName: _subjectName!,
        topics: topicsWithSubtopics,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load knowledge graph: $e';
        });
      }
    }
  }

  void _buildGraph({
    required String subjectId,
    required String subjectName,
    required List<Map<String, dynamic>> topics,
  }) {
    final nodes = <GraphNode>[];
    final edges = <GraphEdge>[];

    // Root subject node
    final rootNode = GraphNode(
      id: subjectId,
      label: subjectName,
      type: GraphNodeType.subject,
    );
    nodes.add(rootNode);

    int subtopicCount = 0;

    // Topic nodes
    for (final topic in topics) {
      final topicId = topic['id']?.toString() ?? '';
      final topicName = topic['name']?.toString() ?? 'Topic';

      final topicNode = GraphNode(
        id: topicId,
        label: topicName,
        type: GraphNodeType.topic,
        parentId: subjectId,
        subjectId: subjectId,
      );
      nodes.add(topicNode);
      edges.add(GraphEdge(fromId: subjectId, toId: topicId));

      // Subtopic nodes
      final subtopics =
          (topic['subtopics'] as List? ?? []).cast<Map<String, dynamic>>();
      subtopicCount += subtopics.length;
      for (final sub in subtopics) {
        final subId = sub['id']?.toString() ?? '';
        final subName = sub['name']?.toString() ?? 'Subtopic';

        final subNode = GraphNode(
          id: subId,
          label: subName,
          type: GraphNodeType.subtopic,
          parentId: topicId,
          topicId: topicId,
          subjectId: subjectId,
        );
        nodes.add(subNode);
        edges.add(GraphEdge(fromId: topicId, toId: subId));
      }
    }

    // Temporary debug logs for Step 7
    debugPrint('Loaded Subject: $subjectName');
    debugPrint('Topics: ${topics.length}');
    debugPrint('Subtopics: $subtopicCount');
    debugPrint('Nodes Built: ${nodes.length}');
    debugPrint('Edges Built: ${edges.length}');

    // Run layout
    final laidOut = GraphLayoutEngine.layout(nodes, edges);

    setState(() {
      _nodes = laidOut;
      _edges = edges;
      _emptyTopics = false;
      _isLoading = false;
    });

    // Fit to screen after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final size = MediaQuery.of(context).size;
        _canvasKey.currentState?.fitToScreen(size);
      }
    });
  }

  // ── Graph Interactions ───────────────────────────────────────────────────────

  void _onNodeTap(GraphNode node) {
    HapticFeedback.selectionClick();
    setState(() {
      // Deselect all
      _nodes = _nodes.map((n) => n.copyWith(isSelected: false)).toList();
      // Select tapped
      final idx = _nodes.indexWhere((n) => n.id == node.id);
      if (idx >= 0) {
        _nodes[idx] = _nodes[idx].copyWith(isSelected: true);
        _selectedNode = _nodes[idx];
      }
      // Update breadcrumb
      _updateBreadcrumb(node);
      // Update topicName for detail panel
      if (node.type == GraphNodeType.topic) {
        _topicName = node.label;
      } else if (node.type == GraphNodeType.subtopic) {
        _topicName = _findParentLabel(node);
      }
      _panelVisible = true;
    });
  }

  void _onNodeDoubleTap(GraphNode node) {
    final size = MediaQuery.of(context).size;
    _canvasKey.currentState?.centerOn(node, size);
  }

  void _onToggleExpand(String nodeId) {
    setState(() {
      final idx = _nodes.indexWhere((n) => n.id == nodeId);
      if (idx < 0) return;
      final node = _nodes[idx];
      final newExpanded = !node.isExpanded;
      _nodes[idx] = node.copyWith(isExpanded: newExpanded);

      // Show/hide children
      _setChildrenVisible(nodeId, newExpanded);
    });
    // Re-run layout
    _relayout();
  }

  void _setChildrenVisible(String parentId, bool visible) {
    for (var i = 0; i < _nodes.length; i++) {
      if (_nodes[i].parentId == parentId) {
        _nodes[i] = _nodes[i].copyWith(isVisible: visible);
        if (!visible) {
          // Recursively hide grandchildren
          _setChildrenVisible(_nodes[i].id, false);
        }
      }
    }
  }

  void _relayout() {
    final laidOut = GraphLayoutEngine.layout(_nodes, _edges);
    setState(() => _nodes = laidOut);
  }

  void _closePanel() {
    setState(() {
      _panelVisible = false;
      _selectedNode = null;
      _nodes = _nodes.map((n) => n.copyWith(isSelected: false)).toList();
    });
  }

  // ── AI Expansion ─────────────────────────────────────────────────────────────

  Future<void> _expandNodeWithAI(GraphNode node) async {
    if (_aiExpanding) return;
    setState(() => _aiExpanding = true);

    AppNotification.showLoading(
      context: context,
      title: 'Expanding with AI',
      message: 'Generating sub-concepts for "${node.label}"…',
    );

    try {
      final result = await _aiService.expandNode(
        nodeLabel: node.label,
        subjectName: _subjectName,
        topicName: _topicName,
      );

      AppNotification.dismissAll();

      if (!mounted) return;
      if (result.childLabels.isEmpty) {
        AppNotification.showWarning(
          context: context,
          message: 'AI could not generate expansions for this node.',
        );
        return;
      }

      // Remove previous AI children for this node
      final previousAiIds =
          (_aiChildren[node.id] ?? []).map((n) => n.id).toSet();
      setState(() {
        _nodes.removeWhere((n) => previousAiIds.contains(n.id));
        _edges.removeWhere((e) => previousAiIds.contains(e.toId));
      });

      // Add new AI nodes
      final newNodes = result.childLabels.asMap().entries.map((entry) {
        final aiId = 'ai_${node.id}_${entry.key}_${entry.value.hashCode}';
        return GraphNode(
          id: aiId,
          label: entry.value,
          type: GraphNodeType.aiExpanded,
          parentId: node.id,
          topicId: node.topicId ?? node.id,
          subjectId: node.subjectId,
          isAiGenerated: true,
        );
      }).toList();

      final newEdges = newNodes
          .map((n) => GraphEdge(fromId: node.id, toId: n.id))
          .toList();

      _aiChildren[node.id] = newNodes;

      setState(() {
        _nodes = [..._nodes, ...newNodes];
        _edges = [..._edges, ...newEdges];
      });

      _relayout();

      if (!mounted) return;
      AppNotification.showSuccess(
        context: context,
        message: '${newNodes.length} AI concepts added!',
      );
    } catch (e) {
      if (mounted) {
        AppNotification.dismissAll();
        AppNotification.showError(
          context: context,
          message: 'AI expansion failed. Check your API key.',
        );
      }
    } finally {
      if (mounted) setState(() => _aiExpanding = false);
    }
  }

  // ── Search ───────────────────────────────────────────────────────────────────

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _nodes = _nodes.map((n) => n.copyWith(isHighlighted: false)).toList();
      } else {
        _nodes = _nodes.map((n) {
          final matches = n.label.toLowerCase().contains(query);
          return n.copyWith(isHighlighted: matches);
        }).toList();
      }
    });
  }

  void _onSearchSubmit(String value) {
    if (value.isEmpty) return;
    final match = _nodes.firstWhere(
      (n) => n.label.toLowerCase().contains(value.toLowerCase()),
      orElse: () => _nodes.first,
    );
    final size = MediaQuery.of(context).size;
    _canvasKey.currentState?.centerOn(match, size);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  void _updateBreadcrumb(GraphNode node) {
    _breadcrumb = [
      if (_subjectName != null) _subjectName!,
      if (node.type == GraphNodeType.topic) node.label,
      if (node.type == GraphNodeType.subtopic || node.type == GraphNodeType.aiExpanded) ...[
        _findParentLabel(node),
        node.label,
      ],
    ].whereType<String>().where((s) => s.isNotEmpty).toList();
  }

  String _findParentLabel(GraphNode node) {
    if (node.parentId == null) return '';
    return _nodes
        .firstWhere(
          (n) => n.id == node.parentId,
          orElse: () => GraphNode(id: '', label: '', type: GraphNodeType.topic),
        )
        .label;
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Column(
        children: [
          _buildTopBar(isDark),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _error != null
                    ? _buildErrorState()
                    : _emptyTopics || _nodes.isEmpty
                        ? _buildEmptyTopicsState(isDark)
                        : _buildGraphArea(isDark, isDesktop),
          ),
        ],
      ),
    );
  }

  // ── Top Bar ──────────────────────────────────────────────────────────────────

  Widget _buildTopBar(bool isDark) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.library);
              }
            },
            tooltip: 'Back',
          ),
          const SizedBox(width: 4),

          // Subject title / breadcrumb
          Expanded(
            child: _breadcrumb.isEmpty
                ? Text(
                    _subjectName ?? 'Knowledge Graph',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  )
                : _buildBreadcrumbRow(isDark),
          ),

          // Search bar
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: _searchFocused ? 220 : 140,
            height: 34,
            child: TextField(
              controller: _searchController,
              onTap: () => setState(() => _searchFocused = true),
              onEditingComplete: () {
                _onSearchSubmit(_searchController.text);
                setState(() => _searchFocused = false);
              },
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search nodes…',
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
                prefixIcon: const Icon(Icons.search_rounded, size: 16),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppColors.brandAccent),
                ),
                filled: true,
                fillColor: isDark ? AppColors.darkCard : AppColors.lightSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Control buttons
          _ControlButton(
            icon: Icons.fit_screen_rounded,
            tooltip: 'Fit to screen',
            isDark: isDark,
            onTap: () {
              final size = MediaQuery.of(context).size;
              _canvasKey.currentState?.fitToScreen(size);
            },
          ),
          _ControlButton(
            icon: Icons.center_focus_strong_rounded,
            tooltip: 'Reset view',
            isDark: isDark,
            onTap: () => _canvasKey.currentState?.resetView(),
          ),
          _ControlButton(
            icon: Icons.refresh_rounded,
            tooltip: 'Reload graph',
            isDark: isDark,
            onTap: _loadGraph,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 240.ms);
  }

  Widget _buildBreadcrumbRow(bool isDark) {
    return Row(
      children: _breadcrumb.asMap().entries.expand((entry) {
        final isLast = entry.key == _breadcrumb.length - 1;
        return [
          Text(
            entry.value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              fontWeight: isLast ? FontWeight.w700 : FontWeight.w400,
              color: isLast
                  ? (isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary)
                  : (isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary),
            ),
          ),
          if (!isLast)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 14,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
        ];
      }).toList(),
    );
  }

  // ── Graph Area ───────────────────────────────────────────────────────────────

  void _navigateTool(String tool, String nodeId) {
    final route = switch (tool) {
      'flashcards' => AppRoutes.flashcards,
      'quiz' => AppRoutes.quiz,
      'summary' => AppRoutes.summary,
      _ => AppRoutes.flashcards,
    };
    context.go(route.replaceFirst(':topicId', nodeId));
  }

  Widget _buildGraphArea(bool isDark, bool isDesktop) {
    final canvas = GraphCanvas(
      key: _canvasKey,
      nodes: _nodes,
      edges: _edges,
      transformController: _transformController,
      onNodeTap: _onNodeTap,
      onNodeDoubleTap: _onNodeDoubleTap,
      onToggleExpand: _onToggleExpand,
    );

    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: canvas),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: _panelVisible && _selectedNode != null
                ? GraphDetailPanel(
                    node: _selectedNode!,
                    aiService: _aiService,
                    subjectName: _subjectName,
                    topicName: _topicName,
                    onClose: _closePanel,
                    onAiExpand: () => _expandNodeWithAI(_selectedNode!),
                    onNavigateTool: _navigateTool,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      );
    }

    // Mobile: canvas full + bottom sheet
    return Stack(
      children: [
        canvas,
        if (_panelVisible && _selectedNode != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GraphDetailPanel(
              node: _selectedNode!,
              aiService: _aiService,
              subjectName: _subjectName,
              topicName: _topicName,
              onClose: _closePanel,
              onAiExpand: () => _expandNodeWithAI(_selectedNode!),
              onNavigateTool: _navigateTool,
            ),
          ).animate().slideY(
                begin: 1.0,
                end: 0.0,
                duration: 300.ms,
                curve: Curves.easeOutCubic,
              ),
      ],
    );
  }

  // ── Loading / Error States ───────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.brandAccent,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Building Knowledge Graph…',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.brandAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hub_outlined, size: 56, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadGraph,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTopicsState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightSurface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: const Icon(
              Icons.hub_outlined,
              size: 48,
              color: AppColors.brandAccent,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Topics Found',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Add topics to begin building your knowledge graph.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.go(AppRoutes.library),
            icon: const Icon(Icons.menu_book_rounded, size: 18),
            label: const Text('Open Library'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Control Button ─────────────────────────────────────────────────────────────

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isDark;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.tooltip,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 34,
          height: 34,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkCard
                : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ),
    );
  }
}
