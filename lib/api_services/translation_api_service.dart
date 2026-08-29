import 'dart:convert';

import 'package:http/http.dart' as http;

class TranslationApiService {
  static const String baseUrl = 'https://api.mymemory.translated.net/get';

  Future<String> translate({
    required String text,
    String from = 'en',
    String to = 'ar',
  }) async {
    if (text.trim().isEmpty) {
      return '';
    }

    final uri = Uri.parse(
      baseUrl,
    ).replace(queryParameters: {'q': text, 'langpair': '$from|$to'});

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Translation API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final responseData = data['responseData'] as Map<String, dynamic>?;

    final translatedText = responseData?['translatedText']?.toString();

    if (translatedText == null || translatedText.trim().isEmpty) {
      throw Exception('Translation result is empty.');
    }

    return translatedText;
  }
}
