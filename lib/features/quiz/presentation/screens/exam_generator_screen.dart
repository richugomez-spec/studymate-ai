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
  bool _isGenerating = false;
  String? _error;
  Future<Map<String, dynamic>>? _result;
  final Set<int> _revealedAnswers = {};

  Future<void> _generate() async {
    setState(() {
      _error = null;
      _isGenerating = true;
      _revealedAnswers.clear();
      _result = ref.read(knowledgeEngineProvider).generateExam(
            topicId: widget.topicId,
            prompt:
                'Generate a $_marks mark exam for $_minutes minutes at $_difficulty difficulty. Create precise, varied questions grounded in workspace knowledge. Return JSON with title and questions. Each question must have prompt, marks, modelAnswer, markingScheme (list), and commonMistakes (list). Do not include the answer in the question prompt.',
          );
    });
    try {
      await _result;
    } catch (_) {
      if (mounted)
        setState(() => _error =
            'We could not create an exam right now. Please try again.');
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
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
              if (_error != null) Text(_error!),
              const SizedBox(height: 12),
              FilledButton.icon(
                  onPressed: _isGenerating ? null : _generate,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(_isGenerating ? 'Thinking...' : 'Generate exam')),
            ])
          : FutureBuilder<Map<String, dynamic>>(
              future: _result,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: Text('Thinking...'));
                }
                if (snapshot.hasError || snapshot.data == null) {
                  return _friendlyError();
                }
                final data = snapshot.data!;
                final questions = (data['questions'] as List? ?? const [])
                    .whereType<Map>()
                    .map(Map<String, dynamic>.from)
                    .where((q) => (q['prompt'] ?? q['question'] ?? '')
                        .toString()
                        .trim()
                        .isNotEmpty)
                    .toList();
                if (questions.isEmpty) return _friendlyError();
                return ListView(padding: const EdgeInsets.all(20), children: [
                  Text((data['title'] ?? 'Practice Exam').toString(),
                      style: Theme.of(context).textTheme.headlineSmall),
                  for (var i = 0; i < questions.length; i++)
                    _questionCard(questions[i], i),
                  TextButton(
                      onPressed: () => setState(() => _result = null),
                      child: const Text('Adjust settings')),
                ]);
              }),
    );
  }

  Widget _friendlyError() => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('We could not prepare the exam. Please try again.'),
          TextButton(
              onPressed: () => setState(() => _result = null),
              child: const Text('Back to settings')),
        ]),
      );

  Widget _questionCard(Map<String, dynamic> question, int index) {
    final revealed = _revealedAnswers.contains(index);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Question ${index + 1} · ${question['marks'] ?? ''} marks',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text((question['prompt'] ?? question['question'] ?? '').toString()),
          if (!revealed) ...[
            const SizedBox(height: 12),
            OutlinedButton(
                onPressed: () => setState(() => _revealedAnswers.add(index)),
                child: const Text('Reveal Answer')),
          ],
          if (revealed) ...[
            const Divider(),
            _answerSection(
                'Model Answer', question['modelAnswer'] ?? question['answer']),
            _answerSection('Marking Scheme', question['markingScheme']),
            _answerSection('Common Mistakes', question['commonMistakes']),
          ],
        ]),
      ),
    );
  }

  Widget _answerSection(String title, dynamic value) {
    if (value == null) return const SizedBox.shrink();
    final values = value is List ? value : [value];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        for (final item in values)
          Text(
              '• ${item is Map ? (item['criterion'] ?? item['point'] ?? item['text'] ?? '').toString() : item.toString()}'),
      ]),
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
