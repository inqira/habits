import 'package:flutter/material.dart';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:signals/signals_flutter.dart';

import 'package:habits/services/service_locator.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = serviceLocator.settingsService;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Theme Mode Card
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Theme Mode',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Watch((context) {
                      return RadioListTile(
                        title: const Text('System'),
                        subtitle: const Text('Follow system settings'),
                        value: ThemeMode.system,
                        groupValue: settingsService.settings.themeMode.value,
                        onChanged: (value) {
                          if (value != null) {
                            settingsService.settings.updateSettings(
                              newThemeMode: value,
                            );
                            settingsService.saveSettings();
                          }
                        },
                      );
                    }),
                    Watch((context) {
                      return RadioListTile(
                        title: const Text('Light'),
                        subtitle: const Text('Always use light theme'),
                        value: ThemeMode.light,
                        groupValue: settingsService.settings.themeMode.value,
                        onChanged: (value) {
                          if (value != null) {
                            settingsService.settings.updateSettings(
                              newThemeMode: value,
                            );
                            settingsService.saveSettings();
                          }
                        },
                      );
                    }),
                    Watch((context) {
                      return RadioListTile(
                        title: const Text('Dark'),
                        subtitle: const Text('Always use dark theme'),
                        value: ThemeMode.dark,
                        groupValue: settingsService.settings.themeMode.value,
                        onChanged: (value) {
                          if (value != null) {
                            settingsService.settings.updateSettings(
                              newThemeMode: value,
                            );
                            settingsService.saveSettings();
                          }
                        },
                      );
                    }),
                  ],
                ),
              ),
              // Theme Scheme Card
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Theme Scheme',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Watch((context) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          children: [
                            DropdownButtonFormField<FlexScheme>(
                              value: settingsService.settings.themeScheme.value,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              items: FlexScheme.values.map((scheme) {
                                final themePrimaryColor =
                                    FlexThemeData.light(scheme: scheme)
                                        .primaryColor;
                                return DropdownMenuItem(
                                  value: scheme,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: themePrimaryColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        scheme.name
                                            .replaceAllMapped(
                                              RegExp(r'([A-Z])'),
                                              (match) => ' ${match[1]}',
                                            )
                                            .trim()
                                            .toLowerCase()
                                            .split(' ')
                                            .map((word) =>
                                                word[0].toUpperCase() +
                                                word.substring(1))
                                            .join(' '),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (scheme) {
                                if (scheme != null) {
                                  settingsService.settings.updateSettings(
                                    newThemeScheme: scheme,
                                  );
                                  settingsService.saveSettings();
                                }
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Select a color scheme to personalize your app experience',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
