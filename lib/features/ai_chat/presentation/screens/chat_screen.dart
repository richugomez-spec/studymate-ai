import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ai/services/real_ai_chat_service.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../core/theme/app_colors.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  final List<RealChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _initializeGreeting();
  }

  void _initializeGreeting() {
    final activeDoc = ref.read(activeDocumentProvider);
    if (activeDoc != null) {
      _messages.add(
        RealChatMessage(
          id: 'msg_init',
          role: 'assistant',
          content:
              '👋 Hello! I have indexed your document **"${activeDoc.fileName}"** (${activeDoc.concepts.length} micro-concepts, ${activeDoc.quizzes.length} quizzes).\n\nWhat would you like to master first? You can ask any question, test your knowledge, or tap one of the Socratic chips below! 🎓',
          timestamp: DateTime.now(),
        ),
      );
    } else {
      _messages.add(
        RealChatMessage(
          id: 'msg_init',
          role: 'assistant',
          content:
              '👋 Hi! I am your **StudyMate AI Learning Coach**.\n\nUpload your lecture slides or notes (PDF, PPTX, TXT) via the paperclip icon above to ask questions directly grounded in your real materials, or configure your Gemini API key for live generative synthesis!',
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  @override
  void dispose() {
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

  Future<void> _sendMessage(String text) async {
    final clean = text.trim();
    if (clean.isEmpty || _isSending) return;

    final userMsg = RealChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      role: 'user',
      content: clean,
      timestamp: DateTime.now(),
    );

    final placeholderMsg = RealChatMessage(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      role: 'assistant',
      content: 'Synthesizing response...',
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

    try {
      final chatService = ref.read(realAIChatServiceProvider);
      final responseText = await chatService.askAI(
        prompt: clean,
        conversationHistory: _messages.where((m) => !m.isThinking).toList(),
      );

      if (mounted) {
        setState(() {
          _messages.removeWhere((m) => m.id == placeholderMsg.id);
          _messages.add(
            RealChatMessage(
              id: placeholderMsg.id,
              role: 'assistant',
              content: responseText,
              timestamp: DateTime.now(),
              isThinking: false,
            ),
          );
          _isSending = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.removeWhere((m) => m.id == placeholderMsg.id);
          _messages.add(
            RealChatMessage(
              id: placeholderMsg.id,
              role: 'assistant',
              content: 'Error communicating with AI: $e',
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

  void _showApiKeyDialog() {
    final currentKey = ref.read(aiApiKeyProvider) ?? '';
    final controller = TextEditingController(text: currentKey);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.vpn_key_rounded, color: AppColors.electricViolet, size: 22),
            SizedBox(width: 10),
            Text('Connect Gemini API Key', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your Google Gemini API key to enable live generative streaming responses with Gemini 1.5 Flash. Keys are free on Google AI Studio.',
              style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white.withOpacity(0.7), height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'AIzaSy...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: AppColors.darkSurfaceVariant,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.key, color: AppColors.electricViolet, size: 18),
              ),
            ),
          ],
        ),
        actions: [
          if (currentKey.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(aiApiKeyProvider.notifier).setApiKey('');
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API Key cleared.')));
              },
              child: const Text('Clear Key', style: TextStyle(color: AppColors.error)),
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(aiApiKeyProvider.notifier).setApiKey(controller.text);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gemini API Key saved! Ready for live streaming.')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.electricViolet),
            child: const Text('Save Key', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeDoc = ref.watch(activeDocumentProvider);
    final apiKey = ref.watch(aiApiKeyProvider);
    final hasKey = apiKey != null && apiKey.isNotEmpty;

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
              child: const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.white),
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
                    activeDoc != null ? '📄 ${activeDoc.fileName}' : 'No document loaded',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: activeDoc != null ? AppColors.teal : Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // API Key status button
          TextButton.icon(
            onPressed: _showApiKeyDialog,
            icon: Icon(
              hasKey ? Icons.check_circle_rounded : Icons.vpn_key_outlined,
              size: 15,
              color: hasKey ? AppColors.teal : AppColors.amber,
            ),
            label: Text(
              hasKey ? 'Gemini Live' : 'Set Key',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hasKey ? AppColors.teal : AppColors.amber,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.upload_file_rounded),
            tooltip: 'Upload material',
            onPressed: () => context.push(AppRoutes.uploadCenter),
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
                  onTap: () => _sendMessage('Can you test my understanding of this material with a challenging exam question?'),
                ),
                const SizedBox(width: 8),
                _PromptChip(
                  icon: '🔗',
                  label: 'Core Prerequisites',
                  onTap: () => _sendMessage('What are the foundational prerequisite concepts I need to understand this?'),
                ),
                const SizedBox(width: 8),
                _PromptChip(
                  icon: '🧪',
                  label: 'Explain with Analogy',
                  onTap: () => _sendMessage('Explain the central mechanism using an intuitive real-world analogy.'),
                ),
                const SizedBox(width: 8),
                _PromptChip(
                  icon: '⚠️',
                  label: 'Exam Traps',
                  onTap: () => _sendMessage('What are the most common misconceptions and pitfalls in exams regarding this topic?'),
                ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _RealMessageBubble(message: _messages[i]),
            ),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              border: Border(top: BorderSide(color: AppColors.darkBorder.withOpacity(0.5))),
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
                      hintText: activeDoc != null ? 'Ask about ${activeDoc.fileName}...' : 'Ask AI coach or upload document...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
                      filled: true,
                      fillColor: AppColors.darkSurfaceVariant,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
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
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: _isSending ? null : () => _sendMessage(_inputController.text),
                  ),
                ),
              ],
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

  const _PromptChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70)),
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

    return Padding(
      padding: EdgeInsets.only(
        bottom: 16,
        left: isUser ? 48 : 0,
        right: isUser ? 0 : 48,
      ),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isUser) ...[
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, size: 10, color: Colors.white),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                isUser ? 'You' : 'StudyMate AI',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isUser ? AppColors.electricViolet : AppColors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUser ? AppColors.electricViolet.withOpacity(0.18) : AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16).copyWith(
                topLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                topRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
              ),
              border: Border.all(
                color: isUser ? AppColors.electricViolet.withOpacity(0.4) : AppColors.darkBorder,
              ),
            ),
            child: message.isThinking
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal)),
                      SizedBox(width: 10),
                      Text('Synthesizing...', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white70)),
                    ],
                  )
                : SelectableText(
                    message.content,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
