/// Configuration for a single AI model endpoint
class AIModelConfig {
  final String name;       // Human-readable label shown to user, e.g. "Gemini 1.5 Flash"
  final String endpoint;   // Full URL
  final String apiKey;
  final String modelId;    // Model identifier string for the API body/header
  final AIProvider provider;

  const AIModelConfig({
    required this.name,
    required this.endpoint,
    required this.apiKey,
    required this.modelId,
    required this.provider,
  });
}

enum AIProvider { gemini, groq, openRouter }
