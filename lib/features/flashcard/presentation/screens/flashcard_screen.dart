import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ai/services/knowledge_engine.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../services/firestore_service.dart';

class _StudyFlashcard {
  final String front;
  final String back;

  const _StudyFlashcard({required this.front, required this.back});
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
  final List<_StudyFlashcard> _cards = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _generationFailed = false;
  bool _refreshFailed = false;
  bool _refreshAfterGeneration = false;

  // Reactive sync: debounce timer for library-change triggered reload.
  Timer? _libraryChangeDebounce;
  String? _lastLibraryVersion;

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

  @override
  void dispose() {
    _libraryChangeDebounce?.cancel();
    _flipController.dispose();
    super.dispose();
  }

  Future<void> _loadCards({bool forceRefresh = false}) async {
    if (_isRefreshing) {
      _refreshAfterGeneration = true;
      return;
    }
    if (mounted) {
      setState(() {
        _isLoading = _cards.isEmpty;
        _isRefreshing = true;
        _generationFailed = false;
        _refreshFailed = false;
      });
    }
    try {
      final result = await ref.read(knowledgeEngineProvider).generateFlashcards(
          topicId: widget.topicId,
          subjectId: ref.read(activeKnowledgeSubjectIdProvider) ??
              ref.read(activeKnowledgeWorkspaceIdProvider),
          sourceIds: ref.read(selectedKnowledgeSourceIdsProvider),
          forceRefresh: forceRefresh,
          prompt:
              'Create useful active recall cards. Return cards as a list of objects with a concise front question and a correct, clear back answer.');
      final generated = result['cards'];
      final nextCards = <_StudyFlashcard>[];
      if (generated is List) {
        for (int i = 0; i < generated.length; i++) {
          if (generated[i] is! Map) continue;
          final card = Map<String, dynamic>.from(generated[i] as Map);
          final front =
              (card['front'] ?? card['question'] ?? '').toString().trim();
          final back = (card['back'] ?? card['answer'] ?? '').toString().trim();
          if (front.isEmpty || back.isEmpty) continue;
          nextCards.add(_StudyFlashcard(
            front: front,
            back: back,
          ));
        }
      }
      if (nextCards.isEmpty) {
        if (_cards.isEmpty) _generationFailed = true;
        if (_cards.isNotEmpty) _refreshFailed = true;
        return;
      }
      if (mounted) {
        _flipController.reset();
        setState(() {
          _cards
            ..clear()
            ..addAll(nextCards);
          _currentIndex = 0;
          _isFlipped = false;
          _generationFailed = false;
          _refreshFailed = false;
        });
      }
    } catch (error) {
      debugPrint('Flashcard generation did not complete after failover.');
      if (_cards.isEmpty) _generationFailed = true;
      if (_cards.isNotEmpty) _refreshFailed = true;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
        if (_refreshAfterGeneration) {
          _refreshAfterGeneration = false;
          _loadCards(forceRefresh: true);
        }
      }
    }
  }

  void _flipCard() {
    if (_isRefreshing) return;
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _showCard(int index) {
    if (_isRefreshing ||
        index < 0 ||
        index >= _cards.length ||
        index == _currentIndex) {
      return;
    }
    if (_isFlipped) {
      _flipController.reverse();
    }
    setState(() {
      _isFlipped = false;
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(activeKnowledgeSubjectNameSyncProvider);
    final subjectName = ref.watch(activeKnowledgeSubjectNameProvider);
    final activeSubjectId = ref.watch(activeKnowledgeSubjectIdProvider) ??
        ref.watch(activeKnowledgeWorkspaceIdProvider) ??
        '';

    // ── Reactive library sync ─────────────────────────────────────────────
    // Listen to Firestore topic/note changes and re-generate if the library
    // version changes. Debounced 600 ms to avoid rapid successive reloads.
    ref.listen<AsyncValue<String>>(
      subjectTopicsVersionProvider(activeSubjectId),
      (_, next) {
        final version = next.valueOrNull;
        if (version == null || version.isEmpty) return;
        if (_lastLibraryVersion == null) {
          // First emission — just record the baseline; don't reload.
          _lastLibraryVersion = version;
          return;
        }
        if (version == _lastLibraryVersion) return;
        _lastLibraryVersion = version;
        // Library changed — debounce then reload cards from scratch.
        _libraryChangeDebounce?.cancel();
        _libraryChangeDebounce = Timer(const Duration(milliseconds: 600), () {
          if (mounted) {
            _loadCards(forceRefresh: true);
          }
        });
      },
    );

    if (_isLoading && _cards.isEmpty) {
      return const Scaffold(body: Center(child: Text('Thinking...')));
    }
    if (_generationFailed) {
      return Scaffold(
        appBar: AppBar(
            title: Text(
                '${subjectName == null ? '' : '$subjectName · '}Flashcards')),
        body: Center(
          child: TextButton(
            onPressed: () => _loadCards(forceRefresh: true),
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
                '${subjectName == null ? '' : '$subjectName · '}Flashcards',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 16))),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                  'Flashcards could not be prepared from this subject hierarchy. Try generating them again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Colors.white60,
                      height: 1.4),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _loadCards(forceRefresh: true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricViolet,
                      foregroundColor: Colors.white),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final card = _cards[_currentIndex];
    final completion =
        _cards.length <= 1 ? 0.0 : _currentIndex / (_cards.length - 1);
    final estimatedMinutes = (_cards.length * 0.5).ceil();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('${subjectName == null ? '' : '$subjectName · '}Flashcards',
            style: const TextStyle(
                fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 15),
            overflow: TextOverflow.ellipsis),
        actions: [
          TextButton.icon(
            onPressed:
                _isRefreshing ? null : () => _loadCards(forceRefresh: true),
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: Text(_isRefreshing
                ? 'Updating...'
                : _cards.isEmpty
                    ? 'Generate Flashcards'
                    : 'Regenerate Flashcards'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isRefreshing) const LinearProgressIndicator(minHeight: 2),
          LinearProgressIndicator(
            value: completion,
            backgroundColor: Colors.white.withOpacity(0.06),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
            minHeight: 3,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.horizontalPadding(context),
              vertical: 10,
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 4,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Text('${_cards.length} Flashcards',
                    style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
                Text('~$estimatedMinutes min review',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
                Text('${(completion * 100).round()}% complete',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('Updating study tools...'),
            ),
          if (_refreshFailed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextButton.icon(
                onPressed:
                    _isRefreshing ? null : () => _loadCards(forceRefresh: true),
                icon: const Icon(Icons.warning_amber_rounded, size: 17),
                label: const Text(
                    'Could not update; showing previous cards. Try again.'),
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.horizontalPadding(context),
              vertical: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: !_isRefreshing && _currentIndex > 0
                      ? () => _showCard(_currentIndex - 1)
                      : null,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Prev'),
                ),
                Text('Card ${_currentIndex + 1} / ${_cards.length}',
                    style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                TextButton.icon(
                  onPressed: !_isRefreshing && _currentIndex < _cards.length - 1
                      ? () => _showCard(_currentIndex + 1)
                      : null,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Next'),
                ),
              ],
            ),
          ),

          // ── Flippable 3D Card ─────────────────────────────────────────────
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, boxConstraints) {
                  final hPad = Responsive.horizontalPadding(context);
                  final maxW = (boxConstraints.maxWidth - hPad * 2).clamp(200.0, 520.0);
                  final maxH = (boxConstraints.maxHeight * 0.85).clamp(180.0, 360.0);
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: GestureDetector(
                      key: ValueKey<int>(_currentIndex),
                      onTap: _isRefreshing ? null : _flipCard,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
                        margin: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
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
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFront(_StudyFlashcard card) {
    final fontSize = Responsive.titleFont(context);
    return Container(
      padding: EdgeInsets.all(Responsive.cardPadding(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('QUESTION',
              style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.teal,
                  letterSpacing: 0.8)),
          const Spacer(),
          Text(card.front,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: fontSize,
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

  Widget _buildCardBack(_StudyFlashcard card) {
    final fontSize = Responsive.titleFont(context);
    return Container(
      padding: EdgeInsets.all(Responsive.cardPadding(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.electricViolet.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('ANSWER',
              style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.electricVioletLight,
                  letterSpacing: 0.8)),
          const Spacer(),
          Text(card.back,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.45)),
          const Spacer(),
          Text('Use Prev and Next to continue reviewing',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.35))),
        ],
      ),
    );
  }
}
