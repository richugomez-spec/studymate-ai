import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ai/services/knowledge_engine.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../services/firestore_service.dart';

class ExamGeneratorScreen extends ConsumerStatefulWidget {
  final String? topicId;
  const ExamGeneratorScreen({super.key, this.topicId});

  @override
  ConsumerState<ExamGeneratorScreen> createState() =>
      _ExamGeneratorScreenState();
}

class _ExamGeneratorScreenState extends ConsumerState<ExamGeneratorScreen> {
  final List<_ExamSectionConfig> _sections = [
    _ExamSectionConfig(
        name: 'Part A',
        marksPerQuestion: 2,
        questionCount: 10,
        compulsoryCount: 10),
    _ExamSectionConfig(
        name: 'Part B',
        marksPerQuestion: 5,
        questionCount: 5,
        compulsoryCount: 3),
    _ExamSectionConfig(
        name: 'Part C',
        marksPerQuestion: 10,
        questionCount: 2,
        compulsoryCount: 2),
  ];
  int _durationMinutes = 120;
  bool _isGenerating = false;
  String? _error;
  Future<Map<String, dynamic>>? _result;
  final Set<int> _revealedAnswers = {};

  // Reactive sync
  Timer? _libraryChangeDebounce;
  String? _lastLibraryVersion;

  int get _totalMarks => _sections.fold<int>(0,
      (sum, section) => sum + section.questionCount * section.marksPerQuestion);
  int get _questionCount =>
      _sections.fold<int>(0, (sum, section) => sum + section.questionCount);

  @override
  void dispose() {
    for (final section in _sections) {
      section.dispose();
    }
    _libraryChangeDebounce?.cancel();
    super.dispose();
  }

  void _addSection() {
    setState(() => _sections.add(_ExamSectionConfig(
          name: 'Part ${String.fromCharCode(65 + _sections.length)}',
          compulsoryCount: 4,
        )));
  }

  void _removeSection(_ExamSectionConfig section) {
    if (_sections.length == 1) return;
    setState(() => _sections.remove(section));
    section.dispose();
  }

