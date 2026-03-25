import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/chat_message.dart';
import '../services/ai_model_manager.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/disclaimer_dialog.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final _manager = AIModelManager();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  List<ChatMessage> _messages = [];
  bool _isTyping = false;

  static const _suggestions = [
    '❓ What is the meaning of Ayatul Kursi?',
    '📖 Explain the 5 pillars of Islam',
    '🤲 What does Islam say about patience (Sabr)?',
    '🔢 How many times is "Allah" mentioned in the Quran?',
  ];

  @override
  void initState() {
    super.initState();
    _checkDisclaimer();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _checkDisclaimer() async {
    final accepted = await DisclaimerDialog.wasAccepted();
    if (!accepted && mounted) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => DisclaimerDialog(onAccepted: () {}),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isTyping) return;

    HapticFeedback.selectionClick();
    _textController.clear();
    _focusNode.unfocus();

    setState(() {
      _messages = List.from(_manager.history)
        ..add(ChatMessage(
          text: trimmed,
          role: MessageRole.user,
          timestamp: DateTime.now(),
        ));
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      await _manager.sendMessage(trimmed);
      if (mounted) {
        setState(() {
          _messages = List.from(_manager.history);
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } on AllModelsExhaustedException {
      if (mounted) {
        _appendErrorMessage(
          'All AI services are temporarily busy. Please try again in a moment.\n\n'
          '⚠️ AI can make mistakes. Please double-check all information from trusted Islamic sources or a qualified scholar.',
          'Unavailable',
        );
      }
    } catch (_) {
      if (mounted) {
        _appendErrorMessage(
          'Something went wrong. Please check your internet connection and try again.\n\n'
          '⚠️ AI can make mistakes. Please double-check all information from trusted Islamic sources or a qualified scholar.',
          'Error',
        );
      }
    }
  }

  void _appendErrorMessage(String text, String modelLabel) {
    setState(() {
      _messages = List.from(_manager.history)
        ..add(ChatMessage(
          text: text,
          role: MessageRole.assistant,
          modelUsed: modelLabel,
          timestamp: DateTime.now(),
        ));
      _isTyping = false;
    });
    _scrollToBottom();
  }

  Widget _buildEmptyState(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor,
                    theme.primaryColor.withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text('☪',
                    style: TextStyle(fontSize: 42, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Islamic AI Assistant',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask anything about Quran, Hadith, Fiqh,\nor general Islamic knowledge.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color:
                    isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Quick Questions',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color:
                    isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: _suggestions.map((s) {
                return GestureDetector(
                  onTap: () => _sendMessage(s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E2A3A)
                          : theme.primaryColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.primaryColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.grey.shade300
                            : const Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final inputBg =
        isDark ? const Color(0xFF1E2A3A) : const Color(0xFFF5F5F5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.15),
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.newline,
                  style: TextStyle(
                    fontSize: 14.5,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask about Quran, Islam...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade400,
                      fontSize: 14.5,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: _isTyping ? null : _sendMessage,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isTyping
                  ? null
                  : () => _sendMessage(_textController.text),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: _isTyping
                      ? null
                      : LinearGradient(
                          colors: [
                            theme.primaryColor,
                            theme.primaryColor.withValues(alpha: 0.75),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  color: _isTyping ? Colors.grey.shade300 : null,
                  shape: BoxShape.circle,
                  boxShadow: _isTyping
                      ? null
                      : [
                          BoxShadow(
                            color: theme.primaryColor.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: _isTyping ? Colors.grey.shade500 : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D1621) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome,
                color: theme.primaryColor, size: 18),
            const SizedBox(width: 8),
            Text(
              'Islamic AI Assistant',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color:
                    isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: isDark
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
            ),
            onPressed: _messages.isEmpty
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Clear Chat'),
                        content: const Text(
                            'Are you sure you want to clear the conversation?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              _manager.clearHistory();
                              setState(() => _messages = []);
                              Navigator.pop(ctx);
                            },
                            child: const Text('Clear',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
            tooltip: 'Clear chat',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(
            height: 0.5,
            color: theme.primaryColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty && !_isTyping
                ? _buildEmptyState(theme)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (_isTyping && i == _messages.length) {
                        return const TypingIndicator();
                      }
                      return ChatBubble(message: _messages[i]);
                    },
                  ),
          ),
          _buildInputBar(theme),
        ],
      ),
    );
  }
}
