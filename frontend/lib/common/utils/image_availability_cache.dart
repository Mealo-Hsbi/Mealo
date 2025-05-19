import 'package:flutter/services.dart';

class IngredientImageHelper {
  static final Map<String, bool> _cache = {};

  static Future<bool> canLoadImage(String? path) async {
    if (path == null) return false;
    if (_cache.containsKey(path)) return _cache[path]!;
    try {
      await rootBundle.load(path);
      _cache[path] = true;
    } catch (_) {
      _cache[path] = false;
    }
    return _cache[path]!;
  }
}
