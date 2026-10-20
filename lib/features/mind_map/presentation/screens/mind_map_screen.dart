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

  void _generate() => _result = ref
      .read(knowledgeEngineProvider)
      .generateMindMap(topicId: widget.topicId);

  @override
  Widget build(BuildContext context) {
    final doc = ref.watch(activeDocumentProvider);
    return Scaffold(
      appBar: AppBar(
          title: Text('Mind Map${doc == null ? '' : ': ${doc.fileName}'}'),
          leading: BackButton(onPressed: () => Navigator.maybePop(context)),
          actions: [
            IconButton(
                onPressed: () => setState(_generate),
                icon: const Icon(Icons.refresh))
          ]),
      body: FutureBuilder<Map<String, dynamic>>(
          future: _result,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done)
              return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError)
              return const Center(child: Text('Please try again.'));
            final map = snapshot.data!;
            final root =
                (map['root'] ?? map['title'] ?? 'Main topic').toString();
            final nodes = (map['nodes'] as List? ?? const [])
                .whereType<Map>()
                .map(Map<String, dynamic>.from)
                .toList();
            final edges = (map['edges'] as List? ?? const [])
                .whereType<Map>()
                .map(Map<String, dynamic>.from)
                .toList();
            return InteractiveViewer(
                minScale: .6,
                maxScale: 2.2,
                child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(children: [
                      _node(root, true),
                      const Icon(Icons.arrow_downward, color: Colors.teal),
                      Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            for (final node in nodes)
                              SizedBox(
                                  width: 230,
                                  child: _node(
                                      (node['name'] ??
                                              node['title'] ??
                                              node['label'] ??
                                              '')
                                          .toString(),
                                      false,
                                      detail: (node['description'] ??
                                              node['example'] ??
                                              '')
                                          .toString(),
                                      relations: edges
                                          .where((e) =>
                                              e['from'] == node['id'] ||
                                              e['to'] == node['id'])
                                          .map((e) => (e['label'] ??
                                                  e['type'] ??
                                                  'connects')
                                              .toString())
                                          .toList())),
                          ]),
                    ])));
          }),
    );
  }

  Widget _node(String title, bool root,
          {String detail = '', List<String> relations = const []}) =>
      Card(
          color: root
              ? Colors.deepPurple.shade700
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: root ? 18 : 15)),
                if (detail.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(detail, textAlign: TextAlign.center)
                ],
                if (relations.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(relations.join(' · '),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11))
                ],
              ])));
}
