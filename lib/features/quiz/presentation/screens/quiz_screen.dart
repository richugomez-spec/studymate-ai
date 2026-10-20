import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../core/ai/services/knowledge_engine.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../services/firestore_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

enum QuizType { mcq, trueFalse, fillBlank, shortAnswer }

enum QuizDifficulty { easy, medium, hard }

class _GeneratedQuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String correctAnswer;
  final String explanation;
  final String conceptTitle;
  final QuizType type;

  const _GeneratedQuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.correctAnswer,
    required this.explanation,
    required this.conceptTitle,
    required this.type,
  });
}

class QuizScreen extends ConsumerStatefulWidget {
  final String? topicId;
  const QuizScreen({super.key, this.topicId});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  // Configuration options
  int _questionCount = 5;
  QuizDifficulty _difficulty = QuizDifficulty.medium;
  QuizType _quizType = QuizType.mcq;
  bool _quizStarted = false;

  // Active quiz state
  int _currentIndex = 0;
  int? _selectedAnswer;
  final TextEditingController _textAnswerController = TextEditingController();
  bool _answered = false;
  int _score = 0;
  bool _quizComplete = false;
  final List<String> _weakTopics = [];

  List<_GeneratedQuizQuestion> _questions = [];

  @override
  void dispose() {
    _textAnswerController.dispose();
    super.dispose();
  }

  Future<void> _generateQuiz(UploadedDocument doc) async {
    _questions.clear();
    final result = await ref.read(knowledgeEngineProvider).generateQuiz(
          topicId: widget.topicId ?? doc.id,
          prompt:
              'Create $_questionCount ${_difficulty.name} ${_quizType.name} questions. Return questions with question, options, answer, explanation, and conceptTitle.',
        );
    final generated = result['questions'];
    if (generated is List) {
      for (final item in generated.whereType<Map>()) {
        final q = Map<String, dynamic>.from(item);
        final options = (q['options'] as List? ?? const [])
            .map((e) => e.toString())
            .toList();
        final answer = (q['answer'] ?? '').toString();
        _questions.add(_GeneratedQuizQuestion(
          question: (q['question'] ?? '').toString(),
          options: options,
          correctIndex:
              (q['answerIndex'] as num?)?.toInt() ?? options.indexOf(answer),
          correctAnswer: answer,
          explanation: (q['explanation'] ?? '').toString(),
          conceptTitle: (q['conceptTitle'] ?? '').toString(),
          type: _quizType,
        ));
      }
    }

    setState(() {
      _quizStarted = true;
      _currentIndex = 0;
      _selectedAnswer = null;
      _answered = false;
      _score = 0;
      _quizComplete = false;
      _weakTopics.clear();
    });
  }

