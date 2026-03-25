import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  bool _isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isUser = message.role == MessageRole.user;

    final textIsArabic = _isArabic(message.text);
    final textDirection =
        textIsArabic ? TextDirection.rtl : TextDirection.ltr;

    final userBubbleColor = theme.primaryColor;
    final aiBubbleColor =
        isDark ? const Color(0xFF1E2A3A) : const Color(0xFFF0F4F7);
    const userTextColor = Colors.white;
    final aiTextColor =
        isDark ? Colors.white : const Color(0xFF1A1A2E);

    // Split disclaimer for separate styling
    final fullText = message.text;
    const disclaimerPrefix = '⚠️ AI can make mistakes.';
    String mainText = fullText;
    String disclaimerText = '';

    if (!isUser) {
      final idx = fullText.indexOf(disclaimerPrefix);
      if (idx != -1) {
        mainText = fullText.substring(0, idx).trimRight();
        disclaimerText = fullText.substring(idx);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(right: 8, bottom: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor,
                    theme.primaryColor.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child:
                    Text('☪', style: TextStyle(fontSize: 14, color: Colors.white)),
              ),
            ),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? userBubbleColor : aiBubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Directionality(
                    textDirection: textDirection,
                    child: Text(
                      mainText,
                      style: TextStyle(
                        color: isUser ? userTextColor : aiTextColor,
                        fontSize: textIsArabic ? 17.0 : 14.5,
                        height: 1.5,
                        fontFamily: textIsArabic ? 'Amiri' : null,
                      ),
                    ),
                  ),
                  if (!isUser && disclaimerText.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      disclaimerText,
                      style: TextStyle(
                        color: isDark
                            ? Colors.amber.shade400
                            : Colors.orange.shade700,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (!isUser && message.modelUsed != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'via ${message.modelUsed}',
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade400,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
