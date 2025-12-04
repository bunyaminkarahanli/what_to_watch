import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_watch/constants/pref_keys.dart';

class CarFavoriteService {
  /// ▶ Araba kaydet
  static Future<void> saveCar(Map<String, String> car) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList(PrefKeys.keySavedCars) ?? [];

    final encoded = jsonEncode(car);

    // Duplicate kontrol: model bazlı (istersen burayı sonra değiştirebilirsin)
    final exists = saved.any((item) {
      final decoded = jsonDecode(item);
      return decoded["model"] == car["model"];
    });

    if (!exists) {
      saved.add(encoded);
      await prefs.setStringList(PrefKeys.keySavedCars, saved);
    }
  }

  /// ▶ Tüm kayıtlı arabaları yükle
  static Future<List<Map<String, String>>> loadCars() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList(PrefKeys.keySavedCars) ?? [];

    return saved
        .map((e) {
          try {
            final decoded = jsonDecode(e) as Map<String, dynamic>;
            final safeMap = decoded.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            );
            return safeMap;
          } catch (_) {
            return <String, String>{};
          }
        })
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// ▶ Araba sil (model üzerinden)
  static Future<void> removeCar(String model) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList(PrefKeys.keySavedCars) ?? [];

    saved.removeWhere((item) {
      try {
        final decoded = jsonDecode(item);
        return decoded["model"] == model;
      } catch (_) {
        return false;
      }
    });

    await prefs.setStringList(PrefKeys.keySavedCars, saved);
  }
}
