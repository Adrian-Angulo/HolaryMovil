import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/dependency_injection.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final Ref _ref;

  ThemeNotifier(this._ref) : super(_getInitialTheme(_ref));

  static ThemeMode _getInitialTheme(Ref ref) {
    try {
      final storage = ref.read(sessionStorageProvider);
      final savedMode = storage.getThemeMode();
      switch (savedMode) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        default:
          return ThemeMode.system;
      }
    } catch (_) {
      return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final storage = _ref.read(sessionStorageProvider);
    String modeString = 'system';
    if (mode == ThemeMode.light) {
      modeString = 'light';
    } else if (mode == ThemeMode.dark) {
      modeString = 'dark';
    }
    await storage.saveThemeMode(modeString);
  }

  void toggleTheme() {
    if (state == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }
}

final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(ref);
});
