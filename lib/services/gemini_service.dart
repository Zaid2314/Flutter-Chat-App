// Path: lib/services/gemini_service.dart

import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // Use the ID defined in new_message.dart to maintain consistency
  static const String aiUserId = 'gemini-bot';

  // ⚠️ WARNING: Hardcoding API key is not secure. Use flutter_dotenv or --dart-define.
  static const String _apiKey = 'AIzaSyCx44evKq8ywERoorDxucnFbUtSUUHfzVs';

  final GenerativeModel _model;

  GeminiService()
      : _model = GenerativeModel(
    // 'gemini-1.5-flash' is a fast and efficient model
    model: 'gemini-2.5-flash',
    apiKey: _apiKey,
  );

  /// Yeh function AI se response generate karwayega (text return karta hai)
  Future<String> generateResponse(String prompt) async {
    try {
      // API ko call karne ke liye content तैयार karein
      final content = [Content.text(prompt)];

      // API se response ka intezaar karein
      final response = await _model.generateContent(content);

      // Response se text nikal kar return karein
      return response.text ?? 'Sorry, the AI model returned no text.';
    } catch (e) {
      // Return a user-friendly error message on failure
      print('Gemini API Error: $e');
      return 'Sorry, an error occurred while connecting to the AI.';
    }
  }
}