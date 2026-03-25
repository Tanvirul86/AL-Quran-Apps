import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

/// Calls Google Gemini 2.0 Flash API
class GeminiService {
  final String apiKey;
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  static const String _systemPrompt = '''
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

  GeminiService({required this.apiKey});

  Future<String> sendMessage(List<ChatMessage> history) async {
    final url = Uri.parse('$_baseUrl?key=$apiKey');

    // Build conversation history for Gemini format
    final contents = <Map<String, dynamic>>[];

    // Gemini uses "system_instruction" for the system prompt
    for (final msg in history) {
      contents.add({
        'role': msg.role == MessageRole.user ? 'user' : 'model',
        'parts': [
          {'text': msg.text}
        ],
      });
    }

    final body = json.encode({
      'system_instruction': {
        'parts': [
          {'text': _systemPrompt}
        ]
      },
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 1024,
      },
    });

    final response = await http
        .post(url,
            headers: {'Content-Type': 'application/json'}, body: body)
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 429 || response.statusCode == 503) {
      throw RateLimitException('Gemini rate limit: ${response.statusCode}');
    }

    if (response.statusCode != 200) {
      throw AIServiceException(
          'Gemini error ${response.statusCode}: ${response.body}');
    }

    final data = json.decode(response.body);
    final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
    if (text == null) throw AIServiceException('Gemini returned empty response');
    return text as String;
  }
}

class RateLimitException implements Exception {
  final String message;
  RateLimitException(this.message);
}

class AIServiceException implements Exception {
  final String message;
  AIServiceException(this.message);
}
