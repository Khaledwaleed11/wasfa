import 'package:hive_flutter/hive_flutter.dart';

import '../models/meal_model.dart';

class RecentMealsService {
  static const String _boxName = 'recentMeals';
  static const int _maxMeals = 10;

  static Future<Box> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box(_boxName);
    }

    return Hive.openBox(_boxName);
  }

  static Future<List<MealModel>> getRecentMeals() async {
    final box = await _openBox();
    final keys = box.keys.toList().reversed;
    final meals = <MealModel>[];

    for (final key in keys) {
      final value = box.get(key);

      if (value is Map) {
        try {
          meals.add(MealModel.fromJson(Map<String, dynamic>.from(value)));
        } catch (_) {}
      }
    }

    return meals;
  }

  static Future<void> addRecentMeal(MealModel meal) async {
    final box = await _openBox();

    await box.delete(meal.id);
    await box.put(meal.id, meal.toJson());

    final keys = box.keys.toList();

    if (keys.length > _maxMeals) {
      final keysToDelete = keys.take(keys.length - _maxMeals).toList();

      for (final key in keysToDelete) {
        await box.delete(key);
      }
    }
  }

  static Future<void> removeRecentMeal(String mealId) async {
    final box = await _openBox();

    await box.delete(mealId);
  }

  static Future<void> clearRecentMeals() async {
    final box = await _openBox();

    await box.clear();
  }
}
