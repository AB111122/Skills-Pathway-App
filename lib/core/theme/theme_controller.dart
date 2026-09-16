import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key for storing theme mode preference.
const String kThemeModeStorageKey = 'app_theme_mode';

/// StateNotifier that manages and persists the app's [ThemeMode].
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier([ThemeMode initial = ThemeMode.system]) : super(initial) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(kThemeModeStorageKey);
      if (savedMode != null) {
        state = _themeModeFromString(savedMode);
      }
    } catch (e) {
      debugPrint('[ThemeModeNotifier] Failed to load theme mode: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kThemeModeStorageKey, mode.name);
    } catch (e) {
      debugPrint('[ThemeModeNotifier] Failed to persist theme mode: $e');
    }
  }

  static ThemeMode _themeModeFromString(String name) {
    switch (name) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}

/// Provider for accessing and modifying the active [ThemeMode].
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
