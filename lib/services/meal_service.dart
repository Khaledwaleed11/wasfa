import '../api_services/meal_api_service.dart';
import '../models/category_model.dart';
import '../models/meal_model.dart';

class MealService {
  final MealApiService apiService = MealApiService();

  Future<MealModel> getRandomMeal() async {
    final data = await apiService.getRandomMeal();

    final meals = data['meals'];

    if (meals is! List || meals.isEmpty) {
      throw Exception('No random meal found');
    }

    final firstMeal = meals.first;

    if (firstMeal is! Map) {
      throw Exception('Invalid random meal response');
    }

    return MealModel.fromJson(Map<String, dynamic>.from(firstMeal));
  }

  Future<List<MealModel>> searchMeals(String query) async {
    final data = await apiService.searchMeals(query);

    return _parseMeals(data['meals']);
  }

  Future<MealModel> getMealDetails(String mealId) async {
    final data = await apiService.getMealDetails(mealId);

    final meals = data['meals'];

    if (meals is! List || meals.isEmpty) {
      throw Exception('Meal not found');
    }

    final firstMeal = meals.first;

    if (firstMeal is! Map) {
      throw Exception('Invalid meal response');
    }

    return MealModel.fromJson(Map<String, dynamic>.from(firstMeal));
  }

  Future<List<CategoryModel>> getCategories() async {
    final data = await apiService.getCategories();

    final categories = data['categories'];

    if (categories is! List) {
      return [];
    }

    return categories
        .whereType<Map>()
        .map(
          (category) =>
              CategoryModel.fromJson(Map<String, dynamic>.from(category)),
        )
        .toList();
  }

  Future<List<MealModel>> getMealsByCategory(String category) async {
    final data = await apiService.getMealsByCategory(category);

    return _parseMeals(data['meals']);
  }

  Future<List<MealModel>> getMealsByArea(String area) async {
    final data = await apiService.getMealsByArea(area);

    return _parseMeals(data['meals']);
  }

  Future<List<MealModel>> getMealsByIngredient(String ingredient) async {
    final data = await apiService.getMealsByIngredient(ingredient);

    return _parseMeals(data['meals']);
  }

  List<MealModel> _parseMeals(dynamic data) {
    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map>()
        .map((meal) => MealModel.fromJson(Map<String, dynamic>.from(meal)))
        .toList();
  }
}
