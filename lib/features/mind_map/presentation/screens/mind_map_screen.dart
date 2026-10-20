import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ai/services/knowledge_engine.dart';
import '../../../../core/services/document_processing_service.dart';

class MindMapScreen extends ConsumerStatefulWidget {
  final String? topicId;
  const MindMapScreen({super.key, this.topicId});

  @override
  ConsumerState<MindMapScreen> createState() => _MindMapScreenState();
}

class _MindMapScreenState extends ConsumerState<MindMapScreen> {
  late Future<Map<String, dynamic>> _result;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate({bool forceRefresh = false}) =>
      _result = ref.read(knowledgeEngineProvider).generateMindMap(
          topicId: widget.topicId,
          subjectId: ref.read(activeKnowledgeSubjectIdProvider) ??
              ref.read(activeKnowledgeWorkspaceIdProvider),
          forceRefresh: forceRefresh);

  @override
  Widget build(BuildContext context) {
    final subjectName = ref.watch(activeKnowledgeSubjectNameProvider);
    return Scaffold(
      appBar: AppBar(
          title:
              Text('${subjectName == null ? '' : '$subjectName · '}Mind Map'),
          leading: BackButton(onPressed: () => Navigator.maybePop(context)),
          actions: [
            IconButton(
                onPressed: () => setState(() => _generate(forceRefresh: true)),
                icon: const Icon(Icons.refresh))
          ]),
      body: FutureBuilder<Map<String, dynamic>>(
          future: _result,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: Text('Thinking...'));
            }
            if (snapshot.hasError || snapshot.data == null) {
              return const Center(
                  child: Text(
                      'We could not create this mind map. Please try again.'));
            }
            final data = snapshot.data!;
            final nodes = (data['nodes'] as List? ?? const [])
                .whereType<Map>()
                .map(Map<String, dynamic>.from)
                .toList();
            final edges = (data['edges'] as List? ?? const [])
                .whereType<Map>()
                .map(Map<String, dynamic>.from)
                .toList();
            final byId = <String, Map<String, dynamic>>{};
            for (var i = 0; i < nodes.length; i++) {
              byId[(nodes[i]['id'] ?? '$i').toString()] = nodes[i];
            }
            final rawRoot = data['root'] ?? data['title'] ?? 'Study Topic';
            final root = rawRoot is Map
                ? Map<String, dynamic>.from(rawRoot)
                : <String, dynamic>{'name': rawRoot.toString()};
            final rootId = (root['id'] ?? '').toString();
            final rootReferences = <String>{
              if (rootId.isNotEmpty) rootId,
              'root',
              (root['name'] ?? root['title'] ?? '').toString(),
            }.map((value) => value.toLowerCase()).toSet();
            final rootChildren = <String>{};
            final children = <String, List<String>>{};
            final parents = <String>{};
            for (final edge in edges) {
              final from = (edge['from'] ?? edge['source'] ?? '').toString();
              final to = (edge['to'] ?? edge['target'] ?? '').toString();
              if (byId.containsKey(from) && byId.containsKey(to)) {
                children.putIfAbsent(from, () => []).add(to);
                parents.add(to);
              } else if (rootReferences.contains(from.toLowerCase()) &&
                  byId.containsKey(to)) {
                rootChildren.add(to);
                parents.add(to);
              }
            }
            for (final entry in byId.entries) {
              final parent = entry.value['parentId']?.toString();
              if (parent != null && byId.containsKey(parent)) {
                children.putIfAbsent(parent, () => []).add(entry.key);
                parents.add(entry.key);
              } else if (parent != null &&
                  rootReferences.contains(parent.toLowerCase())) {
                rootChildren.add(entry.key);
                parents.add(entry.key);
              }
            }
            final topLevel =
                byId.keys.where((id) => !parents.contains(id)).toList();
            if (topLevel.isEmpty) topLevel.addAll(byId.keys);
            topLevel.removeWhere(rootChildren.contains);
            final nestedRootChildren = (root['children'] as List? ?? const [])
                .whereType<Map>()
                .map(Map<String, dynamic>.from)
                .toList();
            return InteractiveViewer(
              minScale: .6,
              maxScale: 2.2,
              constrained: false,
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _MindRoot(title: _nodeTitle(root)),
                        const SizedBox(height: 12),
                        for (final id in rootChildren)
                          _MindMapNode(
                            data: byId[id]!,
                            children: children,
                            nodes: byId,
                            path: {id},
                            depth: 0,
                          ),
                        for (final child in nestedRootChildren)
                          _MindMapNode(
                            data: child,
                            children: children,
                            nodes: byId,
                            path: const {},
                            depth: 0,
                          ),
                        for (final id in topLevel)
                          _MindMapNode(
                            data: byId[id]!,
                            children: children,
                            nodes: byId,
                            path: {id},
                            depth: 0,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  String _nodeTitle(Map<String, dynamic> node) =>
      (node['name'] ?? node['title'] ?? node['label'] ?? 'Study Topic')
          .toString();
}

class _MindRoot extends StatelessWidget {
  final String title;
  const _MindRoot({required this.title});

  @override
  Widget build(BuildContext context) => Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center),
        ),
      );
}

class _MindMapNode extends StatelessWidget {
  final Map<String, dynamic> data;
  final Map<String, List<String>> children;
  final Map<String, Map<String, dynamic>> nodes;
  final Set<String> path;
  final int depth;

  const _MindMapNode({
    required this.data,
    required this.children,
    required this.nodes,
    required this.path,
    required this.depth,
  });

  @override
  Widget build(BuildContext context) {
    final id = (data['id'] ?? '').toString();
    final title = (data['name'] ?? data['title'] ?? data['label'] ?? 'Concept')
        .toString();
    final detail = (data['description'] ?? data['detail'] ?? '').toString();
    final childIds = (children[id] ?? const <String>[])
        .where((child) => !path.contains(child))
        .toList();
    final nested = (data['children'] as List? ?? const [])
        .whereType<Map>()
        .map(Map<String, dynamic>.from)
        .toList();
    final hasChildren = childIds.isNotEmpty || nested.isNotEmpty;
    return Padding(
      padding: EdgeInsets.only(left: depth * 18.0, bottom: 6),
      child: Card(
        child: hasChildren
            ? ExpansionTile(
                initiallyExpanded: depth == 0,
                title: Text(title),
                subtitle: detail.isEmpty ? null : Text(detail),
                children: [
                  for (final childId in childIds)
                    _MindMapNode(
                      data: nodes[childId]!,
                      children: children,
                      nodes: nodes,
                      path: {...path, childId},
                      depth: depth + 1,
                    ),
                  for (var i = 0; i < nested.length; i++)
                    _MindMapNode(
                      data: nested[i],
                      children: children,
                      nodes: nodes,
                      path: path,
                      depth: depth + 1,
                    ),
                ],
              )
            : ListTile(
                title: Text(title),
                subtitle: detail.isEmpty ? null : Text(detail),
              ),
      ),
    );
  }
}
