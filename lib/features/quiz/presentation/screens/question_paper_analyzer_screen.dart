import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ai/services/knowledge_engine.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../core/services/firebase_upload_service.dart';
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
  Future<Map<String, dynamic>>? _analysis;
  bool _isBusy = false;
  String? _error;
  String? _paperName;

  Future<void> _uploadAndAnalyze() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const [
        'pdf',
        'docx',
        'pptx',
        'txt',
        'md',
        'png',
        'jpg',
        'jpeg'
      ],
      allowMultiple: false,
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    if (file.bytes == null) {
      setState(
          () => _error = 'Could not read that file. Please choose it again.');
      return;
    }
    setState(() {
      _isBusy = true;
      _error = null;
      _paperName = file.name;
      _analysis = null;
    });
    String? documentId;
    try {
      final result = await ref.read(firebaseUploadServiceProvider).uploadFile(
        file,
        subject: 'Previous Year Papers',
        topic: 'PYQ',
        tags: const ['pyq'],
      );
      documentId = result.firestoreDocId;
      final firestore = ref.read(firestoreServiceProvider);
      await firestore.setDocumentStatus(documentId, 'processing');
      final text =
          await ref.read(documentProcessingServiceProvider).extractText(file);
      await ref.read(knowledgeEngineProvider).index(
            sourceId: documentId,
            title: file.name,
            content: text,
            subject: 'Previous Year Papers',
            topic: 'PYQ',
            sourceBytes: file.bytes,
            mimeType: _mimeType(file.extension),
          );
      await _analyzePaper(documentId, file.name);
    } catch (_) {
      debugPrint('Previous-year paper processing did not complete.');
      if (documentId != null) {
        await ref
            .read(firestoreServiceProvider)
            .setDocumentIndexError(documentId, 'unavailable');
      }
      if (mounted) {
        setState(() => _error =
            'We could not process this paper. Please try another file.');
      }
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
            prompt:
                'Analyze only this uploaded previous-year question paper. Return JSON with frequently_repeated_questions (list, only evidence present in the paper), topic_frequency (list of topic and count), marks_distribution (list), important_units (list), and predicted_questions (list grounded in observed patterns). Do not invent repeated questions, frequencies, or marks.',
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
    return Scaffold(
      appBar: AppBar(
          title: const Text('PYQ Analyzer'),
          leading: BackButton(onPressed: () => Navigator.maybePop(context)),
          actions: [
            if (_analysis != null)
              IconButton(
                  onPressed: _uploadAndAnalyze,
                  tooltip: 'Upload another paper',
                  icon: const Icon(Icons.upload_file_outlined)),
          ]),
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
              const Icon(Icons.fact_check_outlined, size: 48),
              const SizedBox(height: 12),
              const Text('Analyze a previous-year paper',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text(
                  'Upload a paper for question, topic, marks, and unit analysis. Predictions are based only on the uploaded paper.'),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 18),
              FilledButton.icon(
                  onPressed: _uploadAndAnalyze,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Previous Year Question Paper')),
              if (widget.topicId != null && widget.topicId != 'current') ...[
                const SizedBox(height: 8),
                TextButton(
                    onPressed: _analyzeSelectedPaper,
                    child: const Text('Analyze selected paper')),
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

  String _display(dynamic item) {
    if (item is Map) {
      return item.entries
          .map((entry) => '${entry.key}: ${_display(entry.value)}')
          .join(' · ');
    }
    if (item is List) return item.map(_display).join(', ');
    return item?.toString() ?? '';
  }

  String _mimeType(String? extension) => switch (extension?.toLowerCase()) {
        'pdf' => 'application/pdf',
        'docx' =>
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'pptx' =>
          'application/vnd.openxmlformats-officedocument.presentationml.presentation',
        'txt' => 'text/plain',
        'md' => 'text/markdown',
        'png' => 'image/png',
        'jpg' || 'jpeg' => 'image/jpeg',
        _ => 'application/octet-stream',
      };
}
