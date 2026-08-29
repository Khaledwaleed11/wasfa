import 'package:hive_flutter/hive_flutter.dart';

import '../api_services/translation_api_service.dart';

class TranslationService {
  final TranslationApiService apiService = TranslationApiService();

  static const String boxName = 'translations';

  // ============================================================
  // TRANSLATE TEXT
  // ============================================================

  Future<String> translateText(String text) async {
    final cleanText = text.trim();

    if (cleanText.isEmpty) {
      return '';
    }

    final box = Hive.box(boxName);

    // ==========================================================
    // CHECK CACHE
    // ==========================================================

    final cachedTranslation = box.get(cleanText);

    if (cachedTranslation != null) {
      return cachedTranslation.toString();
    }

    // ==========================================================
    // CALL API
    // ==========================================================

    final translatedText = await apiService.translate(
      text: cleanText,
      from: 'en',
      to: 'ar',
    );

    // ==========================================================
    // SAVE TO CACHE
    // ==========================================================

    await box.put(cleanText, translatedText);

    return translatedText;
  }

  // ============================================================
  // CLEAR CACHE
  // ============================================================

  Future<void> clearCache() async {
    final box = Hive.box(boxName);

    await box.clear();
  }
}
