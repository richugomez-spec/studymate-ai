import 'dart:async';
import 'dart:convert';

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

/// The Knowledge Tree Mind Map screen inspired by Google NotebookLM.
/// Features:
/// - Buchheim-Walker hierarchical tree layout
/// - Smooth animated cubic Bézier curve connections
/// - Collapsible topics with smooth branch reflow
/// - Student notes from Firestore & AI-assisted exploration
/// - Node search with animated camera focus
/// - Full mouse wheel zoom, pinch, pan, fit-to-screen
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

  // Knowledge Tree Data
  List<GraphNode> _nodes = [];
  List<GraphEdge> _edges = [];
  bool _isLoading = true;
  bool _syncing = false;
  bool _emptyTopics = false;
  String? _error;

  // Selected node & side panel
  GraphNode? _selectedNode;
  bool _panelVisible = false;
  String? _subjectName;
  String? _topicName;
  List<Map<String, dynamic>> _subjectNotes = [];
  Timer? _libraryChangeDebounce;
  String? _lastLibraryVersion;
  int _graphRequestId = 0;

  // Search state
  bool _searchFocused = false;

  // Breadcrumbs
  List<String> _breadcrumb = [];

  // Temporary AI expanded children
  bool _aiExpanding = false;
  final Map<String, List<GraphNode>> _aiChildren = {};

  late GraphAiService _aiService;

  // Application theme constants
  static const Color _canvasBackground = Color(0xFF08192D);
  static const Color _topBarBackground = Color(0xFF08192D);
  static const Color _subtleBorder = Color(0xFF1E3A5F);

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
    _libraryChangeDebounce?.cancel();
    _transformController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Data Loading from Firestore ──────────────────────────────────────────────

  Future<void> _loadGraph({bool backgroundRefresh = false}) async {
    final requestId = ++_graphRequestId;
    setState(() {
      _isLoading = !backgroundRefresh;
      _syncing = backgroundRefresh;
      _emptyTopics = false;
      _error = null;
      _subjectNotes = [];
    });

    try {
      final service = ref.read(firestoreServiceProvider);
      final uid =
          ref.read(currentUserProvider)?.id ?? service.currentUserId ?? '';

      // Get all subjects for this user
      var fetchedSubjects =
          ref.read(userSubjectsStreamProvider(uid)).asData?.value;
      if (fetchedSubjects == null || fetchedSubjects.isEmpty) {
        fetchedSubjects = await service.streamSubjects(uid).first;
      }
      if (!mounted || requestId != _graphRequestId) return;

      final subjectList = fetchedSubjects;
      if (subjectList.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _syncing = false;
            _selectedNode = null;
            _panelVisible = false;
            _breadcrumb = [];
            _error =
                'No subjects found. Create a subject in the Library first.';
          });
        }
        return;
      }

      final activeSubjectId = ref.read(activeKnowledgeSubjectIdProvider);

      // Resolve which subject to open
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

      // Keep active subject synchronized
      ref.read(activeKnowledgeSubjectIdProvider.notifier).state = subjectId;
      ref.read(activeKnowledgeSubjectNameProvider.notifier).state =
          _subjectName;

      // Load hierarchy with full notes from Firestore
      List<Map<String, dynamic>> topicsWithSubtopics = [];
      String? subjectSummary;
      try {
        final hierarchy = await service.loadSubjectStudyHierarchy(subjectId);
        if (hierarchy != null && hierarchy['topics'] is List) {
          topicsWithSubtopics =
              List<Map<String, dynamic>>.from(hierarchy['topics'] as List);
          _subjectNotes = (hierarchy['subjectNotes'] as List? ?? [])
              .cast<Map<String, dynamic>>();
          final currentSubject =
              hierarchy['subject'] as Map<String, dynamic>? ?? const {};
          _subjectName = currentSubject['name']?.toString() ?? _subjectName;
          subjectSummary = (currentSubject['summary'] ??
                  currentSubject['studySummary'] ??
                  currentSubject['description'])
              ?.toString();
          ref.read(activeKnowledgeSubjectNameProvider.notifier).state =
              _subjectName;
        }
      } catch (err) {
        debugPrint(
            'loadSubjectStudyHierarchy error ($err), falling back to getSubjectTopicsWithSubtopics');
        topicsWithSubtopics =
            await service.getSubjectTopicsWithSubtopics(subjectId);
      }
      if (!mounted || requestId != _graphRequestId) return;

      if (topicsWithSubtopics.isEmpty) {
        // Step 7 debug logs for empty state
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
            _syncing = false;
            _selectedNode = null;
            _panelVisible = false;
            _breadcrumb = [];
            _topicName = null;
          });
        }
        return;
      }

      _buildGraph(
        subjectId: subjectId,
        subjectName: _subjectName!,
        topics: topicsWithSubtopics,
        subjectNotes: _subjectNotes,
        subjectSummary: subjectSummary,
        backgroundRefresh: backgroundRefresh,
      );
    } catch (e) {
      if (mounted && requestId == _graphRequestId) {
        setState(() {
          _isLoading = false;
          _syncing = false;
          _error = 'Failed to load knowledge graph: $e';
        });
      }
    }
  }

  void _buildGraph({
    required String subjectId,
    required String subjectName,
    required List<Map<String, dynamic>> topics,
    List<Map<String, dynamic>> subjectNotes = const [],
    String? subjectSummary,
    bool backgroundRefresh = false,
  }) {
    final nodes = <GraphNode>[];
    final edges = <GraphEdge>[];

    // Root node (Subject)
    final rootNode = GraphNode(
      id: subjectId,
      label: subjectName,
      type: GraphNodeType.subject,
      notes: subjectNotes,
      description: subjectSummary,
      childCount: topics.length,
    );
    nodes.add(rootNode);

    int subtopicCount = 0;

    // Level 1: Topic nodes
    for (final topic in topics) {
      final topicId = topic['id']?.toString() ?? '';
      final topicName = topic['name']?.toString() ?? 'Topic';
      final topicNotes =
          (topic['notes'] as List? ?? []).cast<Map<String, dynamic>>();

      final subtopics =
          (topic['subtopics'] as List? ?? []).cast<Map<String, dynamic>>();
      subtopicCount += subtopics.length;

      final topicNode = GraphNode(
        id: topicId,
        label: topicName,
        type: GraphNodeType.topic,
        parentId: subjectId,
        subjectId: subjectId,
        notes: topicNotes,
        description:
            (topic['summary'] ?? topic['studySummary'] ?? topic['description'])
                ?.toString(),
        childCount: subtopics.length,
      );
      nodes.add(topicNode);
      edges.add(GraphEdge(fromId: subjectId, toId: topicId));

      // Level 2: Subtopic nodes
      for (final sub in subtopics) {
        final subId = sub['id']?.toString() ?? '';
        final subName = sub['name']?.toString() ?? 'Subtopic';
        final subNotes =
            (sub['notes'] as List? ?? []).cast<Map<String, dynamic>>();

        final subNode = GraphNode(
          id: subId,
          label: subName,
          type: GraphNodeType.subtopic,
          parentId: topicId,
          topicId: topicId,
          subjectId: subjectId,
          notes: subNotes,
          description:
              (sub['summary'] ?? sub['studySummary'] ?? sub['description'])
                  ?.toString(),
        );
        nodes.add(subNode);
        edges.add(GraphEdge(fromId: topicId, toId: subId));
      }
    }

    // Step 7: Required debug logs
    debugPrint('Loaded Subject: $subjectName');
    debugPrint('Topics: ${topics.length}');
    debugPrint('Subtopics: $subtopicCount');
    debugPrint('Nodes Built: ${nodes.length}');
    debugPrint('Edges Built: ${edges.length}');

    // Run Buchheim-Walker Tidier Tree Layout algorithm
    final laidOut = GraphLayoutEngine.layout(nodes, edges);

    setState(() {
      _nodes = laidOut;
      _edges = edges;
      _emptyTopics = false;
      _isLoading = false;
      _syncing = false;
      final refreshedSelection = laidOut.where(
        (node) => node.id == _selectedNode?.id,
      );
      if (refreshedSelection.isNotEmpty) {
        _selectedNode = refreshedSelection.first;
        _topicName = switch (_selectedNode!.type) {
          GraphNodeType.subject => null,
          GraphNodeType.topic => _selectedNode!.label,
          GraphNodeType.subtopic => _findParentLabel(_selectedNode!),
          GraphNodeType.aiExpanded => _findTopicLabel(_selectedNode!),
        };
        _updateBreadcrumb(_selectedNode!);
      } else if (_selectedNode != null) {
        _selectedNode = null;
        _panelVisible = false;
      }
    });

    // Auto-fit camera to view the full knowledge tree comfortably
    if (!backgroundRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final size = MediaQuery.of(context).size;
          _canvasKey.currentState?.fitToScreen(size);
        }
      });
    }
  }

  // ── Graph Interactions ───────────────────────────────────────────────────────

  void _onNodeTap(GraphNode node) {
    HapticFeedback.selectionClick();
    debugPrint('MIND_MAP_NODE_TAPPED ${jsonEncode({
      'nodeId': node.id,
      'nodeName': node.label,
      'nodeType': node.type.name,
      'children': node.childCount,
      'notesFound': node.notes.length,
    })}');
    setState(() {
      // Deselect all
      _nodes = _nodes.map((n) => n.copyWith(isSelected: false)).toList();
      // Select tapped node
      final idx = _nodes.indexWhere((n) => n.id == node.id);
      if (idx >= 0) {
        _nodes[idx] = _nodes[idx].copyWith(isSelected: true);
        _selectedNode = _nodes[idx];
      } else {
        _selectedNode = node;
      }
      _updateBreadcrumb(node);
      _topicName = switch (node.type) {
        GraphNodeType.subject => null,
        GraphNodeType.topic => node.label,
        GraphNodeType.subtopic => _findParentLabel(node),
        GraphNodeType.aiExpanded => _findTopicLabel(node),
      };
      _panelVisible = true;
    });
    debugPrint('MIND_MAP_DETAIL_PANEL visible=$_panelVisible node=${_selectedNode?.id}');
  }

  void _onNodeDoubleTap(GraphNode node) {
    final size = MediaQuery.of(context).size;
    _canvasKey.currentState?.centerOn(node, size);
  }

  void _onToggleExpand(String nodeId) {
    HapticFeedback.lightImpact();
    setState(() {
      final idx = _nodes.indexWhere((n) => n.id == nodeId);
      if (idx < 0) return;
      final node = _nodes[idx];
      final newExpanded = !node.isExpanded;
      _nodes[idx] = node.copyWith(isExpanded: newExpanded);

      // Hide or show direct children and grandchildren
      _setChildrenVisible(nodeId, newExpanded);
    });
    // Re-run Buchheim-Walker layout to smoothly recalculate horizontal spacing
    _relayout();
  }

  void _setChildrenVisible(String parentId, bool visible) {
    for (var i = 0; i < _nodes.length; i++) {
      if (_nodes[i].parentId == parentId) {
        _nodes[i] = _nodes[i].copyWith(isVisible: visible);
        if (!visible) {
          // Recursively hide lower descendants
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

  void _onLibraryVersionChanged(
      AsyncValue<String>? previous, AsyncValue<String> next) {
    final version = next.valueOrNull;
    if (version == null || version.isEmpty) return;
    if (_lastLibraryVersion == null) {
      _lastLibraryVersion = version;
      return;
    }
    if (version == _lastLibraryVersion) return;
    _lastLibraryVersion = version;
    _libraryChangeDebounce?.cancel();
    _libraryChangeDebounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) _loadGraph(backgroundRefresh: _nodes.isNotEmpty);
    });
  }

  // ── AI Expansion (Generates Temporary Branch Nodes) ──────────────────────────

  Future<void> _expandNodeWithAI(GraphNode node) async {
    if (_aiExpanding) return;
    setState(() => _aiExpanding = true);

    AppNotification.showLoading(
      context: context,
      title: 'Expanding with AI',
      message: 'Generating related concepts for "${node.label}"…',
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
      _nodes.removeWhere((n) => previousAiIds.contains(n.id));
      _edges.removeWhere((e) => previousAiIds.contains(e.toId));

      // Add new AI branch nodes
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
          .map((n) => GraphEdge(fromId: node.id, toId: n.id, isDashed: true))
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
        message: '${newNodes.length} AI concepts generated!',
      );

      // Smooth camera transition to the expanded node
      final size = MediaQuery.of(context).size;
      _canvasKey.currentState?.centerOn(node, size);
    } catch (e) {
      if (mounted) {
        AppNotification.dismissAll();
        AppNotification.showError(
          context: context,
          message: 'AI expansion failed. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _aiExpanding = false);
    }
  }

  // ── Search & Camera Navigation ───────────────────────────────────────────────

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
    if (value.trim().isEmpty) return;
    final match = _nodes.firstWhere(
      (n) => n.label.toLowerCase().contains(value.trim().toLowerCase()),
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
      if (node.type == GraphNodeType.subtopic) ...[
        _findParentLabel(node),
        node.label,
      ],
      if (node.type == GraphNodeType.aiExpanded) ...[
        _findTopicLabel(node) ?? '',
        node.label,
      ],
    ].where((s) => s.isNotEmpty).toList();
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

  String? _findTopicLabel(GraphNode node) {
    final topicId = node.topicId;
    if (topicId == null) return null;
    final topic = _nodes.where((item) => item.id == topicId);
    if (topic.isEmpty) return _findParentLabel(node);
    return topic.first.type == GraphNodeType.subject ? null : topic.first.label;
  }

  void _navigateTool(String tool, String nodeId) {
    final route = switch (tool) {
      'flashcards' => AppRoutes.flashcards,
      'quiz' => AppRoutes.quiz,
      'pyq' => AppRoutes.questionPaperAnalyzer,
      'summary' => AppRoutes.summary,
      _ => AppRoutes.flashcards,
    };
    context.go(route.replaceFirst(':topicId', nodeId));
  }

  // ── Build Widget Tree ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ref.watch(activeKnowledgeSubjectNameSyncProvider);
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final activeSubjectId = ref.watch(activeKnowledgeSubjectIdProvider) ??
        ref.watch(activeKnowledgeWorkspaceIdProvider) ??
        '';
    ref.listen<AsyncValue<String>>(
      subjectTopicsVersionProvider(activeSubjectId),
      _onLibraryVersionChanged,
    );

    return Scaffold(
      backgroundColor: _canvasBackground,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _error != null
                    ? _buildErrorState()
                    : _emptyTopics || _nodes.isEmpty
                        ? _buildEmptyTopicsState()
                        : _buildGraphArea(isDesktop),
          ),
        ],
      ),
    );
  }

  // ── Top Bar with Breadcrumb, Search, and Controls ────────────────────────────

  Widget _buildTopBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: _topBarBackground,
        border: Border(
          bottom: BorderSide(color: _subtleBorder),
        ),
      ),
      child: Row(
        children: [
          if (_syncing)
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF60A5FA),
                  ),
                ),
                if (MediaQuery.of(context).size.width > 700) ...[
                  const SizedBox(width: 6),
                  const Text(
                    'Updating study tools...',
                    style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
                const SizedBox(width: 8),
              ],
            ),
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                size: 20, color: Colors.white),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.library);
              }
            },
            tooltip: 'Back to Library',
          ),
          const SizedBox(width: 6),

          // Title & Breadcrumbs
          Expanded(
            child: _breadcrumb.isEmpty
                ? Text(
                    _subjectName ?? 'Knowledge Tree',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: Colors.white,
                    ),
                  )
                : _buildBreadcrumbRow(),
          ),

          // Search Bar
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: _searchFocused ? 240 : 160,
            height: 36,
            child: TextField(
              controller: _searchController,
              onTap: () => setState(() => _searchFocused = true),
              onEditingComplete: () {
                _onSearchSubmit(_searchController.text);
                setState(() => _searchFocused = false);
              },
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: 'Search concepts…',
                hintStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
                prefixIcon: const Icon(Icons.search_rounded,
                    size: 16, color: Color(0xFF94A3B8)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: _subtleBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: _subtleBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide:
                      const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                ),
                filled: true,
                fillColor: const Color(0xFF102743).withOpacity(0.85),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Control Buttons
          _ControlButton(
            icon: Icons.fit_screen_rounded,
            tooltip: 'Fit to screen',
            onTap: () {
              final size = MediaQuery.of(context).size;
              _canvasKey.currentState?.fitToScreen(size);
            },
          ),
          _ControlButton(
            icon: Icons.add_rounded,
            tooltip: 'Zoom In',
            onTap: () {
              final size = MediaQuery.of(context).size;
              _canvasKey.currentState?.zoomIn(size);
            },
          ),
          _ControlButton(
            icon: Icons.remove_rounded,
            tooltip: 'Zoom Out',
            onTap: () {
              final size = MediaQuery.of(context).size;
              _canvasKey.currentState?.zoomOut(size);
            },
          ),
          _ControlButton(
            icon: Icons.refresh_rounded,
            tooltip: 'Reload tree',
            onTap: _loadGraph,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildBreadcrumbRow() {
    return Row(
      children: _breadcrumb.asMap().entries.expand((entry) {
        final isLast = entry.key == _breadcrumb.length - 1;
        return [
          Flexible(
            child: Text(
              entry.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: isLast ? FontWeight.w700 : FontWeight.w400,
                color: isLast ? Colors.white : const Color(0xFF94A3B8),
              ),
            ),
          ),
          if (!isLast)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 14,
                color: Color(0xFF64748B),
              ),
            ),
        ];
      }).toList(),
    );
  }

  // ── Main Graph Area ──────────────────────────────────────────────────────────

  Widget _buildGraphArea(bool isDesktop) {
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
            duration: const Duration(milliseconds: 280),
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
                  ).animate().slideX(
                      begin: 0.08,
                      end: 0,
                      duration: 280.ms,
                      curve: Curves.easeOutCubic,
                    )
                : const SizedBox.shrink(),
          ),
        ],
      );
    }

    // Mobile / Tablet Bottom Sheet Overlay
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
                duration: 280.ms,
                curve: Curves.easeOutCubic,
              ),
      ],
    );
  }

  // ── States: Loading, Error, Empty ────────────────────────────────────────────

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Color(0xFF3B82F6),
            ),
          ),
          SizedBox(height: 18),
          Text(
            'Building Knowledge Tree…',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF60A5FA),
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
          const Icon(Icons.hub_outlined, size: 52, color: AppColors.error),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadGraph,
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

  Widget _buildEmptyTopicsState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF102743),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF1E3A5F),
              ),
            ),
            child: const Icon(
              Icons.account_tree_outlined,
              size: 48,
              color: Color(0xFF38BDF8),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Topics Found',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Add topics to begin building your knowledge graph.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.go(AppRoutes.library),
            icon: const Icon(Icons.menu_book_rounded, size: 18),
            label: const Text('Open Library'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
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
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.tooltip,
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
            color: const Color(0xFF102743).withOpacity(0.85),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF1E3A5F)),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFFCBD5E1)),
        ),
      ),
    );
  }
}
