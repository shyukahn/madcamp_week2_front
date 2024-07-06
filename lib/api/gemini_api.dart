import 'package:flutter_gemini/flutter_gemini.dart';

class GeminiSource {
  static final _gemini = Gemini.instance;
  static const _errorMessage = 'Error: Result Not Generated';

  static Future<String> getFromText(String text) async {
    try {
      final value = await _gemini.text(text, modelName: 'models/gemini-pro');
      return value?.output ?? _errorMessage;
    } catch (e) {
      return e.toString();
    }
  }
}