  void _submitChoice(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      final q = _questions[_currentIndex];
      if (index == q.correctIndex) {
        _score++;
      } else {
        if (!_weakTopics.contains(q.conceptTitle)) {
          _weakTopics.add(q.conceptTitle);
        }
      }
    });
  }

  void _submitTextAnswer() {
    if (_answered) return;
    final text = _textAnswerController.text.trim().toLowerCase();
    final q = _questions[_currentIndex];
    final isCorrect = text.isNotEmpty &&
        (q.correctAnswer.toLowerCase().contains(text) ||
            text.contains(q.correctAnswer.toLowerCase()));

    setState(() {
      _answered = true;
      if (isCorrect) {
        _score++;
      } else {
        if (!_weakTopics.contains(q.conceptTitle)) {
          _weakTopics.add(q.conceptTitle);
        }
      }
    });
  }

  Future<void> _nextQuestion() async {
    _textAnswerController.clear();
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      // Record in Firestore
      final user = ref.read(currentUserProvider);
      final firestoreService = ref.read(firestoreServiceProvider);
      final uid = user?.id ?? firestoreService.currentUserId;
      if (uid != null && uid.isNotEmpty) {
        unawaited(firestoreService.incrementQuizzesCompleted(uid));
      }
      setState(() => _quizComplete = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeDoc = ref.watch(activeDocumentProvider);

    if (activeDoc == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
            title: const Text('Quiz Generator',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 16))),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkBorderSubtle),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.quiz_rounded,
                    size: 40, color: AppColors.electricViolet),
                const SizedBox(height: 12),
                const Text('No Document Active',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                    'Upload a document or select one in your Library to generate custom quizzes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.white60)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.uploadCenter),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricViolet,
                      foregroundColor: Colors.white),
                  icon: const Icon(Icons.upload_file_rounded, size: 16),
                  label: const Text('Upload Document'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Setup Mode ────────────────────────────────────────────────────────────
    if (!_quizStarted) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
            title: Text('Quiz Setup: ${activeDoc.fileName}',
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 15),
                overflow: TextOverflow.ellipsis)),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Configure Active Assessment',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Questions are dynamically adapted to your notes.',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Colors.white60)),

                  const SizedBox(height: 24),

                  // Question count selector (5, 10, 20)
                  const Text('NUMBER OF QUESTIONS',
                      style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkTextTertiary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [5, 10, 20].map((count) {
                      final sel = _questionCount == count;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () => setState(() => _questionCount = count),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: sel
                                    ? AppColors.electricViolet
                                    : AppColors.darkSurfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: sel
                                        ? AppColors.electricViolet
                                        : AppColors.darkBorderSubtle),
                              ),
                              child: Text('$count Qs',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          sel ? Colors.white : Colors.white70)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Difficulty (Easy, Medium, Hard)
                  const Text('DIFFICULTY LEVEL',
                      style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkTextTertiary)),
                  const SizedBox(height: 8),
                  Row(
                    children: QuizDifficulty.values.map((d) {
                      final sel = _difficulty == d;
                      final label = d.name.toUpperCase();
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () => setState(() => _difficulty = d),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: sel
                                    ? AppColors.teal
                                    : AppColors.darkSurfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: sel
                                        ? AppColors.teal
                                        : AppColors.darkBorderSubtle),
                              ),
                              child: Text(label,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          sel ? Colors.white : Colors.white70)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Quiz format (MCQ, True/False, Fill blank, Short Answer)
                  const Text('QUESTION FORMAT',
                      style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkTextTertiary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTypeChip('Multiple Choice (MCQ)', QuizType.mcq),
                      _buildTypeChip('True / False', QuizType.trueFalse),
                      _buildTypeChip('Fill in the Blank', QuizType.fillBlank),
                      _buildTypeChip('Short Answer', QuizType.shortAnswer),
                    ],
                  ),

                  const SizedBox(height: 28),

                  ElevatedButton(
                    onPressed: () => _generateQuiz(activeDoc),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricViolet,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Start Quiz',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ── Completion Screen ─────────────────────────────────────────────────────
    if (_quizComplete) {
      final percentage = ((_score / _questions.length) * 100).round();
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
            title: const Text('Quiz Results',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 16))),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.darkBorderSubtle),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                      percentage >= 70
                          ? Icons.stars_rounded
                          : Icons.psychology_rounded,
                      size: 52,
                      color:
                          percentage >= 70 ? AppColors.teal : AppColors.amber),
                  const SizedBox(height: 16),
                  Text('Score: $_score / ${_questions.length} ($percentage%)',
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 6),
                  Text(
                      percentage >= 70
                          ? 'Excellent mastery of these micro-concepts!'
                          : 'Review the identified weak areas below.',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Colors.white70)),
                  if (_weakTopics.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('WEAK TOPICS IDENTIFIED',
                          style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.error)),
                    ),
                    const SizedBox(height: 8),
                    ..._weakTopics.map((wt) => Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: AppColors.error.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  size: 14, color: AppColors.error),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(wt,
                                      style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 12.5,
                                          color: Colors.white))),
                            ],
                          ),
                        )),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _quizStarted = false),
                          style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Colors.white.withOpacity(0.2))),
                          child: const Text('Configure New Quiz',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context.go(AppRoutes.home),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.electricViolet,
                              foregroundColor: Colors.white),
                          child: const Text('Done',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ── Active Quiz Flow ──────────────────────────────────────────────────────
    final q = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Question ${_currentIndex + 1} of ${_questions.length}',
            style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 15)),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.06),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.electricViolet),
              minHeight: 3),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Topic pill
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppColors.electricViolet.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(q.conceptTitle.toUpperCase(),
                          style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.electricVioletLight)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(q.question,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.4)),

                  const SizedBox(height: 24),

                  // Options for MCQ / TrueFalse
                  if (q.type == QuizType.mcq ||
                      q.type == QuizType.trueFalse) ...[
                    ...List.generate(q.options.length, (idx) {
                      final opt = q.options[idx];
                      Color borderCol = AppColors.darkBorderSubtle;
                      Color bgCol = AppColors.darkSurfaceVariant;
                      if (_answered) {
                        if (idx == q.correctIndex) {
                          borderCol = AppColors.teal;
                          bgCol = AppColors.teal.withOpacity(0.12);
                        } else if (idx == _selectedAnswer) {
                          borderCol = AppColors.error;
                          bgCol = AppColors.error.withOpacity(0.12);
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => _submitChoice(idx),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                                color: bgCol,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: borderCol)),
                            child: Row(
                              children: [
                                Text('${String.fromCharCode(65 + idx)}.',
                                    style: TextStyle(
                                        fontFamily: 'JetBrains Mono',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: borderCol == AppColors.teal
                                            ? AppColors.teal
                                            : Colors.white60)),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Text(opt,
                                        style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            color: Colors.white))),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ] else ...[
                    // Text Entry for Fill in Blank / Short Answer
                    TextField(
                      controller: _textAnswerController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      enabled: !_answered,
                      decoration: InputDecoration(
                        hintText: 'Type your answer here...',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.3)),
                        filled: true,
                        fillColor: AppColors.darkSurfaceVariant,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (!_answered)
                      ElevatedButton(
                        onPressed: _submitTextAnswer,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            foregroundColor: Colors.white),
                        child: const Text('Check Answer'),
                      ),
                  ],

                  // Feedback explanation
                  if (_answered) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedAnswer == q.correctIndex
                                ? '✓ Correct!'
                                : '✗ Incorrect (Answer: ${q.correctAnswer})',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _selectedAnswer == q.correctIndex
                                    ? AppColors.teal
                                    : AppColors.error),
                          ),
                          const SizedBox(height: 4),
                          Text(q.explanation,
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12.5,
                                  color: Colors.white.withOpacity(0.75),
                                  height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Bar
          if (_answered)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  border: Border(
                      top: BorderSide(
                          color: AppColors.darkBorder.withOpacity(0.5)))),
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricViolet,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: Text(_currentIndex < _questions.length - 1
                    ? 'Next Question →'
                    : 'View Results'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, QuizType type) {
    final sel = _quizType == type;
    return ChoiceChip(
      label: Text(label,
          style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.5,
              color: sel ? Colors.white : Colors.white70)),
      selected: sel,
      selectedColor: AppColors.electricViolet,
      backgroundColor: AppColors.darkSurfaceVariant,
      onSelected: (_) => setState(() => _quizType = type),
    );
  }
}
