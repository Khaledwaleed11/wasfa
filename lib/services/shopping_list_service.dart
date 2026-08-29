import 'package:hive/hive.dart';

import '../models/shopping_item_model.dart';

class ShoppingListService {
  static const String boxName = 'shopping_list';

  static Future<void> addItem(ShoppingItemModel item) async {
    final box = Hive.box(boxName);

    await box.put(item.id, item.toJson());
  }

  static Future<void> addItems(List<ShoppingItemModel> items) async {
    final box = Hive.box(boxName);

    for (final item in items) {
      await box.put(item.id, item.toJson());
    }
  }

  static Future<List<ShoppingItemModel>> getItems() async {
    final box = Hive.box(boxName);
    final items = <ShoppingItemModel>[];

    for (final value in box.values) {
      if (value is Map) {
        try {
          items.add(
            ShoppingItemModel.fromJson(Map<dynamic, dynamic>.from(value)),
          );
        } catch (_) {}
      }
    }

    return items;
  }

  static Future<void> toggleItem(ShoppingItemModel item) async {
    final updated = item.copyWith(isCompleted: !item.isCompleted);

    await addItem(updated);
  }

  static Future<void> removeItem(String id) async {
    final box = Hive.box(boxName);

    await box.delete(id);
  }

  static Future<void> clearItems() async {
    final box = Hive.box(boxName);

    await box.clear();
  }
}
