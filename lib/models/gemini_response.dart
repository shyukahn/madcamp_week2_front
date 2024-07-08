import 'dart:convert';

class GeminiResponse {
  late final String content;
  late final String answer;
  late final String solution;

  GeminiResponse({required this.content, required this.answer, required this.solution});

  GeminiResponse.fromString(String responseString) {
    final Map<String, String> map = Map<String, String>.from(jsonDecode(responseString));
    content = map['content']!;
    answer = map['answer']!;
    solution = map['solution']!;
  }
}