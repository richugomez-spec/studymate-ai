import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ai/services/knowledge_engine.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../services/firestore_service.dart';

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

  // Reactive sync fields
  Timer? _libraryChangeDebounce;
  String? _lastLibraryVersion;

  @override
  void initState() {
    super.initState();
    _mode = SummaryMode.values.firstWhere((m) => m.name == widget.initialMode,
        orElse: () => SummaryMode.short);
    _generate();
  }

  @override
  void dispose() {
    _libraryChangeDebounce?.cancel();
    super.dispose();
  }

  void _generate({bool forceRefresh = false}) =>
      _result = ref.read(knowledgeEngineProvider).generateSummary(
            topicId: widget.topicId,
            subjectId: ref.read(activeKnowledgeSubjectIdProvider) ??
                ref.read(activeKnowledgeWorkspaceIdProvider),
            sourceIds: ref.read(selectedKnowledgeSourceIdsProvider),
            forceRefresh: forceRefresh,
            prompt: switch (_mode) {
              SummaryMode.short =>
                'Create concise study notes. Return JSON with exactly these keys: overview (string), key_takeaways (list).',
              SummaryMode.detailed =>
                'Create a detailed summary. Return JSON with exactly these keys: overview (string), key_concepts (list), important_points (list), examples (list), exam_tips (list). Use concise, useful study content in every section.',
              SummaryMode.exam =>
                'Create exam revision notes. Return JSON with exactly these keys: overview (string), important_points (list), exam_tips (list).',
              SummaryMode.formula =>
                'Generate a formula sheet. Return JSON with exactly these keys: formulas (list), variable_meanings (list), examples (list).',
            },
          );

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
          if (mounted) setState(() => _generate(forceRefresh: true));
        });
      },
    );
    return Scaffold(
      appBar: AppBar(
          title: Text(
              '${subjectName == null || subjectName.isEmpty ? '' : '$subjectName · '}${switch (_mode) {
            SummaryMode.formula => 'Formula Sheet',
            SummaryMode.exam => 'Exam Notes',
            _ => 'Study Summary'
          }}'),
          leading: BackButton(onPressed: () => Navigator.maybePop(context)),
          actions: [
            IconButton(
                onPressed: () => setState(() => _generate(forceRefresh: true)),
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
                    return const Center(child: Text('Please try again.'));
                  final result = snapshot.data;
                  if (result == null) {
                    return const Center(
                        child:
                            Text('Could not format this summary. Try again.'));
                  }
                  return _buildSummary(context, result);
                })),
      ]),
    );
  }

  Widget _buildSummary(BuildContext context, Map<String, dynamic> data) {
    final sections = switch (_mode) {
      SummaryMode.detailed => <(String, List<String>)>[
          ('Overview', ['overview', 'summary']),
          ('Key Concepts', ['key_concepts', 'key concepts', 'concepts']),
          ('Important Points', ['important_points', 'key_points', 'points']),
          ('Examples', ['examples']),
          ('Exam Tips', ['exam_tips', 'exam_tips_and_traps', 'tips']),
        ],
      SummaryMode.short => <(String, List<String>)>[
          ('Overview', ['overview', 'summary', 'short_summary']),
          ('Key Takeaways', ['key_takeaways', 'key_points', 'points']),
        ],
      SummaryMode.exam => <(String, List<String>)>[
          ('Overview', ['overview', 'summary']),
          ('Important Points', ['important_points', 'key_points']),
          ('Exam Tips', ['exam_tips', 'tips']),
        ],
      SummaryMode.formula => <(String, List<String>)>[
          ('Formulas', ['formulas', 'formulae']),
          ('Variable Meanings', ['variable_meanings', 'variables']),
          ('Examples', ['examples']),
        ],
    };

    final children = <Widget>[];
    for (final (title, keys) in sections) {
      final key = keys.firstWhere(
        data.containsKey,
        orElse: () => '',
      );
      final value = key.isEmpty ? null : data[key];
      final lines = _displayLines(value);
      if (lines.isEmpty) continue;
      children.add(Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              const SizedBox(height: 8),
              for (final line in lines)
                Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(lines.length == 1 && title == 'Overview'
                        ? line
                        : '• $line')),
            ],
          ),
        ),
      ));
    }
    if (children.isEmpty) {
      return const Center(
          child: Text('Could not format this summary. Try again.'));
    }
    return ListView(padding: const EdgeInsets.all(20), children: children);
  }

  List<String> _displayLines(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value.map(_displayValue).where((s) => s.isNotEmpty).toList();
    }
    final text = _displayValue(value);
    return text.isEmpty ? const [] : [text];
  }

  String _displayValue(dynamic value) {
    if (value is String || value is num) return value.toString();
    if (value is Map) {
      for (final key in ['text', 'content', 'description', 'name', 'title']) {
        if (value[key] != null) return _displayValue(value[key]);
      }
      return value.values
          .map(_displayValue)
          .where((s) => s.isNotEmpty)
          .join(' · ');
    }
    if (value is List)
      return value.map(_displayValue).where((s) => s.isNotEmpty).join(' · ');
    return '';
  }
}
