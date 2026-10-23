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
  Future<Map<String, dynamic>>? _analysis;
  bool _isBusy = false;
  String? _error;
  String? _paperName;
  final _questionController = TextEditingController();
  final _marksController = TextEditingController(text: '5');

  @override
  void dispose() {
    _questionController.dispose();
    _marksController.dispose();
    super.dispose();
  }

  Future<void> _answerManualQuestion() async {
    final question = _questionController.text.trim();
    final marks = int.tryParse(_marksController.text.trim());
    if (question.isEmpty || marks == null || marks < 1) {
      setState(() => _error = 'Enter a question and valid marks.');
      return;
    }
    setState(() {
      _isBusy = true;
      _error = null;
      _paperName = 'Manual question';
    });
    try {
      final result = ref.read(knowledgeEngineProvider).generatePYQ(
            topicId: widget.topicId,
            subjectId: ref.read(activeKnowledgeSubjectIdProvider) ??
                ref.read(activeKnowledgeWorkspaceIdProvider),
            sourceIds: ref.read(selectedKnowledgeSourceIdsProvider),
            prompt:
                'Answer this manually entered exam question using the currently opened subject topic/subtopic hierarchy and manual notes. Question: $question. Marks: $marks. Return JSON with question, marks, model_answer, marking_scheme, and common_mistakes. If the subject has no manual notes, include a polite notice suggesting the user add notes.',
          );
      setState(() => _analysis = result);
      await result;
    } catch (_) {
      if (mounted)
        setState(() =>
            _error = 'We could not answer this question. Please try again.');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _analyzeSelectedPaper() async {
    final id = widget.topicId;
    if (id == null || id.isEmpty || id == 'current') return;
    setState(() {
      _error = null;
      _isBusy = true;
      _paperName = 'Selected paper';
    });
    await _analyzePaper(id, _paperName ?? 'Selected paper');
    if (mounted) setState(() => _isBusy = false);
  }

  Future<void> _analyzePaper(String id, String title) async {
    try {
      final result = ref.read(knowledgeEngineProvider).generatePYQ(
            topicId: id,
            subjectId: ref.read(activeKnowledgeSubjectIdProvider) ??
                ref.read(activeKnowledgeWorkspaceIdProvider),
            sourceIds: [id],
            prompt:
                'Analyze the currently opened subject topic/subtopic hierarchy and manual notes for examination themes. Return JSON with frequently_repeated_questions (list, only evidence present in the notes), topic_frequency (list of topic and count), marks_distribution (list), important_units (list), and predicted_questions (list grounded in the hierarchy and notes). Do not invent repeated questions, frequencies, or marks. If no manual notes exist, include a polite notice suggesting the user add them.',
          );
      setState(() {
        _paperName = title;
        _analysis = result;
      });
      await result;
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            'We could not analyze this paper right now. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectName = ref.watch(activeKnowledgeSubjectNameProvider);
    return Scaffold(
      appBar: AppBar(
        title:
            Text('${subjectName == null ? '' : '$subjectName · '}PYQ Analyzer'),
        leading: BackButton(onPressed: () => Navigator.maybePop(context)),
      ),
      body: _isBusy
          ? const Center(child: Text('Processing paper...'))
          : _analysis == null
              ? _startView(context)
              : FutureBuilder<Map<String, dynamic>>(
                  future: _analysis,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: Text('Analyzing paper...'));
                    }
                    if (snapshot.hasError || snapshot.data == null) {
                      return _errorView();
                    }
                    return _analysisView(context, snapshot.data!);
                  }),
    );
  }

  Widget _startView(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.edit_note, size: 48),
              const SizedBox(height: 12),
              const Text('Ask a previous-year question',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                  controller: _questionController,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Question')),
              const SizedBox(height: 8),
              TextField(
                  controller: _marksController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Marks')),
              if (_error != null)
                Padding(padding: const EdgeInsets.all(8), child: Text(_error!)),
              FilledButton.icon(
                  onPressed: _answerManualQuestion,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate answer')),
              if (widget.topicId != null && widget.topicId != 'current') ...[
                const SizedBox(height: 8),
                TextButton(
                    onPressed: _analyzeSelectedPaper,
                    child: const Text('Analyze selected saved source')),
              ],
            ]),
          ),
        ),
      );

  Widget _errorView() => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_error ?? 'We could not analyze this paper. Please try again.'),
          TextButton(
              onPressed: () => setState(() => _analysis = null),
              child: const Text('Try another paper')),
        ]),
      );

  Widget _analysisView(BuildContext context, Map<String, dynamic> data) {
    if (data.containsKey('model_answer')) {
      return ListView(padding: const EdgeInsets.all(20), children: [
        Text((data['question'] ?? _questionController.text).toString(),
            style: Theme.of(context).textTheme.titleLarge),
        Text('${data['marks'] ?? _marksController.text} marks'),
        const SizedBox(height: 12),
        _resultCard('Model Answer', data['model_answer']),
        _resultCard('Marking Scheme', data['marking_scheme']),
        _resultCard('Common Mistakes', data['common_mistakes']),
      ]);
    }
    const sections = <(String, List<String>)>[
      (
        'Frequently Repeated Questions',
        ['frequently_repeated_questions', 'repeated_questions']
      ),
      ('Topic Frequency', ['topic_frequency']),
      ('Marks Distribution', ['marks_distribution']),
      ('Important Units', ['important_units']),
      ('Predicted Questions', ['predicted_questions']),
    ];
    final widgets = <Widget>[];
    for (final (title, keys) in sections) {
      final key = keys.firstWhere(data.containsKey, orElse: () => '');
      if (key.isEmpty) continue;
      final value = data[key];
      final items = value is List ? value : [value];
      if (items.isEmpty) continue;
      widgets.add(Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final item in items)
              Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('• ${_display(item)}')),
          ]),
        ),
      ));
    }
    if (widgets.isEmpty) return _errorView();
    return ListView(padding: const EdgeInsets.all(20), children: [
      if (_paperName != null) Text(_paperName!),
      ...widgets,
    ]);
  }

  Widget _resultCard(String title, dynamic content) {
    final items = content is List ? content : [content];
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                for (final item in items.where((item) => item != null))
                  Text('• ${_display(item)}'),
              ],
            )));
  }

  String _display(dynamic item) {
    if (item is Map) {
      return item.entries
          .map((entry) => '${entry.key}: ${_display(entry.value)}')
          .join(' · ');
    }
    if (item is List) return item.map(_display).join(', ');
    return item?.toString() ?? '';
  }
}
