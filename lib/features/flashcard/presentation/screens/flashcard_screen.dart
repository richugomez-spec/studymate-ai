import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/ai/services/knowledge_engine.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../services/firestore_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class _SRSFlashcard {
  final String id;
  final String front;
  final String back;
  final String difficulty; // 'Easy' | 'Medium' | 'Hard'
  double intervalDays;
  double easeFactor;
  int repetitionCount;

  _SRSFlashcard({
    required this.id,
    required this.front,
    required this.back,
    this.difficulty = 'Medium',
    this.intervalDays = 1.0,
    this.easeFactor = 2.5,
    this.repetitionCount = 0,
  });
}

class FlashcardScreen extends ConsumerStatefulWidget {
  final String? topicId;
  const FlashcardScreen({super.key, this.topicId});

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  int _currentIndex = 0;
  bool _isFlipped = false;
  final List<_SRSFlashcard> _cards = [];
  bool _sessionComplete = false;
  bool _isLoading = true;
  bool _generationFailed = false;
  bool _hasRequestedCards = false;

  int _againCount = 0;
  int _hardCount = 0;
  int _goodCount = 0;
  int _easyCount = 0;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _loadCards();
  }

  Future<void> _loadCards() async {
    _hasRequestedCards = true;
    if (mounted) {
      setState(() {
        _isLoading = true;
        _generationFailed = false;
      });
    }
    try {
      final result = await ref.read(knowledgeEngineProvider).generateFlashcards(
          topicId: widget.topicId,
          subjectId: ref.read(activeKnowledgeSubjectIdProvider) ??
              ref.read(activeKnowledgeWorkspaceIdProvider),
          prompt:
              'Create useful active recall cards. Return cards as a list of objects with a concise front question and a correct, clear back answer.');
      final generated = result['cards'];
      _cards.clear();
      if (generated is List) {
        for (int i = 0; i < generated.length; i++) {
          if (generated[i] is! Map) continue;
          final card = Map<String, dynamic>.from(generated[i] as Map);
          final front =
              (card['front'] ?? card['question'] ?? '').toString().trim();
          final back = (card['back'] ?? card['answer'] ?? '').toString().trim();
          if (front.isEmpty || back.isEmpty) continue;
          _cards.add(_SRSFlashcard(
            id: '$i',
            front: front,
            back: back,
          ));
        }
      }
      if (_cards.isEmpty) _generationFailed = true;
    } catch (_) {
      debugPrint('Flashcard generation did not complete after failover.');
      _generationFailed = true;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

  /// SM-2 Spaced Repetition calculation
  void _rateCard(int quality) {
    if (_cards.isEmpty || _currentIndex >= _cards.length) return;
    final card = _cards[_currentIndex];

    // SM-2 Algorithm Implementation
    // quality: 0 (Again), 3 (Hard), 4 (Good), 5 (Easy)
    if (quality == 0) _againCount++;
    if (quality == 3) _hardCount++;
    if (quality == 4) _goodCount++;
    if (quality == 5) _easyCount++;

    if (quality < 3) {
      card.repetitionCount = 0;
      card.intervalDays = 1.0;
    } else {
      if (card.repetitionCount == 0) {
        card.intervalDays = 1.0;
      } else if (card.repetitionCount == 1) {
        card.intervalDays = 6.0;
      } else {
        card.intervalDays =
            (card.intervalDays * card.easeFactor).roundToDouble();
      }
      card.repetitionCount++;
    }

    // Update ease factor: EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
    card.easeFactor = max(
        1.3,
        card.easeFactor +
            (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02)));

    // Increment user study progress in Firestore
    final user = ref.read(currentUserProvider);
    final firestoreService = ref.read(firestoreServiceProvider);
    final uid = user?.id ?? firestoreService.currentUserId;
    if (uid != null && uid.isNotEmpty) {
      firestoreService.incrementFlashcardsReviewed(uid, count: 1);
    }

    if (_isFlipped) {
      _flipController.reverse();
      _isFlipped = false;
    }

    if (_currentIndex < _cards.length - 1) {
      setState(() => _currentIndex++);
    } else {
      setState(() => _sessionComplete = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectName = ref.watch(activeKnowledgeSubjectNameProvider);
    if (!_hasRequestedCards) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasRequestedCards) _loadCards();
      });
    }

    if (_isLoading) {
      return const Scaffold(body: Center(child: Text('Thinking...')));
    }
    if (_generationFailed) {
      return Scaffold(
        appBar: AppBar(
            title: Text(
                '${subjectName == null ? '' : '$subjectName · '}SRS Flashcards')),
        body: Center(
          child: TextButton(
            onPressed: _loadCards,
            child: const Text('Please try again.'),
          ),
        ),
      );
    }

    if (_cards.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
            title: Text(
                '${subjectName == null ? '' : '$subjectName · '}SRS Flashcards',
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
                const Icon(Icons.flip_to_front_rounded,
                    size: 40, color: AppColors.teal),
                const SizedBox(height: 12),
                const Text('No Flashcards Available',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                  'Add notes or materials to generate active-recall flashcards.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Colors.white60,
                      height: 1.4),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => context.go(AppRoutes.library),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricViolet,
                      foregroundColor: Colors.white),
                  icon: const Icon(Icons.upload_file_rounded, size: 16),
                  label: const Text('Add study materials'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_sessionComplete) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
            title: Text(
                '${subjectName == null ? '' : '$subjectName · '}Review Complete',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 16))),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.darkBorderSubtle),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded,
                    size: 52, color: AppColors.teal),
                const SizedBox(height: 16),
                const Text('Cards Mastered Today!',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                    'SM-2 Spaced Repetition has calculated your next review intervals.',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.white60)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatBadge(
                        label: 'Again',
                        count: _againCount,
                        color: AppColors.error),
                    _StatBadge(
                        label: 'Hard',
                        count: _hardCount,
                        color: AppColors.amber),
                    _StatBadge(
                        label: 'Good',
                        count: _goodCount,
                        color: AppColors.skyBlue),
                    _StatBadge(
                        label: 'Easy',
                        count: _easyCount,
                        color: AppColors.teal),
                  ],
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 0;
                      _sessionComplete = false;
                      _againCount = 0;
                      _hardCount = 0;
                      _goodCount = 0;
                      _easyCount = 0;
                    });
                  },
                  icon: const Icon(Icons.replay_rounded, size: 16),
                  label: const Text('Review Again'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricViolet,
                      foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final card = _cards[_currentIndex];
    final progress = (_currentIndex + 1) / _cards.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
            '${subjectName == null ? '' : '$subjectName · '}SRS Flashcards',
            style: const TextStyle(
                fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 15),
            overflow: TextOverflow.ellipsis),
      ),
      body: Column(
        children: [
          // Linear Progress Indicator
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.06),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
            minHeight: 3,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Card ${_currentIndex + 1} of ${_cards.length}',
                    style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 11,
                        color: AppColors.darkTextSecondary)),
              ],
            ),
          ),

          // ── Flippable 3D Card ─────────────────────────────────────────────
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: _flipCard,
                child: Container(
                  constraints:
                      const BoxConstraints(maxWidth: 520, maxHeight: 360),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, child) {
                      final isUnder = (_flipAnimation.value > 0.5);
                      final angle = _flipAnimation.value * pi;

                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0012)
                          ..rotateY(angle),
                        child: isUnder
                            ? Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(pi),
                                child: _buildCardBack(card),
                              )
                            : _buildCardFront(card),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // ── SM-2 Rating Bar ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              border: Border(
                  top:
                      BorderSide(color: AppColors.darkBorder.withOpacity(0.5))),
            ),
            child: Row(
              children: [
                _buildRatingButton('Again', 0, AppColors.error),
                const SizedBox(width: 8),
                _buildRatingButton('Hard', 3, AppColors.amber),
                const SizedBox(width: 8),
                _buildRatingButton('Good', 4, AppColors.skyBlue),
                const SizedBox(width: 8),
                _buildRatingButton('Easy', 5, AppColors.teal),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFront(_SRSFlashcard card) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('QUESTION',
                  style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.teal,
                      letterSpacing: 0.8)),
              Text('Difficulty: ${card.difficulty}',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Colors.white38)),
            ],
          ),
          const Spacer(),
          Text(card.front,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.4)),
          const Spacer(),
          Text('Tap card to reveal answer',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.35))),
        ],
      ),
    );
  }

  Widget _buildCardBack(_SRSFlashcard card) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.electricViolet.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ANSWER',
                  style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.electricVioletLight,
                      letterSpacing: 0.8)),
              Text('Next: ${card.intervalDays.toStringAsFixed(0)}d',
                  style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 11,
                      color: AppColors.teal)),
            ],
          ),
          const Spacer(),
          Text(card.back,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.45)),
          const Spacer(),
          Text('Rate your recall below to schedule next review',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.35))),
        ],
      ),
    );
  }

  Widget _buildRatingButton(String label, int quality, Color color) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () => _rateCard(quality),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withOpacity(0.5)),
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatBadge(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$count',
            style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                fontFamily: 'Inter', fontSize: 11, color: Colors.white60)),
      ],
    );
  }
}
