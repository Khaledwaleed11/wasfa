import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class MealApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  static const Duration _timeout = Duration(seconds: 15);

  Future<Map<String, dynamic>> _get(String url, String errorMessage) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception(errorMessage);
      }

      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid server response');
      }

      return data;
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on FormatException {
      throw Exception('Invalid server response.');
    } on http.ClientException {
      throw Exception('Unable to connect to the server.');
    }
  }

  Future<Map<String, dynamic>> getRandomMeal() {
    return _get('$_baseUrl/random.php', 'Failed to load random meal');
  }

  Future<Map<String, dynamic>> searchMeals(String query) {
    final encodedQuery = Uri.encodeComponent(query.trim());

    return _get(
      '$_baseUrl/search.php?s=$encodedQuery',
      'Failed to search meals',
    );
  }

  Future<Map<String, dynamic>> getMealDetails(String mealId) {
    final encodedMealId = Uri.encodeComponent(mealId.trim());

    return _get(
      '$_baseUrl/lookup.php?i=$encodedMealId',
      'Failed to load meal details',
    );
  }

  Future<Map<String, dynamic>> getCategories() {
    return _get('$_baseUrl/categories.php', 'Failed to load categories');
  }

  Future<Map<String, dynamic>> getMealsByCategory(String category) {
    final encodedCategory = Uri.encodeComponent(category.trim());

    return _get(
      '$_baseUrl/filter.php?c=$encodedCategory',
      'Failed to load meals by category',
    );
  }

  Future<Map<String, dynamic>> getMealsByArea(String area) {
    final encodedArea = Uri.encodeComponent(area.trim());

    return _get(
      '$_baseUrl/filter.php?a=$encodedArea',
      'Failed to load meals by area',
    );
  }

  Future<Map<String, dynamic>> getMealsByIngredient(String ingredient) {
    final encodedIngredient = Uri.encodeComponent(ingredient.trim());

    return _get(
      '$_baseUrl/filter.php?i=$encodedIngredient',
      'Failed to load meals by ingredient',
    );
  }
}
