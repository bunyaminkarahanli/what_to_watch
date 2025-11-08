import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_watch/constants/pref_keys.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme(bool value) async {
    _isDark = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefKeys.keyIsDark, value);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(PrefKeys.keyIsDark) ?? false;
    notifyListeners();
  }
}
