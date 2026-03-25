import 'dart:developer' as dev;
import '../../../config/api_keys.dart';
import '../models/chat_message.dart';
import 'gemini_service.dart';
import 'groq_service.dart';
import 'openrouter_service.dart';

/// Result returned on a successful AI response
class AIResponse {
  final String text;
  final String modelUsed;
  AIResponse({required this.text, required this.modelUsed});
}

/// Orchestrates free AI models in a waterfall fallback pattern.
///
/// Priority order:
///  1. Gemini 2.0 Flash          (Google — high quality, fast)
///  2. Groq Llama3.3-70b          (Groq — 30 RPM free, high quality)
///  3. Groq Llama3.1-8b           (Groq — 30 RPM free, fast fallback)
///  4. OpenRouter Gemma-2-9b      (Google via OpenRouter — reliable free)
///  5. OpenRouter Mistral-7b      (reliable final fallback)
class AIModelManager {
  /// Maximum conversation history sent to each model
  static const int _maxHistory = 10;

  final List<ChatMessage> _history = [];
  List<ChatMessage> get history => List.unmodifiable(_history);

  // ── Services ──────────────────────────────────────────────────────────────

  late final GeminiService _gemini = GeminiService(
    apiKey: ApiKeys.geminiApiKey,
  );

  late final GroqService _groqLlama70b = GroqService(
    apiKey: ApiKeys.groqApiKey,
    modelId: 'llama-3.3-70b-versatile',
    modelName: 'Llama 3.3 70b',
  );

  late final GroqService _groqLlama8b = GroqService(
    apiKey: ApiKeys.groqApiKey,
    modelId: 'llama-3.1-8b-instant',
    modelName: 'Llama 3.1 8b',
  );

  late final OpenRouterService _orGemma = OpenRouterService(
    apiKey: ApiKeys.openRouterApiKey,
    modelId: 'google/gemma-2-9b-it:free',
    modelName: 'Gemma 2 9b',
  );

  late final OpenRouterService _orMistral = OpenRouterService(
    apiKey: ApiKeys.openRouterApiKey,
    modelId: 'mistralai/mistral-7b-instruct:free',
    modelName: 'Mistral 7b',
  );

  // ── Public API ────────────────────────────────────────────────────────────

  /// Add a user message and get an AI response via waterfall fallback.
  Future<AIResponse> sendMessage(String userText) async {
    _history.add(ChatMessage(
      text: userText,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    ));

    // Trim to last N messages for context window
    final contextWindow = _history.length > _maxHistory
        ? _history.sublist(_history.length - _maxHistory)
        : List<ChatMessage>.from(_history);

    final result = await _tryModels(contextWindow);

    _history.add(ChatMessage(
      text: result.text,
      role: MessageRole.assistant,
      modelUsed: result.modelUsed,
      timestamp: DateTime.now(),
    ));

    return result;
  }

  /// Clear conversation history
  void clearHistory() => _history.clear();

  // ── Private waterfall ────────────────────────────────────────────────────

  Future<AIResponse> _tryModels(List<ChatMessage> ctx) async {
    // 1. Gemini 2.0 Flash
    try {
      final text = await _gemini.sendMessage(ctx);
      dev.log('[AIManager] Responded: Gemini 2.0 Flash');
      return AIResponse(text: text, modelUsed: 'Gemini 2.0 Flash');
    } on RateLimitException catch (e) {
      dev.log('[AIManager] Gemini rate-limited: $e — trying Groq Llama 70b');
    } catch (e) {
      dev.log('[AIManager] Gemini failed: $e — trying Groq Llama 70b');
    }

    // 2. Groq Llama3.3-70b
    try {
      final text = await _groqLlama70b.sendMessage(ctx);
      dev.log('[AIManager] Responded: Llama 3.3 70b');
      return AIResponse(text: text, modelUsed: 'Llama 3.3 70b');
    } on RateLimitException catch (e) {
      dev.log('[AIManager] Groq 70b rate-limited: $e — trying Llama 3.1 8b');
    } catch (e) {
      dev.log('[AIManager] Groq 70b failed: $e — trying Llama 3.1 8b');
    }

    // 3. Groq Llama3.1-8b
    try {
      final text = await _groqLlama8b.sendMessage(ctx);
      dev.log('[AIManager] Responded: Llama 3.1 8b');
      return AIResponse(text: text, modelUsed: 'Llama 3.1 8b');
    } on RateLimitException catch (e) {
      dev.log('[AIManager] Groq 8b rate-limited: $e — trying Gemma-2-9b');
    } catch (e) {
      dev.log('[AIManager] Groq 8b failed: $e — trying Gemma-2-9b');
    }

    // 4. OpenRouter Gemma-2-9b
    try {
      final text = await _orGemma.sendMessage(ctx);
      dev.log('[AIManager] Responded: Gemma 2 9b');
      return AIResponse(text: text, modelUsed: 'Gemma 2 9b');
    } on RateLimitException catch (e) {
      dev.log('[AIManager] Gemma rate-limited: $e — trying Mistral 7b');
    } catch (e) {
      dev.log('[AIManager] Gemma failed: $e — trying Mistral 7b');
    }

    // 5. OpenRouter Mistral-7b
    try {
      final text = await _orMistral.sendMessage(ctx);
      dev.log('[AIManager] Responded: Mistral 7b');
      return AIResponse(text: text, modelUsed: 'Mistral 7b');
    } on RateLimitException catch (e) {
      dev.log('[AIManager] Mistral rate-limited: $e');
    } catch (e) {
      dev.log('[AIManager] Mistral failed: $e');
    }

    throw AllModelsExhaustedException();
  }
}

class AllModelsExhaustedException implements Exception {}
