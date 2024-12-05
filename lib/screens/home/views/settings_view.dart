import 'package:flutter/material.dart';

import 'package:fluttermoji/fluttermoji.dart';

import 'package:habits/screens/settings/about_screen/about_screen.dart';
import 'package:habits/screens/settings/appearance_screen/appearance_screen.dart';
import 'package:habits/screens/settings/categories_screen/categories_screen.dart';
import 'package:habits/screens/settings/profile_screen/profile_screen.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> with RestorationMixin {
  final _scrollController = ScrollController();
  final RestorableDouble _scrollOffset = RestorableDouble(0.0);

  @override
  String? get restorationId => 'settings_view';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_scrollOffset, 'scroll_offset');
    if (_scrollOffset.value > 0) {
      _scrollController.jumpTo(_scrollOffset.value);
    }
  }

  void _handleScroll() {
    _scrollOffset.value = _scrollController.offset;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(24),
        children: [
          // Profile Card
          Card.outlined(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  FluttermojiCircleAvatar(
                    radius: 64,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_outline),
                    label: const Text('Profile Settings'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Other Settings Card
          Card.outlined(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Other Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: const Text('Categories'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoriesScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.color_lens_outlined),
                  title: const Text('Appearance'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppearanceScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