  void _generate() {
    final sectionBrief = _sections.map((section) {
      final blooms = section.bloomLevels.toList()..sort();
      return '''${section.name}:
- ${section.questionCount} questions, ${section.marksPerQuestion} marks each
- ${section.compulsoryCount} compulsory and ${section.questionCount - section.compulsoryCount} optional
- Difficulty distribution target: Easy ${section.easyPercent}%, Moderate ${section.moderatePercent}%, Challenging ${section.challengingPercent}%
- Bloom's levels: ${blooms.join(', ')}
- Instructions: ${section.instructionsController.text.trim().isEmpty ? 'None' : section.instructionsController.text.trim()}''';
    }).join('\n\n');
    final subjectId = ref.read(activeKnowledgeSubjectIdProvider) ??
        ref.read(activeKnowledgeWorkspaceIdProvider);
    setState(() {
      _error = null;
      _isGenerating = true;
      _revealedAnswers.clear();
      _result = ref.read(knowledgeEngineProvider).generateExam(
        topicId: widget.topicId,
        subjectId: subjectId,
        sourceIds: ref.read(selectedKnowledgeSourceIdsProvider),
        prompt:
            '''Build a complete $_totalMarks-mark university examination with an estimated duration of $_durationMinutes minutes.
Create exactly $_questionCount questions across these sections. Return JSON with title and a questions array. Each question must include section, prompt, marks, compulsory (boolean), difficulty, bloomLevel, modelAnswer, markingScheme (list), and commonMistakes (list). The configured section count, marks, compulsory/optional balance, difficulty distribution, Bloom's levels, and instructions are:
$sectionBrief
Use the currently opened subject hierarchy as the syllabus, manual notes as primary context when available, and academic knowledge to fill gaps. Preserve the syllabus hierarchy. Do not include answers in question prompts. Do not invent syllabus topics.''',
      );
    });
    _result!.then((_) {
      if (mounted) setState(() => _isGenerating = false);
    }).catchError((Object error) {
      if (mounted) {
        setState(() {
          _error = 'We could not create an exam right now. Please try again.';
          _isGenerating = false;
        });
      }
    });
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
          if (mounted && !_isGenerating) {
            setState(() {
              _result = null;
              _error = null;
              _revealedAnswers.clear();
            });
          }
        });
      },
    );
    return Scaffold(
      appBar: AppBar(
        title:
            Text('${subjectName == null ? '' : '$subjectName · '}Exam Builder'),
        leading: BackButton(onPressed: () => Navigator.maybePop(context)),
        actions: [
          if (_result != null)
            TextButton.icon(
              onPressed:
                  _isGenerating ? null : () => setState(() => _result = null),
              icon: const Icon(Icons.tune_rounded),
              label: const Text('Edit blueprint'),
            ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: _result == null
                ? _buildBlueprint(context, wide)
                : _buildResult(context),
          ),
        );
      }),
    );
  }

  Widget _buildBlueprint(BuildContext context, bool wide) {
    final summary = _overviewCard(context);
    final sections = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
            child: Text('Exam sections',
                style: Theme.of(context).textTheme.titleLarge),
          ),
          OutlinedButton.icon(
            onPressed: _addSection,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add section'),
          ),
        ]),
        const SizedBox(height: 12),
        for (var i = 0; i < _sections.length; i++)
          _sectionCard(context, _sections[i], i),
        const SizedBox(height: 20),
        if (_error != null) _errorBanner(_error!),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isGenerating ? null : _generate,
            icon: _isGenerating
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome_rounded),
            label: Text(
                _isGenerating ? 'Building your exam…' : 'Generate examination'),
            style: FilledButton.styleFrom(padding: const EdgeInsets.all(18)),
          ),
        ),
      ],
    );
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _pageHeading(context),
        const SizedBox(height: 20),
        if (wide)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 7, child: sections),
            const SizedBox(width: 20),
            Expanded(flex: 3, child: summary),
          ])
        else ...[
          summary,
          const SizedBox(height: 20),
          sections,
        ],
      ],
    );
  }

  Widget _pageHeading(BuildContext context) => Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.electricViolet.withOpacity(.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.fact_check_rounded,
                color: AppColors.electricVioletLight),
          ),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Examination workspace',
                  style: Theme.of(context).textTheme.headlineSmall),
              Text(
                  'Design the paper, then generate questions and marking guides.',
                  style: Theme.of(context).textTheme.bodyMedium),
            ]),
          ),
        ],
      ).animate().fadeIn().slideY(begin: .04, end: 0);

  Widget _overviewCard(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Paper overview',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(spacing: 10, runSpacing: 10, children: [
              _metric(context, Icons.stars_rounded, '$_totalMarks', 'marks'),
              _metric(
                  context, Icons.quiz_outlined, '$_questionCount', 'questions'),
              _metric(context, Icons.schedule_rounded, '$_durationMinutes',
                  'minutes'),
            ]),
            const SizedBox(height: 20),
            Text('Estimated duration',
                style: Theme.of(context).textTheme.titleSmall),
            Row(children: [
              const Icon(Icons.timer_outlined, size: 18),
              Expanded(
                child: Slider(
                  min: 15,
                  max: 240,
                  divisions: 15,
                  value: _durationMinutes.toDouble(),
                  label: '$_durationMinutes min',
                  onChanged: (value) =>
                      setState(() => _durationMinutes = value.round()),
                ),
              ),
              Text('$_durationMinutes min'),
            ]),
            const Divider(height: 28),
            Text('Blueprint totals update as you edit sections.',
                style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
      ).animate().fadeIn(delay: 80.ms).slideY(begin: .03, end: 0);

  Widget _metric(
          BuildContext context, IconData icon, String value, String label) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 17, color: AppColors.electricVioletLight),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ]),
      );

  Widget _sectionCard(
      BuildContext context, _ExamSectionConfig section, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(.13),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${index + 1}',
                  style: const TextStyle(
                      color: AppColors.teal, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                initialValue: section.name,
                onChanged: (value) => section.name = value.trim().isEmpty
                    ? 'Part ${String.fromCharCode(65 + index)}'
                    : value,
                decoration: const InputDecoration(
                    labelText: 'Section name', isDense: true),
              ),
            ),
            if (_sections.length > 1)
              IconButton(
                tooltip: 'Remove section',
                onPressed: () => _removeSection(section),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
          ]),
          const SizedBox(height: 18),
          Wrap(spacing: 16, runSpacing: 8, children: [
            _numberControl(
                context,
                'Questions',
                section.questionCount,
                1,
                50,
                (value) => setState(() {
                      section.questionCount = value;
                      section.compulsoryCount =
                          section.compulsoryCount.clamp(0, value);
                    })),
            _numberControl(
                context,
                'Marks each',
                section.marksPerQuestion,
                1,
                100,
                (value) => setState(() => section.marksPerQuestion = value)),
            _numberControl(
                context,
                'Compulsory',
                section.compulsoryCount,
                0,
                section.questionCount,
                (value) => setState(() => section.compulsoryCount = value)),
          ]),
          const SizedBox(height: 18),
          Text('Difficulty distribution',
              style: Theme.of(context).textTheme.titleSmall),
          _distributionSlider(
              context,
              'Easy',
              section.easyPercent,
              (value) =>
                  setState(() => _setDifficulty(section, 'easy', value))),
          _distributionSlider(
              context,
              'Moderate',
              section.moderatePercent,
              (value) =>
                  setState(() => _setDifficulty(section, 'moderate', value))),
          _distributionSlider(
              context,
              'Challenging',
              section.challengingPercent,
              (value) => setState(
                  () => _setDifficulty(section, 'challenging', value))),
          const SizedBox(height: 8),
          Text("Bloom's taxonomy",
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(spacing: 7, runSpacing: 4, children: [
            for (final level in _bloomLevels)
              FilterChip(
                label: Text(level),
                selected: section.bloomLevels.contains(level),
                onSelected: (selected) => setState(() {
                  if (selected) {
                    section.bloomLevels.add(level);
                  } else if (section.bloomLevels.length > 1) {
                    section.bloomLevels.remove(level);
                  }
                }),
              ),
          ]),
          const SizedBox(height: 14),
          TextField(
            controller: section.instructionsController,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Custom instructions',
              hintText: 'e.g. Include one case study and show all working',
              prefixIcon: Icon(Icons.notes_rounded),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${section.questionCount - section.compulsoryCount} optional questions; students answer ${section.compulsoryCount} compulsory.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ]),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 40 * index))
        .slideY(begin: .025, end: 0);
  }

  Widget _numberControl(BuildContext context, String label, int value, int min,
      int max, ValueChanged<int> onChanged) {
    return SizedBox(
      width: 175,
      child: Row(children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text('$value', style: Theme.of(context).textTheme.titleMedium),
          ]),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline_rounded),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_circle_outline_rounded),
        ),
      ]),
    );
  }

  Widget _distributionSlider(BuildContext context, String label, int value,
          ValueChanged<int> onChanged) =>
      Row(children: [
        SizedBox(width: 98, child: Text(label)),
        Expanded(
          child: Slider(
            min: 0,
            max: 100,
            divisions: 10,
            value: value.toDouble(),
            label: '$value%',
            onChanged: (next) => onChanged(next.round()),
          ),
        ),
        SizedBox(width: 42, child: Text('$value%')),
      ]);

  void _setDifficulty(_ExamSectionConfig section, String selected, int value) {
    final remaining = 100 - value;
    if (selected == 'easy') {
      final otherTotal = section.moderatePercent + section.challengingPercent;
      section.easyPercent = value;
      section.moderatePercent = otherTotal == 0
          ? remaining ~/ 2
          : (remaining * section.moderatePercent / otherTotal).round();
      section.challengingPercent = remaining - section.moderatePercent;
    } else if (selected == 'moderate') {
      final otherTotal = section.easyPercent + section.challengingPercent;
      section.moderatePercent = value;
      section.easyPercent = otherTotal == 0
          ? remaining ~/ 2
          : (remaining * section.easyPercent / otherTotal).round();
      section.challengingPercent = remaining - section.easyPercent;
    } else {
      final otherTotal = section.easyPercent + section.moderatePercent;
      section.challengingPercent = value;
      section.easyPercent = otherTotal == 0
          ? remaining ~/ 2
          : (remaining * section.easyPercent / otherTotal).round();
      section.moderatePercent = remaining - section.easyPercent;
    }
  }

  Widget _buildResult(BuildContext context) =>
      FutureBuilder<Map<String, dynamic>>(
        future: _result,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
                child: _errorBanner(_error ?? 'Exam generation failed.'));
          }
          final data = snapshot.data!;
          final questions = (data['questions'] as List? ?? const [])
              .whereType<Map>()
              .map(Map<String, dynamic>.from)
              .where((question) =>
                  (question['prompt'] ?? question['question'] ?? '')
                      .toString()
                      .trim()
                      .isNotEmpty)
              .toList();
          if (questions.isEmpty) {
            return Center(
                child: _errorBanner(
                    'No questions were returned. Edit the blueprint and try again.'));
          }
          return ListView(padding: const EdgeInsets.all(24), children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(children: [
                  const Icon(Icons.verified_outlined,
                      color: AppColors.teal, size: 30),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              (data['title'] ?? 'Practice Examination')
                                  .toString(),
                              style: Theme.of(context).textTheme.titleLarge),
                          Text(
                              '$_totalMarks marks · $_durationMinutes minutes · ${questions.length} questions'),
                        ]),
                  ),
                  IconButton(
                    tooltip: 'Edit blueprint',
                    onPressed: () => setState(() => _result = null),
                    icon: const Icon(Icons.tune_rounded),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < questions.length; i++)
              _questionCard(questions[i], i),
          ]);
        },
      );

  Widget _questionCard(Map<String, dynamic> question, int index) {
    final revealed = _revealedAnswers.contains(index);
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 8, runSpacing: 6, children: [
            _tag(theme, 'Q${index + 1}', AppColors.electricViolet),
            _tag(theme, '${question['marks'] ?? ''} marks', AppColors.teal),
            if (question['section'] != null)
              _tag(theme, question['section'].toString(), AppColors.amber),
            if (question['difficulty'] != null)
              _tag(theme, question['difficulty'].toString(),
                  AppColors.electricVioletLight),
            if (question['bloomLevel'] != null)
              _tag(theme, question['bloomLevel'].toString(), AppColors.teal),
            if (question['compulsory'] != null)
              _tag(
                  theme,
                  question['compulsory'] == true ? 'Compulsory' : 'Optional',
                  AppColors.amber),
          ]),
          const SizedBox(height: 12),
          Text((question['prompt'] ?? question['question'] ?? '').toString(),
              style: theme.textTheme.titleMedium),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() => revealed
                  ? _revealedAnswers.remove(index)
                  : _revealedAnswers.add(index)),
              icon: Icon(revealed
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined),
              label: Text(revealed ? 'Hide answer' : 'Reveal answer'),
            ),
          ),
          if (revealed) ...[
            const Divider(),
            _answerSection(
                'Model answer', question['modelAnswer'] ?? question['answer']),
            _answerSection('Marking scheme', question['markingScheme']),
            _answerSection('Common mistakes', question['commonMistakes']),
          ],
        ]),
      ),
    );
  }

  Widget _tag(ThemeData theme, String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: theme.textTheme.labelMedium?.copyWith(color: color)),
      );

  Widget _answerSection(String title, dynamic value) {
    if (value == null) return const SizedBox.shrink();
    final values = value is List ? value : [value];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        for (final item in values)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(
                '• ${item is Map ? (item['criterion'] ?? item['point'] ?? item['text'] ?? '').toString() : item.toString()}'),
          ),
      ]),
    );
  }

  Widget _errorBanner(String message) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message),
      );
}

const _bloomLevels = <String>[
  'Remember',
  'Understand',
  'Apply',
  'Analyze',
  'Evaluate',
  'Create',
];

class _ExamSectionConfig {
  _ExamSectionConfig({
    required this.name,
    required this.compulsoryCount,
    this.marksPerQuestion = 5,
    this.questionCount = 4,
  });

  String name;
  int marksPerQuestion;
  int questionCount;
  int compulsoryCount;
  int easyPercent = 25;
  int moderatePercent = 50;
  int challengingPercent = 25;
  final Set<String> bloomLevels = {'Understand', 'Apply', 'Analyze'};
  final TextEditingController instructionsController = TextEditingController();

  void dispose() => instructionsController.dispose();
}
