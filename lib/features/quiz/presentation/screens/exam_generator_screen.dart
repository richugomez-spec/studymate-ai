import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ai/services/knowledge_engine.dart';

class ExamGeneratorScreen extends ConsumerStatefulWidget {
  final String? topicId;
  const ExamGeneratorScreen({super.key, this.topicId});
  @override
  ConsumerState<ExamGeneratorScreen> createState() =>
      _ExamGeneratorScreenState();
}

class _ExamGeneratorScreenState extends ConsumerState<ExamGeneratorScreen> {
  int _marks = 50;
  int _minutes = 60;
  String _difficulty = 'Moderate';
  bool _answerKey = true;
  Future<Map<String, dynamic>>? _result;

  Future<void> _generate() async {
    setState(() => _result = ref.read(knowledgeEngineProvider).generateExam(
          topicId: widget.topicId,
          prompt:
              'Generate an exam for $_marks marks, $_minutes minutes, difficulty $_difficulty, answer key $_answerKey. Use a balanced question mix grounded in workspace topics. Return title and questions (type, prompt, marks, answer, explanation).',
        ));
    await _result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Exam Generator'),
          leading: BackButton(onPressed: () => Navigator.maybePop(context))),
      body: _result == null
          ? ListView(padding: const EdgeInsets.all(20), children: [
              _choice('Total marks', _marks, const [25, 50, 100],
                  (value) => setState(() => _marks = value)),
              _choice('Duration (minutes)', _minutes, const [30, 60, 120],
                  (value) => setState(() => _minutes = value)),
              DropdownButtonFormField<String>(
                  value: _difficulty,
                  items: const ['Easy', 'Moderate', 'Challenging']
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _difficulty = v ?? 'Moderate')),
              SwitchListTile(
                  title: const Text('Include answer key'),
                  value: _answerKey,
                  onChanged: (v) => setState(() => _answerKey = v)),
              const SizedBox(height: 12),
              FilledButton.icon(
                  onPressed: _generate,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate exam')),
            ])
          : FutureBuilder<Map<String, dynamic>>(
              future: _result,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done)
                  return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError)
                  return const Center(child: Text('Please try again.'));
                final data = snapshot.data!;
                final questions = (data['questions'] as List? ?? const [])
                    .whereType<Map>()
                    .toList();
                return ListView(padding: const EdgeInsets.all(20), children: [
                  Text((data['title'] ?? 'Practice Exam').toString(),
                      style: Theme.of(context).textTheme.headlineSmall),
                  for (var i = 0; i < questions.length; i++)
                    Card(
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Question ${i + 1} · ${questions[i]['marks'] ?? ''} marks',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Text((questions[i]['prompt'] ??
                                          questions[i]['question'] ??
                                          '')
                                      .toString()),
                                  if (_answerKey &&
                                      questions[i]['answer'] != null) ...[
                                    const Divider(),
                                    Text('Answer: ${questions[i]['answer']}'),
                                    if (questions[i]['explanation'] != null)
                                      Text(questions[i]['explanation']
                                          .toString())
                                  ],
                                ]))),
                  TextButton(
                      onPressed: () => setState(() => _result = null),
                      child: const Text('Adjust settings')),
                ]);
              }),
    );
  }

  Widget _choice(String label, int selected, List<int> values,
          ValueChanged<int> onChanged) =>
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label),
            Wrap(spacing: 8, children: [
              for (final value in values)
                ChoiceChip(
                    label: Text('$value'),
                    selected: selected == value,
                    onSelected: (_) => onChanged(value))
            ]),
          ]));
}
