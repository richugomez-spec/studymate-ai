import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ai/engines/ai_engine_providers.dart';
import '../../../../core/services/document_processing_service.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String topicId;
  const QuizScreen({super.key, required this.topicId});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _score = 0;
  bool _quizComplete = false;
  // ignore: unused_field
  bool _isSavingToBrain = false;

  static const _defaultQuestions = [
    _QuizQuestion(
      question: 'Which scheduling algorithm gives the shortest average waiting time for a given set of processes?',
      options: ['FCFS', 'Round Robin', 'SJF (Shortest Job First)', 'Priority Scheduling'],
      correctIndex: 2,
      explanation: 'SJF minimizes the average waiting time by always selecting the process with the shortest burst time next. This is optimal but requires knowing burst times in advance.',
    ),
    _QuizQuestion(
      question: 'What does the term "Convoy Effect" refer to in OS scheduling?',
      options: [
        'Multiple short processes waiting behind one long process',
        'Processes forming a convoy to share CPU',
        'CPU scheduling based on process priority',
        'Memory fragmentation pattern',
      ],
      correctIndex: 0,
      explanation: 'The Convoy Effect occurs in FCFS scheduling when multiple short processes are stuck waiting behind one long CPU-bound process, leading to poor CPU and I/O utilization.',
    ),
    _QuizQuestion(
      question: 'In Round Robin scheduling, what happens when a process does not complete within its time quantum?',
      options: [
        'It is terminated',
        'It gets highest priority in next cycle',
        'It is preempted and moved to end of ready queue',
        'Its priority is reduced',
      ],
      correctIndex: 2,
      explanation: 'In Round Robin, when a process exhausts its time quantum without completing, the CPU is preempted and the process is placed at the back of the ready queue to wait for its next turn.',
    ),
  ];

  List<_QuizQuestion> get _questions {
    final doc = ref.read(activeDocumentProvider);
    if (doc != null && doc.quizzes.isNotEmpty) {
      return doc.quizzes.map((q) => _QuizQuestion(
        question: q.question,
        options: q.options,
        correctIndex: q.correctIndex,
        explanation: q.explanation,
      )).toList();
    }
    return _defaultQuestions;
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (index == _questions[_currentIndex].correctIndex) {
        _score++;
      }
    });
  }

  Future<void> _nextQuestion() async {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      setState(() => _isSavingToBrain = true);
      // Record completion locally
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        setState(() {
          _isSavingToBrain = false;
          _quizComplete = true;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final activeDoc = ref.watch(activeDocumentProvider);
    final questions = _questions;

    if (_quizComplete) return _QuizResultScreen(score: _score, total: questions.length);

    final question = questions[_currentIndex.clamp(0, questions.length - 1)];
    final progress = (_currentIndex + 1) / questions.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(activeDoc != null ? 'Quiz: ${activeDoc.fileName}' : 'Quiz', style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 15), overflow: TextOverflow.ellipsis),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentIndex + 1} / ${_questions.length}',
                style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkTextSecondary),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.darkBorder,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.electricViolet),
            minHeight: 3,
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Score badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.teal.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: AppColors.teal),
                          const SizedBox(width: 4),
                          Text('$_score correct', style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.teal)),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 24),

                // Question card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: Text(
                    question.question,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 20),

                // Answer options
                ...question.options.asMap().entries.map((e) {
                  final i = e.key;
                  final isCorrect = i == question.correctIndex;
                  final isSelected = i == _selectedAnswer;

                  Color borderColor = AppColors.darkBorder;
                  Color bgColor = AppColors.darkSurface;
                  Color textColor = Colors.white;
                  Widget? trailingIcon;

                  if (_answered) {
                    if (isCorrect) {
                      borderColor = AppColors.teal;
                      bgColor = AppColors.teal.withOpacity(0.08);
                      trailingIcon = const Icon(Icons.check_circle_rounded, color: AppColors.teal, size: 20);
                    } else if (isSelected && !isCorrect) {
                      borderColor = AppColors.error;
                      bgColor = AppColors.error.withOpacity(0.08);
                      textColor = AppColors.error;
                      trailingIcon = const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20);
                    }
                  } else if (isSelected) {
                    borderColor = AppColors.electricViolet;
                    bgColor = AppColors.electricViolet.withOpacity(0.08);
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => _selectAnswer(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: (_answered && isCorrect)
                                    ? AppColors.teal.withOpacity(0.15)
                                    : (_answered && isSelected && !isCorrect)
                                        ? AppColors.error.withOpacity(0.15)
                                        : AppColors.darkSurfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  ['A', 'B', 'C', 'D'][i],
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _answered && isCorrect
                                        ? AppColors.teal
                                        : _answered && isSelected && !isCorrect
                                            ? AppColors.error
                                            : Colors.white.withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                e.value,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: textColor,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            if (trailingIcon != null) ...[
                              const SizedBox(width: 8),
                              trailingIcon,
                            ],
                          ],
                        ),
                      ).animate(delay: Duration(milliseconds: i * 60)).fadeIn().slideX(begin: 0.05, end: 0),
                    ),
                  );
                }),

                // Explanation (shown after answering)
                if (_answered) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.skyBlue.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.skyBlue.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppColors.skyBlue),
                            const SizedBox(width: 6),
                            const Text('Explanation', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.skyBlue)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          question.explanation,
                          style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withOpacity(0.75), height: 1.5),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),

          // Next button
          if (_answered)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: AppColors.electricViolet.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))],
                  ),
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      _currentIndex < _questions.length - 1 ? 'Next Question →' : 'See Results',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0),
            ),
        ],
      ),
    );
  }
}

// ── Result Screen ──────────────────────────────────────────────────────────────

class _QuizResultScreen extends StatelessWidget {
  final int score;
  final int total;

  const _QuizResultScreen({required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    final percent = (score / total * 100).round();
    final color = percent >= 80 ? AppColors.teal : percent >= 60 ? AppColors.amber : AppColors.error;
    final emoji = percent >= 80 ? '🎉' : percent >= 60 ? '💪' : '📚';
    final message = percent >= 80 ? 'Excellent work!' : percent >= 60 ? 'Good effort!' : 'Keep practising!';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 64))
                  .animate().scale(duration: 600.ms, curve: Curves.elasticOut),

              const SizedBox(height: 24),

              Text('$percent%', style: TextStyle(fontFamily: 'Inter', fontSize: 64, fontWeight: FontWeight.w800, color: color))
                  .animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),

              Text(message, style: const TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white))
                  .animate(delay: 300.ms).fadeIn(),

              const SizedBox(height: 8),

              Text('$score out of $total correct', style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: Colors.white.withOpacity(0.5)))
                  .animate(delay: 400.ms).fadeIn(),

              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const _QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}
