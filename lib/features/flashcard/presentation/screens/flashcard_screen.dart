import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class FlashcardScreen extends ConsumerStatefulWidget {
  final String topicId;
  const FlashcardScreen({super.key, required this.topicId});

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  int _currentIndex = 0;
  bool _isFlipped = false;
  int _easyCount = 0;
  int _hardCount = 0;
  int _againCount = 0;

  static const _defaultCards = [
    _Flashcard(
      front: 'What is a Semaphore?',
      back:
          'A semaphore is a synchronization primitive used to control access to shared resources. It\'s an integer variable that can only be accessed through two atomic operations:\n\n• **wait (P)**: Decrements the semaphore value\n• **signal (V)**: Increments the semaphore value\n\nUsed to prevent race conditions in concurrent programming.',
    ),
    _Flashcard(
      front: 'Explain Deadlock and its four conditions',
      back:
          'Deadlock occurs when two or more processes are waiting for each other indefinitely.\n\n**Four Necessary Conditions (Coffman\'s):**\n1. **Mutual Exclusion** — Resource held exclusively\n2. **Hold & Wait** — Process holds one resource, waits for others\n3. **No Preemption** — Resources cannot be forcefully taken\n4. **Circular Wait** — Circular chain of waiting processes',
    ),
    _Flashcard(
      front: 'What is Thrashing?',
      back:
          'Thrashing occurs when a process spends more time in paging (swapping pages) than executing actual instructions.\n\n**Cause:** Too many processes compete for limited memory frames, causing continuous page faults.\n\n**Solution:** Working Set Model — allocate frames based on the process\'s actual working set size.',
    ),
    _Flashcard(
      front: 'Difference between Process and Thread?',
      back:
          '**Process:**\n• Independent execution unit\n• Separate memory space\n• Heavyweight — context switch is expensive\n• Communication via IPC\n\n**Thread:**\n• Lightweight subprocess within a process\n• Shares memory with parent process\n• Faster context switch\n• Communication via shared memory',
    ),
  ];

  List<_Flashcard> get _cards {
    final doc = ref.watch(activeDocumentProvider);
    if (doc != null && doc.flashcards.isNotEmpty) {
      return doc.flashcards.map((f) => _Flashcard(
        front: f.front,
        back: f.back,
      )).toList();
    }
    return _defaultCards;
  }

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _rate(String rating) {
    if (rating == 'easy') _easyCount++;
    if (rating == 'hard') _hardCount++;
    if (rating == 'again') _againCount++;

    // Increment flashcards reviewed in Firestore
    final user = ref.read(currentUserProvider);
    final firestoreService = ref.read(firestoreServiceProvider);
    final uid = user?.id ?? firestoreService.currentUserId;
    if (uid != null && uid.isNotEmpty) {
      firestoreService.incrementFlashcardsReviewed(uid);
    }

    if (_currentIndex < _cards.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
        _flipController.reset();
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Session Complete! 🎉', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ResultRow(label: '✅ Easy', count: _easyCount, color: AppColors.teal),
            const SizedBox(height: 8),
            _ResultRow(label: '⚡ Hard', count: _hardCount, color: AppColors.amber),
            const SizedBox(height: 8),
            _ResultRow(label: '🔁 Again', count: _againCount, color: AppColors.error),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Done', style: TextStyle(color: AppColors.electricViolet))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentIndex + 1) / _cards.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Flashcards', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('${_currentIndex + 1}/${_cards.length}',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkTextSecondary)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.darkBorder,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.electricViolet),
            minHeight: 3,
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MiniStat(label: 'Easy', count: _easyCount, color: AppColors.teal),
                      const SizedBox(width: 16),
                      _MiniStat(label: 'Hard', count: _hardCount, color: AppColors.amber),
                      const SizedBox(width: 16),
                      _MiniStat(label: 'Again', count: _againCount, color: AppColors.error),
                    ],
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 24),

                  // 3D Flip Card
                  Expanded(
                    child: GestureDetector(
                      onTap: _flipCard,
                      child: AnimatedBuilder(
                        animation: _flipAnimation,
                        builder: (_, __) {
                          final angle = _flipAnimation.value * pi;
                          final isFrontVisible = angle < pi / 2;

                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(angle),
                            child: isFrontVisible
                                ? _CardFace(
                                    text: _cards[_currentIndex].front,
                                    isFront: true,
                                    label: 'TAP TO REVEAL ANSWER',
                                  )
                                : Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()..rotateY(pi),
                                    child: _CardFace(
                                      text: _cards[_currentIndex].back,
                                      isFront: false,
                                      label: 'TAP TO FLIP BACK',
                                    ),
                                  ),
                          );
                        },
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                  ),

                  const SizedBox(height: 24),

                  // Rating buttons — only visible after flip
                  if (_isFlipped) ...[
                    Text(
                      'How well did you know this?',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withOpacity(0.5)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _RatingButton(label: '🔁 Again', color: AppColors.error, onTap: () => _rate('again')),
                        const SizedBox(width: 10),
                        _RatingButton(label: '⚡ Hard', color: AppColors.amber, onTap: () => _rate('hard')),
                        const SizedBox(width: 10),
                        _RatingButton(label: '✅ Easy', color: AppColors.teal, onTap: () => _rate('easy')),
                      ],
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
                  ] else ...[
                    Text(
                      'Tap the card to reveal the answer',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withOpacity(0.4)),
                    ).animate().fadeIn(duration: 300.ms),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final String text;
  final bool isFront;
  final String label;

  const _CardFace({required this.text, required this.isFront, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isFront
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E1535), Color(0xFF251D45)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F2D27), Color(0xFF162E2A)],
              ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isFront
              ? AppColors.electricViolet.withOpacity(0.3)
              : AppColors.teal.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isFront ? AppColors.electricViolet : AppColors.teal).withOpacity(0.1),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (isFront ? AppColors.electricViolet : AppColors.teal).withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isFront ? 'QUESTION' : 'ANSWER',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: isFront ? AppColors.electricViolet : AppColors.teal,
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 56),
              child: SingleChildScrollView(
                child: Text(
                  text,
                  textAlign: isFront ? TextAlign.center : TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: isFront ? 18 : 14,
                    fontWeight: isFront ? FontWeight.w600 : FontWeight.w400,
                    color: Colors.white,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                letterSpacing: 1,
                color: Colors.white.withOpacity(0.25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _RatingButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: color),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _MiniStat({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$count $label', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white.withOpacity(0.5))),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _ResultRow({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white.withOpacity(0.7))),
        Text('$count cards', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}

class _Flashcard {
  final String front;
  final String back;
  const _Flashcard({required this.front, required this.back});
}
