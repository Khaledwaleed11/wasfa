import 'dart:convert';

import 'package:http/http.dart' as http;

class CategoryApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // ============================================================
  // GET ALL CATEGORIES
  // ============================================================

  Future<Map<String, dynamic>> getCategories() async {
    final url = Uri.parse('$_baseUrl/categories.php');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          return data;
        }

        throw Exception('Invalid categories response');
      }

      throw Exception('Failed to load categories');
    } catch (e) {
      throw Exception('Something went wrong while loading categories');
    }
  }
}
