import 'package:flutter/material.dart';

import 'package:fluttermoji/fluttermoji.dart';
import 'package:signals/signals_flutter.dart';

import 'package:habits/services/service_locator.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditAvatarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Edit Avatar',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: FluttermojiCircleAvatar(
                    radius: 48,
                  ),
                ),
                const SizedBox(height: 24),
                FluttermojiCustomizer(
                  scaffoldWidth: MediaQuery.of(context).size.width,
                  autosave: true,
                  theme: FluttermojiThemeData(
                    primaryBgColor: Colors.transparent,
                    secondaryBgColor: Colors.transparent,
                    iconColor: Theme.of(context).colorScheme.primary,
                    selectedIconColor: Theme.of(context).colorScheme.primary,
                    unselectedIconColor:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                    labelTextStyle: Theme.of(context).textTheme.bodyMedium!,
                    selectedTileDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    unselectedTileDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    tilePadding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final settingsService = serviceLocator.settingsService;
    final controller = TextEditingController(
      text: settingsService.settings.name.value,
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Name',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Your Name',
                    hintText: 'Enter your name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        if (controller.text.trim().isNotEmpty) {
                          settingsService.settings.updateSettings(
                            newName: controller.text.trim(),
                          );
                          settingsService.saveSettings();
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = serviceLocator.settingsService;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Welcome Message
              Text(
                '👋 Welcome back,',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Watch((context) {
                final name = settingsService.settings.name.value;
                return Text(
                  name.isEmpty ? 'Friend' : name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                );
              }),
              const SizedBox(height: 8),
              Text(
                'Here you can customize your profile and make it uniquely yours!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 32),

              // Avatar Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      FluttermojiCircleAvatar(
                        radius: 64,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => _showEditAvatarDialog(context),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Avatar'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Name Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Name',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Watch((context) {
                        final name = settingsService.settings.name.value;
                        return Row(
                          children: [
                            Expanded(
                              child: Text(
                                name.isEmpty ? 'Not set' : name,
                                style: name.isEmpty
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        )
                                    : Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _showEditNameDialog(context),
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
