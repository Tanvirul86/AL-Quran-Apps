import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import 'gemini_service.dart' show RateLimitException, AIServiceException;

const String _systemPrompt = '''
You are an Islamic AI Assistant embedded in an Al Quran application. Your purpose is to help Muslims learn about the Quran, Hadith, Islamic jurisprudence (Fiqh), and general Islamic knowledge.

STRICT RULES YOU MUST FOLLOW:

1. CONFIDENCE RULE: Only provide answers you are highly confident about from established Islamic sources (Quran, Sahih Hadith, consensus of scholars). If you are uncertain about any Islamic ruling, fact, or interpretation, you MUST clearly say: "I am not fully certain about this. Please verify this with a qualified Islamic scholar or trusted Islamic source before acting on it."

2. SOURCE CITATION: When answering, try to mention the source (e.g., "According to Surah Al-Baqarah 2:255..." or "In Sahih Bukhari, it is narrated..."). If you cannot cite a reliable source, state that clearly.

3. MADHAB SENSITIVITY: When topics involve differences between Islamic schools of thought (Hanafi, Maliki, Shafi'i, Hanbali), mention that there are scholarly differences and advise the user to follow their own madhab or consult a local scholar.

4. FORBIDDEN TOPICS: Do not issue fatwas. Do not make definitive rulings on complex fiqh matters. Do not engage with political Islam debates. If asked, say: "This requires a qualified scholar's guidance."

5. LANGUAGE: Respond in the same language the user uses (Bengali, English, or Arabic). Use respectful Islamic greetings where appropriate (e.g., "Assalamu Alaikum").

6. TONE: Be respectful, humble, and knowledgeable. Avoid being dismissive of any sincere Islamic question.

7. DISCLAIMER: At the end of EVERY response, add this line:
"⚠️ AI can make mistakes. Please double-check all information from trusted Islamic sources or a qualified scholar."
''';

/// Calls Groq API — accepts any of Groq's supported model IDs
class GroqService {
  final String apiKey;
  final String modelId;
  final String modelName;

  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  GroqService({
    required this.apiKey,
    required this.modelId,
    required this.modelName,
  });

  Future<String> sendMessage(List<ChatMessage> history) async {
    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': _systemPrompt},
    ];

    for (final msg in history) {
      messages.add({
        'role': msg.role == MessageRole.user ? 'user' : 'assistant',
        'content': msg.text,
      });
    }

    final body = json.encode({
      'model': modelId,
      'messages': messages,
      'temperature': 0.7,
      'max_tokens': 1024,
    });

    final response = await http
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: body,
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 429 || response.statusCode == 503) {
      throw RateLimitException('$modelName rate limit: ${response.statusCode}');
    }

    if (response.statusCode != 200) {
      throw AIServiceException(
          '$modelName error ${response.statusCode}: ${response.body}');
    }

    final data = json.decode(response.body);
    final text = data['choices']?[0]?['message']?['content'];
    if (text == null) {
      throw AIServiceException('$modelName returned empty response');
    }
    return text as String;
  }
}
