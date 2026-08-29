import '../api_services/meal_api_service.dart';
import '../models/category_model.dart';
import '../models/meal_model.dart';

class MealService {
  final MealApiService apiService = MealApiService();

  Future<MealModel> getRandomMeal() async {
    final data = await apiService.getRandomMeal();

    final meals = data['meals'] as List?;

    if (meals == null || meals.isEmpty) {
      throw Exception('No random meal found');
    }

    return MealModel.fromJson(meals.first as Map<String, dynamic>);
  }

  Future<List<MealModel>> searchMeals(String query) async {
    final data = await apiService.searchMeals(query);

    final meals = data['meals'] as List?;

    if (meals == null) {
      return [];
    }

    return meals
        .map((meal) => MealModel.fromJson(meal as Map<String, dynamic>))
        .toList();
  }

  Future<MealModel> getMealDetails(String mealId) async {
    final data = await apiService.getMealDetails(mealId);

    final meals = data['meals'] as List?;

    if (meals == null || meals.isEmpty) {
      throw Exception('Meal not found');
    }

    return MealModel.fromJson(meals.first as Map<String, dynamic>);
  }

  Future<List<CategoryModel>> getCategories() async {
    final data = await apiService.getCategories();

    final categories = data['categories'] as List?;

    if (categories == null) {
      return [];
    }

    return categories
        .map(
          (category) =>
              CategoryModel.fromJson(category as Map<String, dynamic>),
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
    if (data == null || data is! List) {
      return [];
    }

    return data
        .map((meal) => MealModel.fromJson(meal as Map<String, dynamic>))
        .toList();
  }
}
