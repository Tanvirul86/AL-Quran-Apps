/// Roles in a chat conversation
enum MessageRole { user, assistant }

/// A single chat message in the AI Assistant conversation
class ChatMessage {
  final String text;
  final MessageRole role;
  final String? modelUsed; // e.g. "Gemini 1.5 Flash"
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.role,
    this.modelUsed,
    required this.timestamp,
  });
}
