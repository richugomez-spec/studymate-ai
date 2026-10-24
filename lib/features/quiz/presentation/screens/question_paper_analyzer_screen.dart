import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ai/services/knowledge_engine.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../services/firestore_service.dart';

class QuestionPaperAnalyzerScreen extends ConsumerStatefulWidget {
  final String? topicId;
  const QuestionPaperAnalyzerScreen({super.key, this.topicId});

  @override
  ConsumerState<QuestionPaperAnalyzerScreen> createState() =>
      _QuestionPaperAnalyzerScreenState();
}

class _QuestionPaperAnalyzerScreenState
    extends ConsumerState<QuestionPaperAnalyzerScreen> {
  final List<_PreviousQuestion> _questions = [];
  Future<Map<String, dynamic>>? _analysis;
  bool _isBusy = false;
  String? _error;

  // Reactive sync
  Timer? _libraryChangeDebounce;
  String? _lastLibraryVersion;

  @override
  void dispose() {
    _libraryChangeDebounce?.cancel();
    super.dispose();
  }

  Future<void> _editQuestion({_PreviousQuestion? existing}) async {
    final questionController =
        TextEditingController(text: existing?.question ?? '');
    final marksController =
        TextEditingController(text: '${existing?.marks ?? 5}');
    final yearController = TextEditingController(text: existing?.year ?? '');
    final topicController = TextEditingController(text: existing?.topic ?? '');
    final saved = await showDialog<_PreviousQuestion>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
            existing == null ? 'Add previous-year question' : 'Edit question'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: questionController,
                autofocus: true,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  hintText: 'Paste or type the exam question',
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: marksController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Marks'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: yearController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Year (optional)'),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              TextField(
                controller: topicController,
                decoration: const InputDecoration(
                    labelText: 'Known topic (optional)',
                    prefixIcon: Icon(Icons.topic_outlined)),
              ),
            ]),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () {
              final marks = int.tryParse(marksController.text.trim());
              final text = questionController.text.trim();
              if (text.isEmpty || marks == null || marks < 1) return;
              Navigator.pop(
                dialogContext,
                _PreviousQuestion(
                  question: text,
                  marks: marks,
                  year: yearController.text.trim(),
                  topic: topicController.text.trim(),
                ),
              );
            },
            icon: const Icon(Icons.check_rounded),
            label: const Text('Save question'),
          ),
        ],
      ),
    );
    questionController.dispose();
    marksController.dispose();
    yearController.dispose();
    topicController.dispose();
    if (saved == null || !mounted) return;
    setState(() {
      if (existing == null) {
        _questions.add(saved);
      } else {
        final index = _questions.indexOf(existing);
        if (index >= 0) {
          _questions[index] = saved;
        }
      }
      _analysis = null;
      _error = null;
    });
  }

  void _removeQuestion(_PreviousQuestion question) {
    setState(() {
      _questions.remove(question);
      _analysis = null;
    });
  }

  Future<void> _analyzeBatch() async {
    if (_questions.isEmpty || _isBusy) return;
    final questionBatch = _questions
        .asMap()
        .entries
        .map((entry) => {
              'id': 'Q${entry.key + 1}',
              'question': entry.value.question,
              'marks': entry.value.marks,
              'year': entry.value.year,
              'topicHint': entry.value.topic,
            })
        .toList(growable: false);
    await _runAnalysis(
      title: 'Batch analysis · ${_questions.length} questions',
      prompt:
          '''Analyze all supplied previous-year questions together against the currently opened subject hierarchy. Use manual notes as primary context when available and academic knowledge to classify syllabus topics. Return JSON with topic_frequency (topic and count), marks_distribution (marks and count), frequently_repeated_questions, important_units, predicted_questions, and question_analysis. Each question_analysis item must include id, topic, difficulty, bloomLevel, model_answer, and marking_scheme. Do not invent historical facts beyond the supplied question years. Generate a complete model answer and marking scheme for every question.
Questions:
${jsonEncode(questionBatch)}''',
    );
  }

  Future<void> _analyzeSelectedPaper() async {
    final id = widget.topicId;
    if (id == null || id.isEmpty || id == 'current') return;
    await _runAnalysis(
      title: 'Selected saved source',
      topicId: id,
      sourceIds: [id],
      prompt:
          'Analyze the selected previous-year source against the currently opened subject hierarchy. Return JSON with topic_frequency, marks_distribution, frequently_repeated_questions, important_units, and predicted_questions. Do not invent historical facts.',
    );
  }

  Future<void> _runAnalysis({
    required String title,
    required String prompt,
    String? topicId,
    List<String> sourceIds = const [],
  }) async {
    setState(() {
      _error = null;
      _isBusy = true;
      _analysis = ref.read(knowledgeEngineProvider).generatePYQ(
            topicId: topicId ?? widget.topicId,
            subjectId: ref.read(activeKnowledgeSubjectIdProvider) ??
                ref.read(activeKnowledgeWorkspaceIdProvider),
            sourceIds: sourceIds.isEmpty
                ? ref.read(selectedKnowledgeSourceIdsProvider)
                : sourceIds,
            prompt: prompt,
          );
    });
    try {
      await _analysis;
    } catch (_) {
      if (mounted)
        setState(() => _error = 'Analysis failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectName = ref.watch(activeKnowledgeSubjectNameProvider);
    final activeSubjectId =
        ref.watch(activeKnowledgeSubjectIdProvider) ?? '';

    // ── Reactive library sync ───────────────────────────────────────
    ref.listen<AsyncValue<String>>(
      subjectTopicsVersionProvider(activeSubjectId),
      (_, next) {
        final version = next.valueOrNull;
        if (version == null || version.isEmpty) return;
        if (_lastLibraryVersion == null) {
          _lastLibraryVersion = version;
          return;
        }
        if (version == _lastLibraryVersion) return;
        _lastLibraryVersion = version;
        _libraryChangeDebounce?.cancel();
        _libraryChangeDebounce =
            Timer(const Duration(milliseconds: 600), () {
          if (mounted && !_isBusy) {
            setState(() {
              _analysis = null;
              _error = null;
            });
          }
        });
      },
    );
    return Scaffold(
      appBar: AppBar(
        title:
            Text('${subjectName == null ? '' : '$subjectName · '}PYQ Studio'),
        leading: BackButton(onPressed: () => Navigator.maybePop(context)),
        actions: [
          if (_analysis != null)
            TextButton.icon(
              onPressed:
                  _isBusy ? null : () => setState(() => _analysis = null),
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('Edit batch'),
            ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 960;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _heading(context),
                const SizedBox(height: 18),
                _summary(context),
                const SizedBox(height: 18),
                if (wide)
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(flex: 6, child: _questionWorkspace(context)),
                    const SizedBox(width: 20),
                    Expanded(flex: 5, child: _analysisPanel(context)),
                  ])
                else ...[
                  _questionWorkspace(context),
                  const SizedBox(height: 18),
                  _analysisPanel(context),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _heading(BuildContext context) => Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.teal.withOpacity(.13),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.manage_search_rounded, color: AppColors.teal),
        ),
        const SizedBox(width: 14),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Previous-year question studio',
                style: Theme.of(context).textTheme.headlineSmall),
            Text(
                'Build a question bank, inspect patterns, and draft model answers.',
                style: Theme.of(context).textTheme.bodyMedium),
          ]),
        ),
      ]).animate().fadeIn().slideY(begin: .04, end: 0);

  Widget _summary(BuildContext context) {
    final marks = _questions.fold<int>(0, (sum, item) => sum + item.marks);
    final years = _questions
        .map((item) => item.year)
        .where((year) => year.isNotEmpty)
        .toSet()
        .length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Wrap(spacing: 28, runSpacing: 12, children: [
          _metric(context, Icons.library_books_outlined, '${_questions.length}',
              'questions'),
          _metric(context, Icons.stars_outlined, '$marks', 'total marks'),
          _metric(context, Icons.event_outlined, '$years', 'year tags'),
          if (widget.topicId != null && widget.topicId != 'current')
            TextButton.icon(
              onPressed: _isBusy ? null : _analyzeSelectedPaper,
              icon: const Icon(Icons.auto_graph_rounded),
              label: const Text('Analyze saved source'),
            ),
        ]),
      ),
    );
  }

  Widget _metric(
          BuildContext context, IconData icon, String value, String label) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 18, color: AppColors.electricVioletLight),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(width: 5),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ]);

  Widget _questionWorkspace(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Question bank',
                          style: Theme.of(context).textTheme.titleLarge),
                      Text('Add questions with marks, year, and topic context.',
                          style: Theme.of(context).textTheme.bodySmall),
                    ]),
              ),
              FilledButton.tonalIcon(
                onPressed: _isBusy ? null : () => _editQuestion(),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add question'),
              ),
            ]),
            const SizedBox(height: 14),
            if (_questions.isEmpty)
              _emptyState(context)
            else
              for (var i = 0; i < _questions.length; i++)
                _questionCard(context, _questions[i], i),
          ]),
        ),
      ).animate().fadeIn(delay: 70.ms).slideY(begin: .025, end: 0);

  Widget _emptyState(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withOpacity(.45),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: [
          const Icon(Icons.post_add_rounded, size: 34, color: AppColors.teal),
          const SizedBox(height: 10),
          Text('Start your PYQ collection',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Add questions from different years and mark values.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall),
        ]),
      );

  Widget _questionCard(
      BuildContext context, _PreviousQuestion question, int index) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(.4),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.electricViolet.withOpacity(.13),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('${index + 1}',
                style: const TextStyle(
                    color: AppColors.electricVioletLight,
                    fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 7, runSpacing: 5, children: [
                _tag(context, '${question.marks} marks', AppColors.teal),
                if (question.year.isNotEmpty)
                  _tag(context, question.year, AppColors.amber),
                if (question.topic.isNotEmpty)
                  _tag(context, question.topic, AppColors.electricVioletLight),
              ]),
              const SizedBox(height: 9),
              Text(question.question,
                  maxLines: 4, overflow: TextOverflow.ellipsis),
            ]),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') _editQuestion(existing: question);
              if (value == 'remove') _removeQuestion(question);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit question')),
              PopupMenuItem(value: 'remove', child: Text('Remove question')),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _tag(BuildContext context, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style:
                Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
      );

  Widget _analysisPanel(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.insights_rounded, color: AppColors.teal),
              const SizedBox(width: 9),
              Expanded(
                  child: Text('Analysis & answers',
                      style: Theme.of(context).textTheme.titleLarge)),
            ]),
            const SizedBox(height: 8),
            Text(
                'Analyze the whole batch to find recurring syllabus themes and create answer guides.',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _questions.isEmpty || _isBusy ? null : _analyzeBatch,
                icon: _isBusy
                    ? const SizedBox.square(
                        dimension: 17,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(
                    _isBusy ? 'Analyzing batch…' : 'Analyze question batch'),
                style:
                    FilledButton.styleFrom(padding: const EdgeInsets.all(15)),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            if (_analysis != null) ...[
              const SizedBox(height: 16),
              FutureBuilder<Map<String, dynamic>>(
                future: _analysis,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError || snapshot.data == null) {
                    return Text(_error ?? 'Analysis unavailable.');
                  }
                  return _analysisResults(context, snapshot.data!);
                },
              ),
            ],
          ]),
        ),
      ).animate().fadeIn(delay: 110.ms).slideY(begin: .025, end: 0);

  Widget _analysisResults(BuildContext context, Map<String, dynamic> data) {
    const fields = <(String, String)>[
      ('Topic-wise frequency', 'topic_frequency'),
      ('Marks distribution', 'marks_distribution'),
      ('Repeated themes', 'frequently_repeated_questions'),
      ('Important units', 'important_units'),
      ('Predicted questions', 'predicted_questions'),
    ];
    final cards = <Widget>[];
    for (final (title, key) in fields) {
      final raw = data[key];
      if (raw == null) continue;
      final values = raw is List ? raw : [raw];
      if (values.isEmpty) continue;
      cards.add(_resultCard(context, title, values.map(_display).toList()));
    }
    final answerItems = data['question_analysis'];
    if (answerItems is List) {
      for (final item in answerItems.whereType<Map>()) {
        final answer = Map<String, dynamic>.from(item);
        final title =
            '${answer['id'] ?? 'Question'} · ${answer['topic'] ?? 'Model answer'}';
        cards.add(_resultCard(context, title, [
          if (answer['model_answer'] != null)
            'Model answer: ${_display(answer['model_answer'])}',
          if (answer['marking_scheme'] != null)
            'Marking scheme: ${_display(answer['marking_scheme'])}',
          if (answer['difficulty'] != null)
            'Difficulty: ${answer['difficulty']}',
          if (answer['bloomLevel'] != null)
            "Bloom's level: ${answer['bloomLevel']}",
        ]));
      }
    }
    if (cards.isEmpty) return const Text('No analysis details were returned.');
    return Column(children: cards);
  }

  Widget _resultCard(BuildContext context, String title, List<String> rows) =>
      Card(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(.38),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('• $row'),
              ),
          ]),
        ),
      );

  String _display(dynamic value) {
    if (value is Map) {
      return value.entries
          .map((entry) => '${entry.key}: ${_display(entry.value)}')
          .join(' · ');
    }
    if (value is List) return value.map(_display).join(', ');
    return value?.toString() ?? '';
  }
}

class _PreviousQuestion {
  _PreviousQuestion({
    required this.question,
    required this.marks,
    required this.year,
    required this.topic,
  });

  final String question;
  final int marks;
  final String year;
  final String topic;
}
