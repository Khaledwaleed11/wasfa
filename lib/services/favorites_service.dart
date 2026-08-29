import 'package:hive_flutter/hive_flutter.dart';

import '../models/meal_model.dart';

class FavoritesService {
  static const String _boxName = 'favoriteMeals';

  static Future<Box> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box(_boxName);
    }

    return Hive.openBox(_boxName);
  }

  static Future<List<MealModel>> getFavorites() async {
    final box = await _openBox();

    return box.values
        .whereType<Map>()
        .map((item) => MealModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<bool> isFavorite(String mealId) async {
    final box = await _openBox();

    return box.containsKey(mealId);
  }

  static Future<void> addFavorite(MealModel meal) async {
    final box = await _openBox();

    await box.put(meal.id, meal.toJson());
  }

  static Future<void> removeFavorite(String mealId) async {
    final box = await _openBox();

    await box.delete(mealId);
  }

  static Future<bool> toggleFavorite(MealModel meal) async {
    final box = await _openBox();

    if (box.containsKey(meal.id)) {
      await box.delete(meal.id);
      return false;
    }

    await box.put(meal.id, meal.toJson());

    return true;
  }

  static Future<void> clearFavorites() async {
    final box = await _openBox();

    await box.clear();
  }
}
