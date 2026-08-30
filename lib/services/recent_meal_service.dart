import 'package:hive_flutter/hive_flutter.dart';

import '../models/meal_model.dart';

class RecentMealsService {
  static const String _boxName = 'recentMeals';
  static const int _maxMeals = 10;
  static const String _timestampKey = '_recentTimestamp';

  static Future<Box> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box(_boxName);
    }

    return Hive.openBox(_boxName);
  }

  static Future<List<MealModel>> getRecentMeals() async {
    final box = await _openBox();

    final entries = <MapEntry<dynamic, dynamic>>[];

    for (final key in box.keys) {
      final value = box.get(key);

      if (value is Map) {
        entries.add(MapEntry(key, value));
      }
    }

    entries.sort((a, b) {
      final firstTimestamp = _getTimestamp(a.value);
      final secondTimestamp = _getTimestamp(b.value);

      return secondTimestamp.compareTo(firstTimestamp);
    });

    final meals = <MealModel>[];

    for (final entry in entries) {
      try {
        final data = Map<String, dynamic>.from(entry.value);

        data.remove(_timestampKey);

        meals.add(MealModel.fromJson(data));
      } catch (_) {}
    }

    return meals;
  }

  static Future<void> addRecentMeal(MealModel meal) async {
    final box = await _openBox();

    await box.delete(meal.id);

    final data = meal.toJson();

    data[_timestampKey] = DateTime.now().millisecondsSinceEpoch;

    await box.put(meal.id, data);

    await _trimOldMeals(box);
  }

  static Future<void> removeRecentMeal(String mealId) async {
    final box = await _openBox();

    await box.delete(mealId);
  }

  static Future<void> clearRecentMeals() async {
    final box = await _openBox();

    await box.clear();
  }

  static int _getTimestamp(dynamic value) {
    if (value is! Map) {
      return 0;
    }

    final timestamp = value[_timestampKey];

    if (timestamp is int) {
      return timestamp;
    }

    if (timestamp is num) {
      return timestamp.toInt();
    }

    return 0;
  }

  static Future<void> _trimOldMeals(Box box) async {
    if (box.length <= _maxMeals) {
      return;
    }

    final entries = <MapEntry<dynamic, dynamic>>[];

    for (final key in box.keys) {
      final value = box.get(key);

      if (value is Map) {
        entries.add(MapEntry(key, value));
      }
    }

    entries.sort((a, b) {
      final firstTimestamp = _getTimestamp(a.value);
      final secondTimestamp = _getTimestamp(b.value);

      return firstTimestamp.compareTo(secondTimestamp);
    });

    final numberToDelete = entries.length - _maxMeals;

    for (int i = 0; i < numberToDelete; i++) {
      await box.delete(entries[i].key);
    }
  }
}
