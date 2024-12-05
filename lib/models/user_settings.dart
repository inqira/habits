import 'package:flutter/material.dart';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:signals/signals.dart';

class UserSettings {
  final Signal<String> name;
  final Signal<bool> is24HourFormat;
  final Signal<FlexScheme> themeScheme;
  final Signal<ThemeMode> themeMode;

  UserSettings({
    String initialName = '',
    bool initialIs24HourFormat = false,
    FlexScheme initialThemeScheme = FlexScheme.bahamaBlue,
    ThemeMode initialThemeMode = ThemeMode.system,
  })  : name = signal(initialName),
        is24HourFormat = signal(initialIs24HourFormat),
        themeScheme = signal(initialThemeScheme),
        themeMode = signal(initialThemeMode);

  void updateSettings({
    String? newName,
    bool? newIs24HourFormat,
    FlexScheme? newThemeScheme,
    ThemeMode? newThemeMode,
  }) {
    if (newName != null) name.value = newName;
    if (newIs24HourFormat != null) is24HourFormat.value = newIs24HourFormat;
    if (newThemeScheme != null) themeScheme.value = newThemeScheme;
    if (newThemeMode != null) themeMode.value = newThemeMode;
  }
}
