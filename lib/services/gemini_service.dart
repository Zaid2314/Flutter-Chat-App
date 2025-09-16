// Path: lib/services/gemini_service.dart

import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // ✅ Bas is line ko theek karna tha
  static const String _apiKey = 'AIzaSyDJjAAjA__la3gsHakYti_miu-xxOI-Fn8';

  // Gemini model ko initialize karein
  final GenerativeModel _model;

  GeminiService()
      : _model = GenerativeModel(
    // 'gemini-1.5-flash' ek fast aur efficient model hai
    model: 'gemini-1.5-flash',
    apiKey: _apiKey,
  );

  // Yeh function AI se response generate karwayega
  Future<String> generateResponse(String prompt) async {
    try {
      // API ko call karne ke liye content तैयार karein
      final content = [Content.text(prompt)];

      // API se response ka intezaar karein
      final response = await _model.generateContent(content);

      // Response se text nikal kar return karein
      return response.text ?? 'Sorry, I could not process that.';
    } catch (e) {
      // Agar koi error aaye toh use console mein print karein
      return 'Sorry, an error occurred.';
    }
  }
}