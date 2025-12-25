import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing app theme (light/dark mode)
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _seedKey = 'theme_seed';
  ThemeMode _themeMode = ThemeMode.dark;
  Color _seedColor = const Color(0xFF4DB6AC);

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  Color get seedColor => _seedColor;

  ThemeProvider() {
    _loadTheme();
  }

  /// Load theme preference from storage
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? true;
    final seedValue = prefs.getInt(_seedKey);
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    if (seedValue != null) {
      _seedColor = Color(seedValue);
    }
    notifyListeners();
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _themeMode == ThemeMode.dark);
  }

  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, mode == ThemeMode.dark);
    }
  }

  /// Set custom seed color for theming
  Future<void> setSeedColor(Color color) async {
    _seedColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_seedKey, color.value);
  }

  /// Reset seed color to default
  Future<void> resetSeedColor() async {
    await setSeedColor(const Color(0xFF4DB6AC));
  }
}
