import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ai/services/knowledge_engine.dart';
import '../../../../core/services/document_processing_service.dart';

enum SummaryMode { short, detailed, exam, formula }

class SummaryScreen extends ConsumerStatefulWidget {
  final String? topicId;
  final String? initialMode;
  const SummaryScreen({super.key, this.topicId, this.initialMode});
  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  late SummaryMode _mode;
  late Future<Map<String, dynamic>> _result;
  @override
  void initState() {
    super.initState();
    _mode = SummaryMode.values.firstWhere((m) => m.name == widget.initialMode,
        orElse: () => SummaryMode.short);
    _generate();
  }

  void _generate() =>
      _result = ref.read(knowledgeEngineProvider).generateSummary(
            topicId: widget.topicId,
            prompt: switch (_mode) {
              SummaryMode.short =>
                'Create concise study notes with main ideas and key takeaways.',
              SummaryMode.detailed =>
                'Create detailed study notes with concepts, explanations, examples, and relationships.',
              SummaryMode.exam =>
                'Create exam revision notes emphasizing important facts and likely assessment points.',
              SummaryMode.formula =>
                'Generate a formula sheet. Include formulae, variable meanings, conditions, and examples.',
            },
          );

  @override
  Widget build(BuildContext context) {
    final doc = ref.watch(activeDocumentProvider);
    return Scaffold(
      appBar: AppBar(
          title: Text(switch (_mode) {
            SummaryMode.formula => 'Formula Sheet',
            SummaryMode.exam => 'Exam Notes',
            _ => 'Study Summary'
          }),
          leading: BackButton(onPressed: () => Navigator.maybePop(context)),
          actions: [
            IconButton(
                onPressed: () => setState(_generate),
                icon: const Icon(Icons.refresh))
          ]),
      body: Column(children: [
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              for (final mode in SummaryMode.values)
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                        label: Text(mode.name),
                        selected: mode == _mode,
                        onSelected: (_) => setState(() {
                              _mode = mode;
                              _generate();
                            }))),
            ])),
        Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
                future: _result,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done)
                    return const Center(child: CircularProgressIndicator());
                  if (snapshot.hasError)
                    return Center(
                        child: Text(
                            'Could not generate notes: ${snapshot.error}'));
                  final result = snapshot.data!;
                  return ListView(padding: const EdgeInsets.all(20), children: [
                    if (doc != null)
                      Text(doc.fileName,
                          style: Theme.of(context).textTheme.titleSmall),
                    for (final entry
                        in result.entries.where((e) => e.key != 'sources'))
                      Card(
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        entry.key
                                            .replaceAll('_', ' ')
                                            .toUpperCase(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary)),
                                    const SizedBox(height: 8),
                                    if (entry.value is List)
                                      for (final item in entry.value as List)
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 6),
                                            child: Text(
                                                '• ${item is Map ? item.entries.map((e) => '${e.key}: ${e.value}').join(' · ') : item}'))
                                    else
                                      Text(entry.value.toString()),
                                  ]))),
                    if ((result['sources'] as List? ?? []).isNotEmpty)
                      const Text('Generated using your workspace sources.'),
                  ]);
                })),
      ]),
    );
  }
}
