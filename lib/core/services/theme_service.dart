import 'package:flutter/material.dart';

class ThemeService {
  ThemeService._();
  static final ThemeService instance = ThemeService._();

  final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  bool get isDarkMode => themeNotifier.value == ThemeMode.dark;

  void toggleTheme() {
    themeNotifier.value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
  }
}
