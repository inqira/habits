import 'package:flutter/material.dart';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:habits/models/user_settings.dart';

export 'package:habits/models/user_settings.dart';

class SettingsService {
  final UserSettings settings = UserSettings();
  final _prefs = SharedPreferences.getInstance();

  Future<void> loadSettings() async {
    final prefs = await _prefs;
    final savedThemeSchemeIndex = prefs.getInt('themeScheme');
    final themeScheme = savedThemeSchemeIndex != null &&
            savedThemeSchemeIndex >= 0 &&
            savedThemeSchemeIndex < FlexScheme.values.length
        ? FlexScheme.values[savedThemeSchemeIndex]
        : FlexScheme.bahamaBlue;

    final savedThemeModeIndex = prefs.getInt('themeMode');
    final themeMode = savedThemeModeIndex != null &&
            savedThemeModeIndex >= 0 &&
            savedThemeModeIndex < ThemeMode.values.length
        ? ThemeMode.values[savedThemeModeIndex]
        : ThemeMode.system;

    settings.updateSettings(
      newName: prefs.getString('name') ?? '',
      newIs24HourFormat: prefs.getBool('is24HourFormat') ?? false,
      newThemeScheme: themeScheme,
      newThemeMode: themeMode,
    );
  }

  Future<void> saveSettings() async {
    final prefs = await _prefs;
    await prefs.setString('name', settings.name.value);
    await prefs.setBool('is24HourFormat', settings.is24HourFormat.value);
    await prefs.setInt('themeScheme', settings.themeScheme.value.index);
    await prefs.setInt('themeMode', settings.themeMode.value.index);
  }
}
