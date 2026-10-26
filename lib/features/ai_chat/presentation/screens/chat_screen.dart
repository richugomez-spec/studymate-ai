import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ai/services/real_ai_chat_service.dart';
import '../../../../core/formatting/study_text_formatter.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../services/firestore_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/auth_required_modal.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;
  bool _isLoadingHistory = false;

  final List<RealChatMessage> _messages = [];
  String? _currentSessionId;
  ProviderSubscription<String?>? _subjectSubscription;

  @override
  void initState() {
    super.initState();
    _subjectSubscription = ref.listenManual<String?>(
      activeKnowledgeSubjectIdProvider,
      (previous, next) {
        if (previous == next || !mounted) return;
        _currentSessionId = null;
        setState(_messages.clear);
        _loadPersistedChatHistory();
      },
    );
    _loadPersistedChatHistory();
  }

  /// Automatically restore conversation history from Firestore
  Future<void> _loadPersistedChatHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final user = ref.read(currentUserProvider);
      final ownerId = user?.id ?? firestoreService.currentUserId;
      if (ownerId != null && ownerId.isNotEmpty) {
        final session = await firestoreService.getOrCreateChatSession(
          ownerId: ownerId,
          subjectId: ref.read(activeKnowledgeSubjectIdProvider) ??
              ref.read(activeKnowledgeWorkspaceIdProvider),
        );
        _currentSessionId = session.id;

        // Fetch existing messages from the session
        final messagesStream =
            firestoreService.streamSessionMessages(session.id);
        final initialMessages = await messagesStream.first.timeout(
          const Duration(seconds: 4),
          onTimeout: () => [],
        );

        if (initialMessages.isNotEmpty) {
          if (mounted) {
            setState(() {
              _messages.clear();
              for (final m in initialMessages
                  .where((m) => !_isInternalFallback(m.content))) {
                _messages.add(RealChatMessage(
                  id: m.id,
                  role: m.role,
                  content: m.content,
                  timestamp: m.timestamp,
                  isThinking: false,
                ));
              }
              _isLoadingHistory = false;
            });
            _scrollToBottom();
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Chat history restoration notice: $e');
    }

    if (mounted) {
      setState(() {
        _isLoadingHistory = false;
        if (_messages.isEmpty) {
          _initializeGreeting();
        }
      });
    }
  }

  bool _isInternalFallback(String content) {
    final text = content.toLowerCase();
    return text.contains('local semantic engine') ||
        text.contains('chunk retrieval') ||
        text.contains('vector search') ||
        text.contains('embedding retrieval') ||
        text.contains('gemini api notice');
  }

  void _initializeGreeting() {
    _messages.add(RealChatMessage(
      id: 'msg_init',
      role: 'assistant',
      content: 'Hi! What would you like to learn today?',
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _subjectSubscription?.close();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Progressively streams words to the screen for a smooth ChatGPT typing effect
  Future<void> _streamWords(
      String fullResponse, String placeholderId, DateTime timestamp) async {
    final words = fullResponse.split(' ');
    final buffer = StringBuffer();
    const batchSize = 3;

    for (int i = 0; i < words.length; i += batchSize) {
      if (!mounted) return;
      final chunk = words.skip(i).take(batchSize).join(' ');
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(chunk);

      setState(() {
        final idx = _messages.indexWhere((m) => m.id == placeholderId);
        if (idx != -1) {
          _messages[idx] = RealChatMessage(
            id: placeholderId,
            role: 'assistant',
            content: buffer.toString(),
            timestamp: timestamp,
            isThinking: false,
          );
        }
      });
      _scrollToBottom();
      await Future.delayed(const Duration(milliseconds: 16));
    }
  }

  Future<void> _sendMessage(String text) async {
    final clean = text.trim();
    if (clean.isEmpty || _isSending) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      final signedIn = await AuthRequiredModal.show(
        context,
        title: 'Sign in to chat with AI Coach',
        message:
            'Sign in to access unlimited AI tutoring, document Q&A, and persistent chat sessions across your devices.',
      );
      if (!signedIn) return;
    }

    final userMsg = RealChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      role: 'user',
      content: clean,
      timestamp: DateTime.now(),
    );

    final placeholderMsg = RealChatMessage(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      role: 'assistant',
      content: 'Thinking...',
      timestamp: DateTime.now(),
      isThinking: true,
    );

    setState(() {
      _messages.add(userMsg);
      _messages.add(placeholderMsg);
      _isSending = true;
    });
    _inputController.clear();
    _scrollToBottom();

    // Firestore session persistence helper
    final firestoreService = ref.read(firestoreServiceProvider);
    final user = ref.read(currentUserProvider);
    final ownerId = user?.id ?? firestoreService.currentUserId;
    if (ownerId != null && ownerId.isNotEmpty) {
      try {
        if (_currentSessionId == null) {
          final session = await firestoreService.getOrCreateChatSession(
            ownerId: ownerId,
            subjectId: ref.read(activeKnowledgeSubjectIdProvider) ??
                ref.read(activeKnowledgeWorkspaceIdProvider),
          );
          _currentSessionId = session.id;
        }
        unawaited(firestoreService.saveChatMessage(
          sessionId: _currentSessionId!,
          role: 'user',
          content: clean,
          timestamp: userMsg.timestamp,
        ));
      } catch (e) {
        debugPrint('Firestore chat user message save notice: $e');
      }
    }

    try {
      final chatService = ref.read(realAIChatServiceProvider);
      final responseBuffer = StringBuffer();
      await for (final part in chatService.streamAI(
        prompt:
            'Current subject: ${ref.read(activeKnowledgeSubjectNameProvider) ?? 'Study Workspace'}. '
            '${ref.read(selectedKnowledgeSourceIdsProvider).isEmpty ? 'Use all manual notes in this subject when available.' : 'Use only the selected notes when available.'} '
            'Use the currently opened Subject > Topic > Subtopic hierarchy as the syllabus. Manual notes are optional; expand partial notes and teach from your academic knowledge when notes are absent. Do not ask which material to use.\nQuestion: $clean',
        conversationHistory: _messages.where((m) => !m.isThinking).toList(),
        subjectId: ref.read(activeKnowledgeSubjectIdProvider) ??
            ref.read(activeKnowledgeWorkspaceIdProvider),
        sourceIds: ref.read(selectedKnowledgeSourceIdsProvider),
      )) {
        responseBuffer.write(part);
        if (mounted) {
          setState(() {
            final idx = _messages.indexWhere((m) => m.id == placeholderMsg.id);
            if (idx != -1)
              _messages[idx] = RealChatMessage(
                  id: placeholderMsg.id,
                  role: 'assistant',
                  content: responseBuffer.toString(),
                  timestamp: placeholderMsg.timestamp);
          });
          _scrollToBottom();
        }
      }
      final responseText = responseBuffer.toString().trim();

      final aiTimestamp = DateTime.now();
      if (_currentSessionId != null) {
        try {
          await firestoreService.saveChatMessage(
            sessionId: _currentSessionId!,
            role: 'assistant',
            content: responseText,
            timestamp: aiTimestamp,
          );
        } catch (e) {
          debugPrint('Firestore chat AI message save notice: $e');
        }
      }

      if (mounted) {
        // Stream response smoothly
        await _streamWords(responseText, placeholderMsg.id, aiTimestamp);
        setState(() {
          _isSending = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('AI response did not complete after automatic failover.');
      if (mounted) {
        setState(() {
          _messages.removeWhere((m) => m.id == placeholderMsg.id);
          _messages.add(
            RealChatMessage(
              id: placeholderMsg.id,
              role: 'assistant',
              content: 'Please try again.',
              timestamp: DateTime.now(),
              isThinking: false,
            ),
          );
          _isSending = false;
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectName =
        ref.watch(activeKnowledgeSubjectNameProvider) ?? 'No Subject Selected';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'AI Learning Coach',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subjectName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: subjectName != 'No Subject Selected'
                          ? AppColors.teal
                          : Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open_rounded),
            tooltip: 'Library',
            onPressed: () => context.go(AppRoutes.library),
          ),
        ],
      ),
      body: Column(
        children: [
          // Socratic quick-action chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _PromptChip(
                  icon: '💡',
                  label: 'Test my understanding',
                  onTap: () => _sendMessage(
                      'Can you test my understanding of this material with a challenging exam question?'),
                ),
                const SizedBox(width: 8),
                _PromptChip(
                  icon: '🔗',
                  label: 'Core Prerequisites',
                  onTap: () => _sendMessage(
                      'What are the foundational prerequisite concepts I need to understand this?'),
                ),
                const SizedBox(width: 8),
                _PromptChip(
                  icon: '🧪',
                  label: 'Explain with Analogy',
                  onTap: () => _sendMessage(
                      'Explain the central mechanism using an intuitive real-world analogy.'),
                ),
                const SizedBox(width: 8),
                _PromptChip(
                  icon: '⚠️',
                  label: 'Exam Traps',
                  onTap: () => _sendMessage(
                      'What are the most common misconceptions and pitfalls in exams regarding this topic?'),
                ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: _isLoadingHistory
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.electricViolet),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Restoring conversation...',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) =>
                        _RealMessageBubble(message: _messages[i]),
                  ),
          ),

          // Input Bar
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                border: Border(
                    top:
                        BorderSide(color: AppColors.darkBorder.withOpacity(0.5))),
              ),
              child: Row(
                children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _sendMessage,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Ask AI coach about $subjectName...',
                      hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.3), fontSize: 13),
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
                    onPressed: _isSending
                        ? null
                        : () => _sendMessage(_inputController.text),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
}

class _PromptChip extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _PromptChip(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RealMessageBubble extends StatelessWidget {
  final RealChatMessage message;

  const _RealMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final bubbleInset = (MediaQuery.sizeOf(context).width * 0.14).clamp(20.0, 56.0);

    return Padding(
      padding: EdgeInsets.only(
        bottom: 16,
        left: isUser ? bubbleInset : 0,
        right: isUser ? 0 : bubbleInset,
      ),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isUser) ...[
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.brandAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: AppColors.brandAccent.withOpacity(0.4)),
                  ),
                  child: const Center(
                    child: Icon(Icons.psychology,
                        size: 12, color: AppColors.electricVioletLight),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                isUser ? 'YOU' : 'STUDYMATE AI',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: isUser
                      ? AppColors.electricVioletLight
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUser
                  ? Theme.of(context).colorScheme.surfaceContainerHigh
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isUser
                    ? AppColors.brandAccent.withOpacity(0.35)
                    : AppColors.darkBorder,
                width: 1,
              ),
            ),
            child: message.isThinking
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.brandAccent)),
                      SizedBox(width: 10),
                      Text('Synthesizing...',
                          style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                    ],
                  )
                : MarkdownBody(
                    data: StudyTextFormatter.cleanForMarkdown(message.content),
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.5,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.55,
                      ),
                      h1: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.4,
                      ),
                      h2: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.4,
                      ),
                      h3: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.electricVioletLight,
                        height: 1.4,
                      ),
                      strong: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      listBullet: const TextStyle(
                        color: AppColors.teal,
                        fontSize: 13.5,
                      ),
                      code: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 12,
                        backgroundColor: Colors.transparent,
                        color: AppColors.teal,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      codeblockPadding: const EdgeInsets.all(12),
                      blockquote: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontStyle: FontStyle.italic,
                      ),
                      blockquoteDecoration: const BoxDecoration(
                        border: Border(
                            left: BorderSide(
                                color: AppColors.electricViolet, width: 3)),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
