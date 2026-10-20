import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ai/services/knowledge_engine.dart';
import '../../../../core/services/document_processing_service.dart';

class QuestionPaperAnalyzerScreen extends ConsumerStatefulWidget {
  final String? topicId;
  const QuestionPaperAnalyzerScreen({super.key, this.topicId});
  @override
  ConsumerState<QuestionPaperAnalyzerScreen> createState() =>
      _QuestionPaperAnalyzerScreenState();
}

class _QuestionPaperAnalyzerScreenState
    extends ConsumerState<QuestionPaperAnalyzerScreen> {
  late Future<Map<String, dynamic>> _analysis;
  @override
  void initState() {
    super.initState();
    _analyze();
  }

  void _analyze() => _analysis =
      ref.read(knowledgeEngineProvider).generatePYQ(topicId: widget.topicId);

  @override
  Widget build(BuildContext context) {
    final doc = ref.watch(activeDocumentProvider);
    return Scaffold(
      appBar: AppBar(
          title: Text('PYQ Analysis${doc == null ? '' : ': ${doc.fileName}'}'),
          leading: BackButton(onPressed: () => Navigator.maybePop(context)),
          actions: [
            IconButton(
                onPressed: () => setState(_analyze),
                icon: const Icon(Icons.refresh))
          ]),
      body: FutureBuilder<Map<String, dynamic>>(
          future: _analysis,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done)
              return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError)
              return const Center(child: Text('Please try again.'));
            final data = snapshot.data!;
            return ListView(padding: const EdgeInsets.all(20), children: [
              for (final entry in data.entries.where((e) => e.key != 'sources'))
                _section(context, entry.key, entry.value),
            ]);
          }),
    );
  }

  Widget _section(BuildContext context, String title, dynamic value) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (value is List)
              for (final item in value)
                Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                        '• ${item is Map ? item.entries.map((e) => '${e.key}: ${e.value}').join(' · ') : item}'))
            else
              Text(value.toString()),
          ])));
}
