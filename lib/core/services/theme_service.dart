import 'package:flutter/material.dart';

class ThemeService {
  ThemeService._();
  static final ThemeService instance = ThemeService._();

  final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false);

  bool get isDarkMode => isDarkModeNotifier.value;

  void toggleTheme() {
    isDarkModeNotifier.value = !isDarkModeNotifier.value;
  }

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;
}
